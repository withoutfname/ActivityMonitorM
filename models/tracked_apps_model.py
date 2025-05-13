# models/tracked_apps_model.py
from PyQt5.QtCore import QAbstractListModel, Qt, QModelIndex, pyqtProperty, pyqtSignal


class trackedAppsModel(QAbstractListModel):
    # Сигнал для уведомления об изменении данных
    trackedAppsChanged = pyqtSignal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._trackedApps = []  # Массив для хранения отслеживаемых приложений

    # Свойство count для QML
    @pyqtProperty(int, notify=trackedAppsChanged)
    def count(self):
        """
        Возвращает количество элементов в модели.
        """
        return len(self._trackedApps)

    def rowCount(self, parent=QModelIndex()):
        """
        Возвращает количество элементов в модели.
        """
        return len(self._trackedApps)

    def data(self, index, role=Qt.DisplayRole):
        """
        Возвращает данные для указанного индекса и роли.
        """
        if not index.isValid() or index.row() >= len(self._trackedApps):
            return None

        app = self._trackedApps[index.row()]

        if role == Qt.DisplayRole:
            return app["name"]  # Возвращаем имя приложения для отображения
        elif role == Qt.UserRole + 1:
            return app["exePath"]  # Возвращаем путь к исполняемому файлу
        elif role == Qt.UserRole + 2:
            return app["processName"]  # Возвращаем название процесса
        elif role == Qt.UserRole + 3:
            return app.get("alias", app["name"])  # Возвращаем псевдоним, если он есть, иначе имя
        return None

    def roleNames(self):
        """
        Возвращает роли, которые поддерживает модель.
        """
        roles = {
            Qt.DisplayRole: b"name",  # Роль для отображения имени
            Qt.UserRole + 1: b"exePath",  # Роль для пути к исполняемому файлу
            Qt.UserRole + 2: b"processName",  # Роль для названия процесса
            Qt.UserRole + 3: b"alias"  # Роль для псевдонима
        }
        return roles

    def updateData(self, trackedApps):
        """
        Обновляет данные модели.
        """
        self.beginResetModel()
        self._trackedApps = trackedApps
        self.endResetModel()
        self.trackedAppsChanged.emit()  # Уведомляем об изменении данных

    def getTrackedApps(self):
        """
        Возвращает список отслеживаемых приложений.
        """
        return self._trackedApps