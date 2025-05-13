import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    property var selectedAppsToRemove: [] // Массив для хранения выбранных приложений

    Rectangle {
        anchors.fill: parent
        color: "#121212"  // Темный фон (почти черный)

        Label {
            id: emptyListMessage
            anchors.centerIn: parent
            text: "Нет отслеживаемых приложений"
            font.pixelSize: 20
            color: "#E0E0E0"  // Светло-серый цвет текста
            visible: trackedAppsModel ? trackedAppsModel.count === 0 : true // Проверка на null
        }

        // Кнопка "Удалить"
        Button {
            visible: trackedAppsModel ? trackedAppsModel.count !== 0 : true // Проверка на null
            id: deleteButton
            anchors {
                top: parent.top
                right: parent.right
                margins: 10
            }
            text: "Удалить"

            // Стилизация кнопки
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
                if (selectedAppsToRemove.length === 0) {
                    messageDialog.open();
                } else {
                    // Удаляем выбранные приложения из базы данных
                    trackedAppsManager.removeAppsFromDatabase(selectedAppsToRemove);
                    selectedAppsToRemove = []; // Очищаем массив
                    trackedAppsManager.updateTrackedApps(); // Обновляем список приложений
                }
            }
        }

        // Список отслеживаемых приложений
        ListView {
            id: listView
            anchors {
                top: deleteButton.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 10
            }
            model: trackedAppsModel // Используем trackedAppsModel
            spacing: 5 // Отступ между элементами

            delegate: Item {
                width: ListView.view.width // Используем ширину ListView
                height: 50

                Rectangle {
                    width: parent.width
                    height: 50
                    color: "#1E1E1E"  // Темный фон ячейки
                    border.color: "#333333"  // Темно-серая граница
                    radius: 5

                    Row {
                        anchors.fill: parent
                        spacing: 10
                        leftPadding: 10

                        // Чекбокс для выбора приложения
                        CheckBox {
                            id: checkBox
                            anchors.verticalCenter: parent.verticalCenter

                            // Устанавливаем начальное состояние чекбокса
                            Component.onCompleted: {
                                checkBox.checked = selectedAppsToRemove.some(app => app.processName === model.processName);
                            }

                            onCheckedChanged: {
                                if (checked) {
                                    // Добавляем приложение в массив, если чекбокс отмечен
                                    selectedAppsToRemove.push({
                                        title: model.name,
                                        exePath: model.exePath,
                                        processName: model.processName
                                    });
                                } else {
                                    // Удаляем приложение из массива, если чекбокс снят
                                    selectedAppsToRemove = selectedAppsToRemove.filter(app => app.processName !== model.processName);
                                }
                            }
                        }

                        // Название приложения и путь
                        Text {
                            text: model.name + " - " + model.exePath
                            font.pixelSize: 14
                            color: "#E0E0E0"  // Светло-серый цвет текста
                            elide: Text.ElideRight
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }

    // Диалог для отображения ошибок
    Dialog {
        id: messageDialog
        title: "Ошибка"
        standardButtons: Dialog.Ok
        width: 300
        height: 200
        contentItem: Text {
            text: "Выберите хотя бы одно приложение"
            wrapMode: Text.WordWrap
            font.pixelSize: 14
            color: "#E0E0E0"  // Светло-серый цвет текста
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            color: "#1E1E1E"  // Темный фон диалога
            radius: 5  // Скругление углов
        }

        onAccepted: {
            messageDialog.close();
        }
    }

    // Автоматическое обновление списка при загрузке страницы
    Component.onCompleted: {
        selectedAppsToRemove = [];
        if (trackedAppsManager) {
            trackedAppsManager.updateTrackedApps(); // Обновляем список приложений
        }
    }
}
