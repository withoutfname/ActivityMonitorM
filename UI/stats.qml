import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Item {
    property int totalDurationLast2Weeks: 0
    property int totalDurationLastMonth: 0
    property int totalDurationLastYear: 0
    property int totalDurationAllTime: 0
    property int totalDurationToday: 0// Новое свойство для статистики за всё время



    Rectangle {
        anchors.fill: parent
        color: "#121212"  // Темный фон (почти черный)


        ScrollView {
            anchors.fill: parent
            anchors.margins: 20
            clip: true


            ColumnLayout {
                Layout.fillWidth: true  // Занимаем всю доступную ширину
                spacing: 15
                anchors.margins: 20  // Внешние отступы

                // Кнопка "Обновить"
                Button {
                    text: "Обновить"
                    font.pixelSize: 16
                    Layout.alignment: Qt.AlignLeft
                    width: 100
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "#FFFFFF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: parent.down ? "#005BB5" : "#0078D7"
                        radius: 5
                        layer.enabled: true
                        layer.effect: DropShadow {
                            color: "#40000000"
                            radius: 5
                            samples: 10
                            verticalOffset: 2
                        }
                    }
                    onClicked: updateStats()
                }

                // Текущие активности
                Item {
                    id: currentActivitiesSection
                    Layout.fillWidth: true
                    Layout.preferredHeight: expanded ? 200 : 70
                    property bool expanded: true

                    // Тень для ячейки
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        radius: 10
                        layer.enabled: true
                        layer.effect: DropShadow {
                            color: "#40000000"
                            radius: 5
                            samples: 10
                            verticalOffset: 2
                        }
                    }

                    // Основная ячейка
                    Rectangle {
                        width: 800
                        height: parent.height
                        color: "#1E1E1E"
                        radius: 10
                        border.color: "#333333"

                        // Основной контент (заголовок и стрелочка)
                        RowLayout {
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                                margins: 15
                            }
                            height: 40

                            Text {
                                text: "Текущие активности:"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#E0E0E0"
                                Layout.fillWidth: true
                            }

                            Button {
                                width: 30
                                height: 30
                                text: currentActivitiesSection.expanded ? "▲" : "▼"
                                onClicked: currentActivitiesSection.expanded = !currentActivitiesSection.expanded
                                background: Rectangle {
                                    color: "transparent"
                                    border.color: "#333333"
                                    radius: 15
                                }
                                contentItem: Text {
                                    text: parent.text
                                    font.pixelSize: 14
                                    color: "#E0E0E0"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }

                        // Дополнительная информация (список активностей)
                        Flickable {
                            visible: currentActivitiesSection.expanded
                            width: parent.width
                            height: parent.height - 60
                            anchors.top: parent.top
                            anchors.topMargin: 60
                            anchors.left: parent.left
                            anchors.leftMargin: 15
                            anchors.right: parent.right
                            anchors.rightMargin: 15
                            clip: true
                            flickableDirection: Flickable.VerticalFlick  // Оставляем только вертикальный скролл

                            ListView {
                                width: parent.width
                                height: parent.height
                                model: ListModel { id: incompleteActivitiesModel }
                                delegate: Item {
                                    width: ListView.view.width
                                    height: 30

                                    Row {
                                        spacing: 10

                                        Text {
                                            text: name + " (начато: " + start_time + ", длительность: " + formatDuration(current_duration) + ")"
                                            font.pixelSize: 14
                                            color: "#E0E0E0"
                                            elide: Text.ElideRight  // Обрезаем текст, если он не помещается
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Анимация раскрытия
                    Behavior on height {
                        NumberAnimation { duration: 200 }
                    }
                }


                // Статистика за текущий день
                Item {
                    id: todaySection
                    Layout.fillWidth: true
                    Layout.preferredHeight: expanded ? 200 : 70
                    property bool expanded: true

                    // Тень для ячейки
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        radius: 10
                        layer.enabled: true
                        layer.effect: DropShadow {
                            color: "#40000000"
                            radius: 5
                            samples: 10
                            verticalOffset: 2
                        }
                    }

                    // Основная ячейка
                    Rectangle {
                        width: 800
                        height: parent.height
                        color: "#1E1E1E"
                        radius: 10
                        border.color: "#333333"

                        // Основной контент (заголовок и стрелочка)
                        RowLayout {
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                                margins: 15
                            }
                            height: 40

                            Text {
                                text: "Статистика за текущий день: " + formatDuration(totalDurationToday)
                                font.pixelSize: 16
                                font.bold: true
                                color: "#E0E0E0"
                                Layout.fillWidth: true
                            }

                            Button {
                                width: 30
                                height: 30
                                text: todaySection.expanded ? "▲" : "▼"
                                onClicked: todaySection.expanded = !todaySection.expanded
                                background: Rectangle {
                                    color: "transparent"
                                    border.color: "#333333"
                                    radius: 15
                                }
                                contentItem: Text {
                                    text: parent.text
                                    font.pixelSize: 14
                                    color: "#E0E0E0"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }

                        // Дополнительная информация (список приложений)
                        Flickable {
                            visible: todaySection.expanded
                            width: parent.width
                            height: parent.height - 60
                            anchors.top: parent.top
                            anchors.topMargin: 60
                            anchors.left: parent.left
                            anchors.leftMargin: 15
                            anchors.right: parent.right
                            anchors.rightMargin: 15
                            clip: true
                            flickableDirection: Flickable.VerticalFlick  // Оставляем только вертикальный скролл

                            ListView {
                                width: parent.width
                                height: parent.height
                                model: ListModel { id: statsTodayModel }
                                delegate: Item {
                                    width: ListView.view.width
                                    height: 30

                                    Row {
                                        spacing: 10

                                        Text {
                                            text: name
                                            font.pixelSize: 14
                                            color: "#E0E0E0"
                                            elide: Text.ElideRight  // Обрезаем текст, если он не помещается
                                        }

                                        Text {
                                            text: formatDuration(duration)
                                            font.pixelSize: 14
                                            color: "#E0E0E0"
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Анимация раскрытия
                    Behavior on height {
                        NumberAnimation { duration: 200 }
                    }
                }

                // Статистика за последние 2 недели
                Item {
                    id: last2WeeksSection
                    Layout.fillWidth: true
                    Layout.preferredHeight: expanded ? 400 : 70
                    property bool expanded: false

                    // Тень для ячейки
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        radius: 10
                        layer.enabled: true
                        layer.effect: DropShadow {
                            color: "#40000000"
                            radius: 5
                            samples: 10
                            verticalOffset: 2
                        }
                    }

                    // Основная ячейка
                    Rectangle {
                        width: 800
                        height: parent.height
                        color: "#1E1E1E"
                        radius: 10
                        border.color: "#333333"

                        // Основной контент (заголовок и стрелочка)
                        RowLayout {
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                                margins: 15
                            }
                            height: 40

                            Text {
                                text: "Статистика за последние 2 недели: " + formatDuration(totalDurationLast2Weeks)
                                font.pixelSize: 16
                                font.bold: true
                                color: "#E0E0E0"
                                Layout.fillWidth: true
                            }

                            Button {
                                width: 30
                                height: 30
                                text: last2WeeksSection.expanded ? "▲" : "▼"
                                onClicked: last2WeeksSection.expanded = !last2WeeksSection.expanded
                                background: Rectangle {
                                    color: "transparent"
                                    border.color: "#333333"
                                    radius: 15
                                }
                                contentItem: Text {
                                    text: parent.text
                                    font.pixelSize: 14
                                    color: "#E0E0E0"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }

                        // Дополнительная информация (список приложений)
                        Flickable {
                            visible: last2WeeksSection.expanded
                            width: parent.width
                            height: parent.height - 60
                            anchors.top: parent.top
                            anchors.topMargin: 60
                            anchors.left: parent.left
                            anchors.leftMargin: 15
                            anchors.right: parent.right
                            anchors.rightMargin: 15
                            clip: true
                            flickableDirection: Flickable.VerticalFlick  // Оставляем только вертикальный скролл

                            ListView {
                                width: parent.width
                                height: parent.height
                                model: ListModel { id: statsLast2WeeksModel }
                                delegate: Item {
                                    width: ListView.view.width
                                    height: 30

                                    Row {
                                        spacing: 10

                                        Text {
                                            text: name
                                            font.pixelSize: 14
                                            color: "#E0E0E0"
                                            elide: Text.ElideRight  // Обрезаем текст, если он не помещается
                                        }

                                        Text {
                                            text: formatDuration(duration)
                                            font.pixelSize: 14
                                            color: "#E0E0E0"
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Анимация раскрытия
                    Behavior on height {
                        NumberAnimation { duration: 200 }
                    }
                }

                // Статистика за последний месяц
                Item {
                    id: lastMonthSection
                    Layout.fillWidth: true
                    Layout.preferredHeight: expanded ? 400 : 70
                    property bool expanded: false

                    // Тень для ячейки
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        radius: 10
                        layer.enabled: true
                        layer.effect: DropShadow {
                            color: "#40000000"
                            radius: 5
                            samples: 10
                            verticalOffset: 2
                        }
                    }

                    // Основная ячейка
                    Rectangle {
                        width: 800
                        height: parent.height
                        color: "#1E1E1E"
                        radius: 10
                        border.color: "#333333"

                        // Основной контент (заголовок и стрелочка)
                        RowLayout {
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                                margins: 15
                            }
                            height: 40

                            Text {
                                text: "Статистика за последний месяц: " + formatDuration(totalDurationLastMonth)
                                font.pixelSize: 16
                                font.bold: true
                                color: "#E0E0E0"
                                Layout.fillWidth: true
                            }

                            Button {
                                width: 30
                                height: 30
                                text: lastMonthSection.expanded ? "▲" : "▼"
                                onClicked: lastMonthSection.expanded = !lastMonthSection.expanded
                                background: Rectangle {
                                    color: "transparent"
                                    border.color: "#333333"
                                    radius: 15
                                }
                                contentItem: Text {
                                    text: parent.text
                                    font.pixelSize: 14
                                    color: "#E0E0E0"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }

                        // Дополнительная информация (список приложений)
                        Flickable {
                            visible: lastMonthSection.expanded
                            width: parent.width
                            height: parent.height - 60
                            anchors.top: parent.top
                            anchors.topMargin: 60
                            anchors.left: parent.left
                            anchors.leftMargin: 15
                            anchors.right: parent.right
                            anchors.rightMargin: 15
                            clip: true
                            flickableDirection: Flickable.VerticalFlick  // Оставляем только вертикальный скролл

                            ListView {
                                width: parent.width
                                height: parent.height
                                model: ListModel { id: statsLastMonthModel }
                                delegate: Item {
                                    width: ListView.view.width
                                    height: 30

                                    Row {
                                        spacing: 10

                                        Text {
                                            text: name
                                            font.pixelSize: 14
                                            color: "#E0E0E0"
                                            elide: Text.ElideRight  // Обрезаем текст, если он не помещается
                                        }

                                        Text {
                                            text: formatDuration(duration)
                                            font.pixelSize: 14
                                            color: "#E0E0E0"
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Анимация раскрытия
                    Behavior on height {
                        NumberAnimation { duration: 200 }
                    }
                }

                // Статистика за последний год
                Item {
                    id: lastYearSection
                    Layout.fillWidth: true
                    Layout.preferredHeight: expanded ? 400 : 70
                    property bool expanded: false

                    // Тень для ячейки
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        radius: 10
                        layer.enabled: true
                        layer.effect: DropShadow {
                            color: "#40000000"
                            radius: 5
                            samples: 10
                            verticalOffset: 2
                        }
                    }

                    // Основная ячейка
                    Rectangle {
                        width: 800
                        height: parent.height
                        color: "#1E1E1E"
                        radius: 10
                        border.color: "#333333"

                        // Основной контент (заголовок и стрелочка)
                        RowLayout {
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                                margins: 15
                            }
                            height: 40

                            Text {
                                text: "Статистика за последний год: " + formatDuration(totalDurationLastYear)
                                font.pixelSize: 16
                                font.bold: true
                                color: "#E0E0E0"
                                Layout.fillWidth: true
                            }

                            Button {
                                width: 30
                                height: 30
                                text: lastYearSection.expanded ? "▲" : "▼"
                                onClicked: lastYearSection.expanded = !lastYearSection.expanded
                                background: Rectangle {
                                    color: "transparent"
                                    border.color: "#333333"
                                    radius: 15
                                }
                                contentItem: Text {
                                    text: parent.text
                                    font.pixelSize: 14
                                    color: "#E0E0E0"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }

                        // Дополнительная информация (список приложений)
                        Flickable {
                            visible: lastYearSection.expanded
                            width: parent.width
                            height: parent.height - 60
                            anchors.top: parent.top
                            anchors.topMargin: 60
                            anchors.left: parent.left
                            anchors.leftMargin: 15
                            anchors.right: parent.right
                            anchors.rightMargin: 15
                            clip: true
                            flickableDirection: Flickable.VerticalFlick  // Оставляем только вертикальный скролл

                            ListView {
                                width: parent.width
                                height: parent.height
                                model: ListModel { id: statsLastYearModel }
                                delegate: Item {
                                    width: ListView.view.width
                                    height: 30

                                    Row {
                                        spacing: 10

                                        Text {
                                            text: name
                                            font.pixelSize: 14
                                            color: "#E0E0E0"
                                            elide: Text.ElideRight  // Обрезаем текст, если он не помещается
                                        }

                                        Text {
                                            text: formatDuration(duration)
                                            font.pixelSize: 14
                                            color: "#E0E0E0"
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Анимация раскрытия
                    Behavior on height {
                        NumberAnimation { duration: 200 }
                    }
                }

                // Статистика за всё время
                Item {
                    id: allTimeSection
                    Layout.fillWidth: true
                    Layout.preferredHeight: expanded ? 400 : 70
                    property bool expanded: false

                    // Тень для ячейки
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        radius: 10
                        layer.enabled: true
                        layer.effect: DropShadow {
                            color: "#40000000"
                            radius: 5
                            samples: 10
                            verticalOffset: 2
                        }
                    }

                    // Основная ячейка
                    Rectangle {
                        width: 800
                        height: parent.height
                        color: "#1E1E1E"
                        radius: 10
                        border.color: "#333333"

                        // Основной контент (заголовок и стрелочка)
                        RowLayout {
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                                margins: 15
                            }
                            height: 40

                            Text {
                                text: "Статистика за всё время: " + formatDuration(totalDurationAllTime)
                                font.pixelSize: 16
                                font.bold: true
                                color: "#E0E0E0"
                                Layout.fillWidth: true
                            }

                            Button {
                                width: 30
                                height: 30
                                text: allTimeSection.expanded ? "▲" : "▼"
                                onClicked: allTimeSection.expanded = !allTimeSection.expanded
                                background: Rectangle {
                                    color: "transparent"
                                    border.color: "#333333"
                                    radius: 15
                                }
                                contentItem: Text {
                                    text: parent.text
                                    font.pixelSize: 14
                                    color: "#E0E0E0"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }

                        // Дополнительная информация (список приложений)
                        Flickable {
                            visible: allTimeSection.expanded
                            width: parent.width
                            height: parent.height - 60
                            anchors.top: parent.top
                            anchors.topMargin: 60
                            anchors.left: parent.left
                            anchors.leftMargin: 15
                            anchors.right: parent.right
                            anchors.rightMargin: 15
                            clip: true
                            flickableDirection: Flickable.VerticalFlick  // Оставляем только вертикальный скролл

                            ListView {
                                width: parent.width
                                height: parent.height
                                model: ListModel { id: statsAllTimeModel }
                                delegate: Item {
                                    width: ListView.view.width
                                    height: 30

                                    Row {
                                        spacing: 10

                                        Text {
                                            text: name
                                            font.pixelSize: 14
                                            color: "#E0E0E0"
                                            elide: Text.ElideRight  // Обрезаем текст, если он не помещается
                                        }

                                        Text {
                                            text: formatDuration(duration)
                                            font.pixelSize: 14
                                            color: "#E0E0E0"
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Анимация раскрытия
                    Behavior on height {
                        NumberAnimation { duration: 200 }
                    }
                }
            }
        }
    }

    // Функция для форматирования времени
    function formatDuration(duration) {
        const hours = Math.floor(duration / 3600);
        const minutes = Math.floor((duration % 3600) / 60);
        const seconds = duration % 60;
        return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    }

    // Инициализация данных при загрузке страницы
    Component.onCompleted: updateStats()

    // Функция для обновления статистики и текущих активностей
    function updateStats() {
        const statsToday = statsManager.getAppStatsToday();
        const statsLast2Weeks = statsManager.getAppStatsLast2Weeks();
        const statsLastMonth = statsManager.getAppStatsLastMonth();
        const statsLastYear = statsManager.getAppStatsLastYear();
        const statsAllTime = statsManager.getAppStatsAllTime();  // Получаем статистику за всё время

        totalDurationToday = statsToday.reduce((acc, stat) => acc + stat.totalDuration, 0);
        totalDurationLast2Weeks = statsLast2Weeks.reduce((acc, stat) => acc + stat.totalDuration, 0);
        totalDurationLastMonth = statsLastMonth.reduce((acc, stat) => acc + stat.totalDuration, 0);
        totalDurationLastYear = statsLastYear.reduce((acc, stat) => acc + stat.totalDuration, 0);
        totalDurationAllTime = statsAllTime.reduce((acc, stat) => acc + stat.totalDuration, 0);  // Общая длительность за всё время

        updateModel(statsTodayModel, statsToday);
        updateModel(statsLast2WeeksModel, statsLast2Weeks);
        updateModel(statsLastMonthModel, statsLastMonth);
        updateModel(statsLastYearModel, statsLastYear);
        updateModel(statsAllTimeModel, statsAllTime);  // Обновляем модель для статистики за всё время

        updateIncompleteActivities();
    }

    // Функция для обновления модели
    function updateModel(model, stats) {
        model.clear();
        stats.forEach(stat => model.append({ name: stat.name, duration: stat.totalDuration }));
    }

    function updateIncompleteActivities() {
        const incompleteActivities = statsManager.getIncompleteActivities();
        incompleteActivitiesModel.clear();
        incompleteActivities.forEach(activity => incompleteActivitiesModel.append({
            name: activity.name,  // Здесь уже будет алиас, если он задан
            start_time: activity.start_time,
            current_duration: activity.current_duration
        }));
    }
}