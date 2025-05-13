from PyQt5.QtCore import QObject, pyqtSlot, pyqtSignal
from backend.database import (
    get_app_stats_last_2_weeks,
    get_app_stats_last_month,
    get_app_stats_last_year,
    get_app_stats_all_time,
    get_incomplete_activities, get_app_stats_today,
)

class statsManager(QObject):
    statsUpdated = pyqtSignal()

    def __init__(self):
        super().__init__()

    @pyqtSlot(result="QVariantList")
    def getAppStatsLast2Weeks(self):
        """
        Возвращает статистику по приложениям за последние 2 недели.
        """
        return get_app_stats_last_2_weeks()

    @pyqtSlot(result="QVariantList")
    def getAppStatsLastMonth(self):
        """
        Возвращает статистику по приложениям за последний месяц.
        """
        return get_app_stats_last_month()

    @pyqtSlot(result="QVariantList")
    def getAppStatsLastYear(self):
        """
        Возвращает статистику по приложениям за последний год.
        """
        return get_app_stats_last_year()

    @pyqtSlot(result="QVariantList")
    def getAppStatsAllTime(self):
        """
        Возвращает статистику по приложениям за всё время.
        """
        return get_app_stats_all_time()

    @pyqtSlot(result="QVariantList")
    def getAppStatsToday(self):
        """
        Возвращает статистику по приложениям за всё время.
        """
        return get_app_stats_today()


    @pyqtSlot(result="QVariantList")
    def getIncompleteActivities(self):
        """
        Возвращает список незавершенных активностей.
        """
        return get_incomplete_activities()


