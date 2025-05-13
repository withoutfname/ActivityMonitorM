import os
import sys

import psycopg2
from PyQt5.QtWidgets import QApplication, QSystemTrayIcon, QMenu, QAction
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtGui import QIcon
from PyQt5.QtCore import QObject, pyqtSlot

from backend.database import get_db_connection
from managers import openedWindowsManager, trackedAppsManager, appMonitorManager, statsManager, \
    statCleaningManager
from models import openedWindowsModel, trackedAppsModel, statCleaningModel

class WindowController(QObject):
    def __init__(self, window, tray_icon):
        super().__init__()
        self.window = window
        self.tray_icon = tray_icon
        self.is_hidden = False

    @pyqtSlot(int)
    def on_window_visibility_changed(self, visibility):
        # visibility: 0 - Hidden, 1 - Minimized, 2 - Normal, 4 - Maximized
        if visibility == 1:  # Окно свернуто
            self.window.hide()  # Полностью скрываем окно
            self.is_hidden = True
            self.show_hide_action.setText("Показать")
            self.tray_icon.showMessage("Activity", "Приложение свернуто в трей", QSystemTrayIcon.Information, 2000)

    @pyqtSlot()
    def on_window_closing(self):
        self.window.hide()  # Скрываем окно вместо закрытия
        self.is_hidden = True
        self.show_hide_action.setText("Показать")
        self.tray_icon.showMessage("Activity", "Приложение свернуто в трей", QSystemTrayIcon.Information, 2000)

    def toggle_window_visibility(self):
        if self.is_hidden:
            self.window.show()
            self.is_hidden = False
            self.show_hide_action.setText("Скрыть")
        else:
            self.window.hide()
            self.is_hidden = True
            self.show_hide_action.setText("Показать")

    def set_show_hide_action(self, action):
        self.show_hide_action = action

if __name__ == "__main__":
    app = QApplication(sys.argv)

    # Проверяем подключение к базе данных
    try:
        connection = get_db_connection()
        print("Успешное подключение к базе данных!")
        connection.close()
    except psycopg2.Error as e:
        print(f"Ошибка подключения к базе данных: {e}")

    # Модели
    opened_windows_model = openedWindowsModel()
    tracked_apps_model = trackedAppsModel()
    stat_cleaning_model = statCleaningModel()

    # Менеджеры
    opened_windows_manager = openedWindowsManager()
    tracked_apps_manager = trackedAppsManager()
    stat_cleaning_manager = statCleaningManager()
    stats_manager = statsManager()

    # Связываем модель с менеджером
    opened_windows_manager.openedWindowsModel = opened_windows_model
    stat_cleaning_manager._model = stat_cleaning_model

    # Устанавливаем связь между менеджерами
    opened_windows_manager.setTrackedAppsManager(tracked_apps_manager)
    app_monitor_manager = appMonitorManager(tracked_apps_manager)

    # Вызываем функции менеджеров
    tracked_apps_manager.updateTrackedApps()
    app_monitor_manager.checkRunningProcesses()

    # Инициализация QML
    engine = QQmlApplicationEngine()
    context = engine.rootContext()

    # Передаем менеджеры в QML
    context.setContextProperty("openedWindowsManager", opened_windows_manager)
    context.setContextProperty("trackedAppsManager", tracked_apps_manager)
    context.setContextProperty("appMonitorManager", app_monitor_manager)
    context.setContextProperty("statCleaningManager", stat_cleaning_manager)
    context.setContextProperty("statsManager", stats_manager)

    # Передаем модели в QML
    context.setContextProperty("openedWindowsModel", opened_windows_model)
    context.setContextProperty("trackedAppsModel", tracked_apps_manager.trackedAppsModel)
    engine.rootContext().setContextProperty("statCleaningModel", stat_cleaning_model)

    # Загружаем QML
    current_dir = os.path.dirname(os.path.abspath(__file__))
    qml_file_path = os.path.join(current_dir, 'UI', 'base.qml')

    engine.load(qml_file_path)  # Загружаем QML-файл

    # Проверяем, загрузился ли QML
    if not engine.rootObjects():
        sys.exit(-1)

    # Получаем корневое окно QML
    window = engine.rootObjects()[0]

    # Настройка системного трея
    tray_icon = QSystemTrayIcon(QIcon(os.path.join(current_dir, "resources", "icon.ico")), app)
    tray_icon.setToolTip("Activity")

    # Создаем контроллер для управления окном
    window_controller = WindowController(window, tray_icon)

    # Создаем контекстное меню для трея
    tray_menu = QMenu()

    # Добавляем действие "Показать/Скрыть"
    show_hide_action = QAction("Скрыть", app)
    show_hide_action.triggered.connect(window_controller.toggle_window_visibility)
    window_controller.set_show_hide_action(show_hide_action)
    tray_menu.addAction(show_hide_action)

    # Добавляем действие "Выход"
    exit_action = QAction("Выход", app)
    exit_action.triggered.connect(app.quit)
    tray_menu.addAction(exit_action)

    tray_icon.setContextMenu(tray_menu)
    tray_icon.show()

    # Передаем контроллер в QML
    context.setContextProperty("windowController", window_controller)

    # Сразу скрываем окно при запуске
    window_controller.toggle_window_visibility()

    def on_app_exit():
        app_monitor_manager.cleanupOnExit()
        tray_icon.hide()

    app.aboutToQuit.connect(on_app_exit)

    sys.exit(app.exec())