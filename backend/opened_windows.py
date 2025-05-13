import win32gui
import win32process
import psutil
from datetime import datetime

def get_opened_windows():
    """Получение списка всех видимых окон и связанных с ними процессов."""
    windows = []

    def callback(hwnd, _):
        if win32gui.IsWindowVisible(hwnd) and win32gui.IsWindowEnabled(hwnd):
            pid = win32process.GetWindowThreadProcessId(hwnd)[1]
            title = win32gui.GetWindowText(hwnd)
            if title:  # Учитываем только окна с заголовками
                try:
                    process = psutil.Process(pid)
                    process_name = process.name()
                    exe_path = process.exe()  # Путь к исполняемому файлу
                    create_time = datetime.fromtimestamp(process.create_time())  # Время запуска процесса
                    windows.append({
                        "title": title,
                        "processName": process_name,
                        "exePath": exe_path
                    })
                except (psutil.NoSuchProcess, psutil.AccessDenied):
                    pass

    win32gui.EnumWindows(callback, None)
    return windows