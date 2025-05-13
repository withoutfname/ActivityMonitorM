from PyQt5.QtCore import QAbstractListModel, Qt, QVariant

class statCleaningModel(QAbstractListModel):
    """
    Модель данных для отображения списка приложений с их алиасами и другими данными.
    """

    # Роли для доступа к данным
    AppIdRole = Qt.UserRole + 1
    NameRole = Qt.UserRole + 2
    ExePathRole = Qt.UserRole + 3
    ProcessNameRole = Qt.UserRole + 4
    AliasRole = Qt.UserRole + 5

    def __init__(self, parent=None):
        super().__init__(parent)
        self._data = []  # Список данных для отображения

    def rowCount(self, parent=None):
        """
        Возвращает количество строк в модели.
        """
        return len(self._data)

    def data(self, index, role=Qt.DisplayRole):
        """
        Возвращает данные для указанной роли и индекса.
        """
        if not index.isValid() or index.row() >= len(self._data):
            return QVariant()

        app_data = self._data[index.row()]

        if role == self.AppIdRole:
            return app_data.get("id", QVariant())
        elif role == self.NameRole:
            return app_data.get("name", QVariant())
        elif role == self.ExePathRole:
            return app_data.get("exePath", QVariant())
        elif role == self.ProcessNameRole:
            return app_data.get("processName", QVariant())
        elif role == self.AliasRole:
            return app_data.get("alias", QVariant())

        return QVariant()

    def roleNames(self):
        return {
            self.AppIdRole: b"app_id",
            self.NameRole: b"name",
            self.ExePathRole: b"exePath",
            self.ProcessNameRole: b"processName",
            self.AliasRole: b"alias",
        }

    def updateData(self, new_data):
        """
        Обновляет данные модели.
        :param new_data: Список словарей с данными приложений.
        """
        self.beginResetModel()
        self._data = new_data
        self.endResetModel()

    def getAppId(self, index):
        """
        Возвращает app_id для указанного индекса.
        :param index: Индекс строки.
        :return: app_id или None, если индекс недействителен.
        """
        if index.isValid() and index.row() < len(self._data):
            return self._data[index.row()].get("id")
        return None