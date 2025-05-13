# managers/app_monitor_manager.py
from PyQt5.QtCore import QObject, QTimer, QDateTime, Qt, pyqtSlot
from backend.database import start_activity, end_activity, delete_incomplete_activities
import psutil


class appMonitorManager(QObject):
    def __init__(self, trackedAppsManager):
        super().__init__()
        self.trackedAppsManager = trackedAppsManager  # Ссылка на менеджер отслеживаемых приложений
        self.runningProcesses = {}  # Словарь для хранения запущенных процессов

        # Удаляем незавершенные активности при запуске
        self.cleanupIncompleteActivitiesOnStartup()

        # Таймер для периодической проверки процессов
        self.timer = QTimer()
        self.timer.timeout.connect(self.checkRunningProcesses)
        self.timer.start(5000)  # Проверка каждые 5 секунд
        self.checkRunningProcesses()  # Первая проверка сразу после запуска

    def cleanupIncompleteActivitiesOnStartup(self):
        """
        Удаляет все незавершенные активности при запуске приложения.
        """
        try:
            delete_incomplete_activities()
        except Exception as e:
            print(f"Ошибка при удалении незавершенных активностей: {e}")

    def checkRunningProcesses(self):
        """
        Проверяет запущенные процессы и сравнивает их с отслеживаемыми приложениями.
        """
        trackedApps = self.trackedAppsManager.getTrackedApps()  # Получаем список отслеживаемых приложений
        runningProcesses = self.getRunningProcesses()  # Получаем список запущенных процессов

        # Проверяем, какие из отслеживаемых приложений запущены
        for app in trackedApps:
            exePath = app["exePath"]
            appName = app["name"]
            processName = app["processName"]

            # Проверяем, запущен ли процесс по пути (exePath) ИЛИ по имени (processName)
            if self.isProcessRunning(exePath, processName, runningProcesses):
                if exePath not in self.runningProcesses:
                    # Приложение запущено
                    self.runningProcesses[exePath] = QDateTime.currentDateTime()  # Сохраняем время начала
                    start_activity(appName, processName, exePath)  # Запускаем активность
                    print(f"Приложение {appName} запущено.")
            else:
                if exePath in self.runningProcesses:
                    # Приложение завершено
                    del self.runningProcesses[exePath]
                    end_activity(appName, processName, exePath)  # Завершаем активность
                    print(f"Приложение {appName} завершено.")

    def getRunningProcesses(self):
        """
        Возвращает список запущенных процессов с использованием psutil.
        """
        processes = []
        try:
            for proc in psutil.process_iter(['pid', 'name', 'exe']):
                try:
                    processInfo = proc.info
                    processes.append({
                        "pid": processInfo['pid'],
                        "name": processInfo['name'],
                        "exe": processInfo['exe']
                    })
                except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                    # Пропускаем процессы, к которым нет доступа
                    continue
        except Exception as e:
            print(f"Ошибка при получении списка процессов: {e}")

        return processes

    def isProcessRunning(self, exePath, processName, runningProcesses):
        """
        Проверяет, запущен ли процесс по пути (exePath) или по имени (processName).
        """
        for proc in runningProcesses:
            # Сравниваем по полному пути к исполняемому файлу
            if exePath and proc["exe"] and exePath.lower() == proc["exe"].lower():
                return True
            # Сравниваем по имени процесса
            if processName and proc["name"] and processName.lower() == proc["name"].lower():
                return True
        return False

    @pyqtSlot(result=int)
    def getRunningTrackedAppsCount(self):
        """
        Возвращает количество запущенных отслеживаемых приложений.
        """
        return len(self.runningProcesses)

    @pyqtSlot(result="QVariantList")
    def getIncompleteActivities(self):
        """
        Возвращает список незавершенных активностей с текущей длительностью.
        """
        incomplete_activities = []
        current_time = QDateTime.currentDateTime()

        for exePath, startTime in self.runningProcesses.items():
            # Находим приложение в списке отслеживаемых
            trackedApps = self.trackedAppsManager.getTrackedApps()
            for app in trackedApps:
                if app["exePath"] == exePath:
                    incomplete_activities.append({
                        "name": app["name"],
                        "exePath": exePath,
                        "start_time": startTime.toString(Qt.ISODate),  # Преобразуем время в строку
                        "current_duration": startTime.secsTo(current_time)  # Текущая длительность в секундах
                    })
                    break

        return incomplete_activities

    def cleanupOnExit(self):
        """
        Завершает все незавершенные активности перед закрытием приложения.
        """
        for exePath in list(self.runningProcesses.keys()):
            trackedApps = self.trackedAppsManager.getTrackedApps()
            for app in trackedApps:
                if app["exePath"] == exePath:
                    end_activity(app["name"], app["processName"], exePath)
                    print(f"Активность для {app['name']} завершена при закрытии приложения.")
                    break