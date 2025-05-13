from PyQt5.QtCore import QObject, pyqtSlot, pyqtSignal
from backend.database import remove_tracked_apps_db

class deleteManager(QObject):
    def __init__(self):
        super().__init__()


