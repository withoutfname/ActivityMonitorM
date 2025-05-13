import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    Rectangle {
        anchors.fill: parent
        color: "#121212"  // Очень темный фон

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20

            // Заголовок
            Text {
                text: "Добро пожаловать!"
                font.pixelSize: 28
                font.bold: true
                color: "#E0E0E0"  // Светло-серый цвет текста
                Layout.alignment: Qt.AlignHCenter
            }

            // Карточка с количеством отслеживаемых приложений
            Rectangle {
                width: 300
                height: 100
                color: "#1E1E1E"  // Темный фон
                radius: 10  // Скругление углов
                border.color: "#333333"  // Темная граница
                Layout.alignment: Qt.AlignHCenter

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 10

                    // Иконка (просто текст для примера)
                    Text {
                        text: "📊"  // Эмодзи или можно заменить на изображение
                        font.pixelSize: 24
                        color: "#E0E0E0"  // Светло-серый цвет текста
                        Layout.alignment: Qt.AlignHCenter
                    }

                    // Количество отслеживаемых приложений
                    Text {
                        text: "Отслеживаемых приложений: " + (trackedAppsModel ? trackedAppsModel.count : 0)
                        font.pixelSize: 16
                        color: "#E0E0E0"  // Светло-серый цвет текста
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // Кнопка "Перейти к приложениям"
            Button {
                text: "Перейти к приложениям"
                font.pixelSize: 16
                Layout.alignment: Qt.AlignHCenter
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
                    // Переход на страницу с приложениями (например, config.qml)
                    contentLoader.source = "config.qml"
                }
            }
        }

    }
}