from functools import wraps
import psycopg2
'''
def get_db_connection():
    """
    Возвращает соединение с базой данных.
    """
    return psycopg2.connect(
        dsn="postgresql://neondb_owner:npg_VPAK5HeQXYy9@ep-royal-waterfall-a2xk5e0o-pooler.eu-central-1.aws.neon.tech/activitydb?sslmode=require"
    )
    
  
    
    
'''

def get_db_connection():
    """
    Возвращает соединение с базой данных.
    """
    return psycopg2.connect(
        dbname="activitydb",  # Название вашей базы данных
        user="postgres",  # Пользователь PostgreSQL
        password="pass",  # Ваш пароль
        host="localhost",  # Хост (локально)
        port="5432"  # Порт по умолчанию
    )


def create_tables():
    """
    Создает таблицы в базе данных, если они не существуют.
    """
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                # Создаем таблицу apps
                cursor.execute("""
                    CREATE TABLE IF NOT EXISTS apps (
                        id SERIAL PRIMARY KEY,
                        name VARCHAR(255) NOT NULL,
                        exe_path VARCHAR(255),
                        process_name VARCHAR(255),
                        alias VARCHAR(255) NOT NULL
                    );
                """)

                # Создаем таблицу tracked_apps
                cursor.execute("""
                    CREATE TABLE IF NOT EXISTS tracked_apps (
                        id SERIAL PRIMARY KEY,
                        app_id INTEGER NOT NULL,
                        FOREIGN KEY (app_id) REFERENCES apps(id)
                    );
                """)

                # Создаем таблицу activity_sessions
                cursor.execute("""
                    CREATE TABLE IF NOT EXISTS activity_sessions (
                        id SERIAL PRIMARY KEY,
                        app_id INTEGER NOT NULL,
                        start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        end_time TIMESTAMP,
                        is_tracking BOOLEAN DEFAULT TRUE,
                        FOREIGN KEY (app_id) REFERENCES apps(id)
                    );
                """)

    except Exception as e:
        print("Ошибка при создании таблиц:", e)


def ensure_tables_exist(func):
    """
    Декоратор, который гарантирует, что таблицы существуют перед выполнением функции.
    """
    @wraps(func)
    def wrapper(*args, **kwargs):
        create_tables()  # Создаем таблицы, если их нет
        return func(*args, **kwargs)  # Выполняем основную функцию
    return wrapper


@ensure_tables_exist
def save_tracked_apps_db(apps):
    """
    Сохраняет приложения в таблицу apps и добавляет их в tracked_apps, если их там еще нет.
    Принимает массив объектов, где каждый объект содержит:
    - title (название приложения)
    - processName (название процесса)
    - exePath (путь к исполняемому файлу)
    """
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                for app in apps:
                    # Проверяем, существует ли запись в таблице apps
                    cursor.execute("""
                        SELECT id FROM apps
                        WHERE name = %s AND exe_path = %s AND process_name = %s
                    """, (app["title"], app["exePath"], app["processName"]))

                    existing_record = cursor.fetchone()

                    if existing_record:
                        app_id = existing_record[0]
                    else:
                        # Вставляем данные в таблицу apps
                        cursor.execute("""
                            INSERT INTO apps (name, exe_path, process_name, alias)
                            VALUES (%s, %s, %s, %s)
                            RETURNING id
                        """, (app["title"], app["exePath"], app["processName"], app["title"]))

                        app_id = cursor.fetchone()[0]

                    # Проверяем, существует ли запись в таблице tracked_apps
                    cursor.execute("""
                        SELECT id FROM tracked_apps
                        WHERE app_id = %s
                    """, (app_id,))

                    existing_tracked_record = cursor.fetchone()

                    if not existing_tracked_record:
                        # Вставляем данные в таблицу tracked_apps, если их там еще нет
                        cursor.execute("""
                            INSERT INTO tracked_apps (app_id)
                            VALUES (%s)
                        """, (app_id,))

                # Сохраняем изменения
                conn.commit()

    except Exception as e:
        print(f"Ошибка при добавлении данных в таблицу: {e}")


@ensure_tables_exist
def get_apps_from_tracked_apps_db():
    """
    Возвращает список приложений из таблицы tracked_apps.
    Каждый элемент списка — это словарь с ключами:
    - name (название приложения)
    - exePath (путь к исполняемому файлу)
    - processName (название процесса)
    - alias (псевдоним, если есть)
    """
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                # Выполнение запроса
                cursor.execute("""
                    SELECT
                        a.name,
                        a.exe_path,
                        a.process_name,
                        a.alias
                    FROM tracked_apps t
                    JOIN apps a ON t.app_id = a.id
                """)

                # Получение данных
                rows = cursor.fetchall()

                # Преобразование данных в список словарей
                apps = [
                    {
                        "name": row[0],
                        "exePath": row[1],
                        "processName": row[2],
                        "alias": row[3]  # Добавляем alias
                    }
                    for row in rows
                ]
                return apps
    except Exception as e:
        print(f"Ошибка при получении данных из базы данных: {e}")
        return []


@ensure_tables_exist
def remove_tracked_apps_db(apps):
    """
    Удаляет приложения из таблицы tracked_apps по имени, пути и названию процесса.
    Принимает массив объектов, где каждый объект содержит:
    - title (название приложения)
    - processName (название процесса)
    - exePath (путь к исполняемому файлу)
    """
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                for app in apps:
                    # Получаем app_id из таблицы apps
                    cursor.execute("""
                        SELECT id FROM apps
                        WHERE name = %s AND exe_path = %s AND process_name = %s
                    """, (app["title"], app["exePath"], app["processName"]))

                    app_id = cursor.fetchone()

                    if app_id:
                        # Удаляем данные из таблицы tracked_apps
                        cursor.execute("""
                            DELETE FROM tracked_apps
                            WHERE app_id = %s
                        """, (app_id[0],))

                # Сохранение изменений
                conn.commit()

    except Exception as e:
        print(f"Ошибка при удалении данных из таблицы: {e}")


@ensure_tables_exist
def start_activity(app_name, process_name, exe_path):
    """
    Запускает новую активность для приложения.
    Заполняет start_time и устанавливает is_tracking в TRUE.
    """
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                # Получаем app_id из таблицы apps
                cursor.execute("""
                    SELECT id FROM apps
                    WHERE name = %s AND exe_path = %s AND process_name = %s
                """, (app_name, exe_path, process_name))

                app_id = cursor.fetchone()

                if app_id:
                    # Вставляем данные в таблицу activity_sessions
                    cursor.execute("""
                        INSERT INTO activity_sessions (app_id, start_time, is_tracking)
                        VALUES (%s, CURRENT_TIMESTAMP, TRUE)
                    """, (app_id[0],))

                    # Сохранение изменений
                    conn.commit()

                else:
                    print(f"Приложение {app_name} не найдено в базе данных.")

    except Exception as e:
        print(f"Ошибка при старте активности: {e}")


@ensure_tables_exist
def end_activity(app_name, process_name, exe_path):
    """
    Завершает активность для приложения.
    Заполняет end_time и устанавливает is_tracking в FALSE.
    """
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                # Получаем app_id из таблицы apps
                cursor.execute("""
                    SELECT id FROM apps
                    WHERE name = %s AND exe_path = %s AND process_name = %s
                """, (app_name, exe_path, process_name))

                app_id = cursor.fetchone()

                if app_id:
                    # Обновляем данные в таблице activity_sessions
                    cursor.execute("""
                        UPDATE activity_sessions
                        SET end_time = CURRENT_TIMESTAMP, is_tracking = FALSE
                        WHERE app_id = %s AND is_tracking = TRUE
                    """, (app_id[0],))

                    # Сохранение изменений
                    conn.commit()

                else:
                    print(f"Приложение {app_name} не найдено в базе данных.")

    except Exception as e:
        print(f"Ошибка при завершении активности: {e}")


@ensure_tables_exist
def cleanup_incomplete_activities():
    """
    Завершает все активности, которые не были завершены (is_tracking = TRUE).
    """
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("""
                    UPDATE activity_sessions
                    SET end_time = CURRENT_TIMESTAMP, is_tracking = FALSE
                    WHERE is_tracking = TRUE
                """)

                # Сохранение изменений
                conn.commit()


    except Exception as e:
        print(f"Ошибка при очистке незавершенных активностей: {e}")



@ensure_tables_exist
def get_app_stats():
    """
    Возвращает статистику по приложениям из таблицы activity_sessions.
    Вычисляет длительность как разницу между end_time и start_time.
    """
    stats = []
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("""
                    SELECT
                        a.name,
                        a.exe_path,
                        SUM(EXTRACT(EPOCH FROM (s.end_time - s.start_time))) as total_duration
                    FROM activity_sessions s
                    JOIN apps a ON s.app_id = a.id
                    WHERE s.end_time IS NOT NULL  -- Исключаем незавершенные сессии
                    GROUP BY a.name, a.exe_path
                """)
                rows = cursor.fetchall()

                # Преобразуем данные в список словарей
                for row in rows:
                    stats.append({
                        "name": row[0],
                        "exePath": row[1],
                        "totalDuration": int(row[2])  # Преобразуем в целое число (секунды)
                    })
    except Exception as e:
        print(f"Ошибка при получении статистики: {e}")

    return stats


@ensure_tables_exist
def get_incomplete_activities():
    """
    Возвращает список незавершенных активностей (где end_time IS NULL).
    Каждый элемент списка — это словарь с ключами:
    - name (название приложения или алиас, если он есть)
    - start_time (время начала отслеживания)
    - current_duration (текущая длительность активности в секундах)
    """
    incomplete_activities = []
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("""
                    SELECT
                        a.alias as name,  -- Используем алиас, если он есть
                        s.start_time,
                        EXTRACT(EPOCH FROM (NOW() - s.start_time)) as current_duration
                    FROM activity_sessions s
                    JOIN apps a ON s.app_id = a.id
                    WHERE s.end_time IS NULL
                """)
                rows = cursor.fetchall()

                # Преобразуем данные в список словарей
                for row in rows:
                    incomplete_activities.append({
                        "name": row[0],  # Используем алиас
                        "start_time": row[1].isoformat(),  # Преобразуем время в строку
                        "current_duration": int(row[2])  # Текущая длительность в секундах
                    })
    except Exception as e:
        print(f"Ошибка при получении незавершенных активностей: {e}")

    return incomplete_activities


@ensure_tables_exist
def delete_incomplete_activities():
    """
    Удаляет все незавершенные активности (где end_time IS NULL).
    """
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("""
                    DELETE FROM activity_sessions
                    WHERE end_time IS NULL
                """)

                # Сохранение изменений
                conn.commit()


    except Exception as e:
        print(f"Ошибка при удалении незавершенных активностей: {e}")



def get_app_stats_by_interval(interval):
    """
    Возвращает статистику по приложениям за указанный интервал времени.
    :param interval: Интервал времени (например, '2 weeks', '1 month', '1 year').
    :return: Список словарей с статистикой.
    """
    stats = []
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("""
                    SELECT
                        COALESCE(a.alias, a.name) as name,
                        a.exe_path,
                        SUM(EXTRACT(EPOCH FROM (s.end_time - s.start_time))) as total_duration
                    FROM activity_sessions s
                    JOIN apps a ON s.app_id = a.id
                    WHERE s.end_time IS NOT NULL
                      AND s.start_time >= NOW() - INTERVAL %s
                    GROUP BY a.alias, a.name, a.exe_path
                    ORDER BY total_duration DESC
                """, (interval,))
                rows = cursor.fetchall()

                for row in rows:
                    stats.append({
                        "name": row[0],
                        "exePath": row[1],
                        "totalDuration": int(row[2])
                    })
    except Exception as e:
        print(f"Ошибка при получении статистики за интервал {interval}: {e}")

    return stats

@ensure_tables_exist
def get_app_stats_last_2_weeks():
    """
    Возвращает статистику по приложениям за последние 2 недели.
    """
    return get_app_stats_by_interval('2 weeks')

@ensure_tables_exist
def get_app_stats_last_month():
    """
    Возвращает статистику по приложениям за последний месяц.
    """
    return get_app_stats_by_interval('1 month')

@ensure_tables_exist
def get_app_stats_last_year():
    """
    Возвращает статистику по приложениям за последний год.
    """
    return get_app_stats_by_interval('1 year')


@ensure_tables_exist
def get_app_stats_today():
    """
    Возвращает статистику по приложениям за текущий день.
    :return: Список словарей с информацией о приложениях.
    """
    stats = []
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                # Получаем статистику по алиасам
                cursor.execute("""
                    SELECT
                        COALESCE(a.alias, a.name) as name,
                        a.exe_path,
                        SUM(EXTRACT(EPOCH FROM (s.end_time - s.start_time))) as total_duration
                    FROM activity_sessions s
                    JOIN apps a ON s.app_id = a.id
                    WHERE s.end_time IS NOT NULL
                      AND s.start_time >= CURRENT_DATE  -- Фильтр по текущему дню
                      AND s.start_time < CURRENT_DATE + INTERVAL '1 day'  -- Верхняя граница дня
                    GROUP BY a.alias, a.name, a.exe_path
                    ORDER BY total_duration DESC
                """)
                rows = cursor.fetchall()

                # Заполняем статистику по алиасам
                for row in rows:
                    stats.append({
                        "name": row[0],
                        "exePath": row[1],
                        "totalDuration": int(row[2])
                    })

    except Exception as e:
        print(f"Ошибка при получении статистики за текущий день: {e}")

    return stats


@ensure_tables_exist
def get_app_stats_all_time():
    """
    Возвращает статистику по приложениям за всё время, отсортированную по убыванию длительности.
    """
    stats = []
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("""
                    SELECT
                        a.alias as name,  -- Используем алиас, если он есть
                        a.exe_path,
                        SUM(EXTRACT(EPOCH FROM (s.end_time - s.start_time))) as total_duration
                    FROM activity_sessions s
                    JOIN apps a ON s.app_id = a.id
                    WHERE s.end_time IS NOT NULL  -- Исключаем незавершенные сессии
                    GROUP BY a.alias, a.exe_path
                    ORDER BY total_duration DESC  -- Сортировка по убыванию
                """)
                rows = cursor.fetchall()

                for row in rows:
                    stats.append({
                        "name": row[0],
                        "exePath": row[1],
                        "totalDuration": int(row[2])
                    })
    except Exception as e:
        print(f"Ошибка при получении статистики за всё время: {e}")

    return stats



@ensure_tables_exist
def add_or_update_alias(name, process_name, exe_path, alias):
    """
    Обновляет псевдоним для приложения.
    Если запись с таким name, process_name и exe_path не существует, выбрасывает исключение.
    """
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                # Проверяем, существует ли запись в таблице apps
                cursor.execute("""
                    SELECT id FROM apps
                    WHERE name = %s AND exe_path = %s AND process_name = %s
                """, (name, exe_path, process_name))

                existing_record = cursor.fetchone()

                if existing_record:
                    app_id = existing_record[0]
                    # Если запись существует, обновляем alias
                    cursor.execute("""
                        UPDATE apps
                        SET alias = %s
                        WHERE id = %s
                    """, (alias, app_id))
                    conn.commit()
                    print(f"Псевдоним '{alias}' обновлен для приложения '{name}'.")
                else:
                    # Если записи нет, выбрасываем исключение
                    raise ValueError(f"Запись для приложения '{name}' не найдена в таблице apps.")

    except Exception as e:
        print(f"Ошибка при обновлении псевдонима: {e}")
        raise  # Пробрасываем исключение дальше, чтобы обработать его в вызывающем коде

@ensure_tables_exist
def get_all_aliases():
    """
    Возвращает все записи из таблицы apps, включая псевдонимы.
    """
    aliases = []
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("""
                    SELECT id, name, exe_path, process_name, alias
                    FROM apps
                """)
                rows = cursor.fetchall()

                for row in rows:
                    aliases.append({
                        "id": row[0],
                        "name": row[1],
                        "exePath": row[2],
                        "processName": row[3],
                        "alias": row[4]
                    })
    except Exception as e:
        print(f"Ошибка при получении всех псевдонимов: {e}")
    return aliases


@ensure_tables_exist
def delete_activity_history_by_app_id(app_id):
    """
    Удаляет всю историю отслеживания из таблицы activity_sessions, связанную с указанным app_id.
    :param app_id: Идентификатор приложения, для которого нужно удалить историю.
    """
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                # Удаляем записи из таблицы activity_sessions, где app_id совпадает с переданным значением
                cursor.execute("""
                    DELETE FROM activity_sessions
                    WHERE app_id = %s
                """, (app_id,))

                # Сохраняем изменения
                conn.commit()
                print(f"История отслеживания для приложения с app_id '{app_id}' удалена.")

    except Exception as e:
        print(f"Ошибка при удалении истории отслеживания: {e}")


@ensure_tables_exist
def clean_full_app_history_by_app_id(app_id):
    """
    Удаляет все записи из таблиц tracked_apps, activity_sessions и apps, связанные с указанным app_id.
    :param app_id: Идентификатор приложения, для которого нужно удалить записи.
    """
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                # Удаляем записи из таблицы tracked_apps
                cursor.execute("""
                    DELETE FROM tracked_apps
                    WHERE app_id = %s
                """, (app_id,))

                # Удаляем записи из таблицы activity_sessions
                cursor.execute("""
                    DELETE FROM activity_sessions
                    WHERE app_id = %s
                """, (app_id,))

                # Удаляем записи из таблицы apps
                cursor.execute("""
                    DELETE FROM apps
                    WHERE id = %s
                """, (app_id,))

                # Сохраняем изменения
                conn.commit()
                print(f"Все записи для приложения с app_id '{app_id}' удалены из всех таблиц.")

    except Exception as e:
        print(f"Ошибка при удалении записей: {e}")





