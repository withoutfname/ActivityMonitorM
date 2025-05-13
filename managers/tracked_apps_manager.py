# managers/tracked_apps_manager.py
from PyQt5.QtCore import QObject, pyqtSlot, QDateTime
from backend.database import get_apps_from_tracked_apps_db, save_tracked_apps_db, add_or_update_alias, \
    remove_tracked_apps_db
from models.tracked_apps_model import trackedAppsModel


class trackedAppsManager(QObject):
    def __init__(self):
        super().__init__()
        self._trackedAppsModel = trackedAppsModel()  # Модель для отслеживаемых приложений

    @property
    def trackedAppsModel(self):
        """
        Возвращает модель отслеживаемых приложений.
        """
        return self._trackedAppsModel

    @pyqtSlot()
    def updateTrackedApps(self):
        """
        Обновляет список отслеживаемых приложений из базы данных.
        """
        trackedApps = get_apps_from_tracked_apps_db()  # Получаем данные из базы данных
        self._trackedAppsModel.updateData(trackedApps)  # Обновляем модель

    @pyqtSlot(result="QVariantList")
    def getTrackedApps(self):
        """
        Возвращает список отслеживаемых приложений.
        """
        return self._trackedAppsModel.getTrackedApps()

    @pyqtSlot(list)
    def saveAppsToDatabase(self, apps):
        """
        Сохраняет приложения в базу данных.
        """
        save_tracked_apps_db(apps)

    @pyqtSlot(list)
    def removeAppsFromDatabase(self, apps):
        """
        Удаляет приложения из базы данных.
        Принимает список объектов, где каждый объект содержит:
        - title (название приложения)
        - exePath (путь к исполняемому файлу)
        - processName (название процесса)
        """
        remove_tracked_apps_db(apps)

    @pyqtSlot(str, str, str, str)
    def addOrUpdateAlias(self, name, process_name, exe_path, alias):
        """
        Добавляет или обновляет псевдоним для приложения.
        """
        add_or_update_alias(name, process_name, exe_path, alias)

