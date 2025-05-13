from PyQt5.QtCore import QAbstractListModel, Qt, QModelIndex, QVariant, pyqtSlot


class openedWindowsModel(QAbstractListModel):
    def __init__(self, windows=None):
        super().__init__()
        self.windows = windows or []
        self.filtered_windows = self.windows  # Изначально отображаем все окна
        self._filter_text = ""  # Текущий текст фильтра

    def rowCount(self, parent=QModelIndex()):
        return len(self.filtered_windows)

    def data(self, index, role):
        if not index.isValid():
            return QVariant()

        window = self.filtered_windows[index.row()]

        if role == Qt.DisplayRole:
            return window["title"]
        elif role == Qt.UserRole:
            return window["processName"]
        elif role == Qt.UserRole + 1:
            return window["exePath"]
        return QVariant()

    def roleNames(self):
        return {
            Qt.DisplayRole: b"title",
            Qt.UserRole: b"processName",
            Qt.UserRole + 1: b"exePath",
        }

    def updateData(self, new_windows):
        """Обновляет данные модели и применяет фильтр."""
        self.beginResetModel()
        self.windows = new_windows
        self._applyFilter()  # Применяем фильтр после обновления данных
        self.endResetModel()

    @pyqtSlot(str)
    def filter(self, text):
        """Фильтрация списка окон по тексту (название, процесс, путь)."""
        self._filter_text = text.lower()  # Приводим текст к нижнему регистру
        self._applyFilter()

    def _applyFilter(self):
        """Применяет текущий фильтр к списку окон."""
        self.beginResetModel()
        if self._filter_text:
            # Фильтруем по названию, процессу и пути
            self.filtered_windows = [
                window for window in self.windows
                if (self._filter_text in window["title"].lower() or
                    self._filter_text in window["processName"].lower() or
                    self._filter_text in window["exePath"].lower())
            ]
        else:
            self.filtered_windows = self.windows  # Если фильтр пуст, показываем все окна
        self.endResetModel()