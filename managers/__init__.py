# managers/__init__.py
from .opened_windows_manager import openedWindowsManager
from .tracked_apps_manager import trackedAppsManager
from .app_monitor_manager import appMonitorManager
from .stats_manager import statsManager
from .stat_cleaning_manager import statCleaningManager


__all__ = [
    "openedWindowsManager",
    "trackedAppsManager",
    "appMonitorManager",
    "statsManager",
    "statCleaningManager",
]