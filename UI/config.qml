import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    Rectangle {
        anchors.fill: parent
        color: "#121212"  // Темный фон (почти черный)

        ColumnLayout {
            anchors.fill: parent
            spacing: 20
            anchors.margins: 20

            // Кнопки навигации
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10

                Button {
                    text: "Просмотр"
                    font.pixelSize: 16
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "#FFFFFF"  // Белый цвет текста (остается, так как кнопка цветная)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: parent.down ? "#005BB5" : "#0078D7"  // Синий цвет кнопки
                        radius: 5  // Скругление углов
                    }
                    onClicked: {
                        contentLoader.source = "viewPage.qml"
                    }
                }

                Button {
                    text: "Добавить"
                    font.pixelSize: 16
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "#FFFFFF"  // Белый цвет текста
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: parent.down ? "#005BB5" : "#0078D7"  // Синий цвет кнопки
                        radius: 5  // Скругление углов
                    }
                    onClicked: {
                        contentLoader.source = "runningAppsPage.qml"
                    }
                }

                Button {
                    text: "Удалить"
                    font.pixelSize: 16
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "#FFFFFF"  // Белый цвет текста
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: parent.down ? "#005BB5" : "#0078D7"  // Синий цвет кнопки
                        radius: 5  // Скругление углов
                    }
                    onClicked: {
                        contentLoader.source = "deletePage.qml"
                    }
                }

                Button {
                    text: "Очистить статитиску"
                    font.pixelSize: 16
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "#FFFFFF"  // Белый цвет текста
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: parent.down ? "#005BB5" : "#0078D7"  // Синий цвет кнопки
                        radius: 5  // Скругление углов
                    }
                    onClicked: {
                        contentLoader.source = "statCleaningPage.qml"
                    }
                }

                Button {
                    text: "Полное удаление"
                    font.pixelSize: 16
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "#FFFFFF"  // Белый цвет текста
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: parent.down ? "#005BB5" : "#0078D7"  // Синий цвет кнопки
                        radius: 5  // Скругление углов
                    }
                    onClicked: {
                        contentLoader.source = "fullCleaningPage.qml"
                    }
                }
            }

            // Загрузчик для страниц
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#1E1E1E"  // Темный фон для области загрузки
                radius: 10  // Скругление углов

                Loader {
                    id: contentLoader
                    anchors.fill: parent
                    anchors.margins: 10
                    source: "viewPage.qml"  // Начальная страница
                }
            }
        }
    }
}