from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot
from backend.database import get_all_aliases, delete_activity_history_by_app_id, clean_full_app_history_by_app_id
from models import statCleaningModel


class statCleaningManager(QObject):
    def __init__(self):
        super().__init__()
        self._aliases = []  # Список алиасов
        self._model = statCleaningModel()  # Создаем экземпляр модели

    # Сигнал для обновления списка алиасов
    aliasesUpdated = pyqtSignal()

    @pyqtSlot(result="QVariantList")
    def getAliases(self):
        """
        Возвращает список алиасов.
        """
        return self._aliases

    @pyqtSlot(result=statCleaningModel)
    def getModel(self):
        """
        Возвращает модель данных.
        """
        return self._model

    @pyqtSlot()
    def updateAliases(self):
        """
        Обновляет список алиасов из базы данных.
        """
        self._aliases = get_all_aliases()  # Получаем все алиасы
        self._model.updateData(self._aliases)  # Обновляем данные модели
        self.aliasesUpdated.emit()  # Уведомляем об обновлении

    @pyqtSlot(list)
    def deleteActivityHistoryForApps(self, app_ids):
        """
        Удаляет историю активности для выбранных приложений.
        :param app_ids: Список идентификаторов приложений, для которых нужно удалить историю.
        """
        for app_id in app_ids:
            delete_activity_history_by_app_id(app_id)  # Удаляем историю по app_id
        self.updateAliases()  # Обновляем список алиасов

    @pyqtSlot(list)
    def deleteFullAppHistoryForApps(self, app_ids):
        """
        Удаляет все записи, связанные с указанными app_id.
        :param app_ids: Список идентификаторов приложений.
        """
        for app_id in app_ids:
            clean_full_app_history_by_app_id(app_id)  # Удаляем данные по app_id
        self.updateAliases()  # Обновляем список алиасов

