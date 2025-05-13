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
            visible: listView.count === 0 // Показываем, если в списке нет элементов
        }

        // Кнопка "Удалить"
        Button {
            id: deleteButton
            visible: listView.count !== 0  // Показываем, если в списке нет элементов
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
                    var app_ids = selectedAppsToRemove.map(app => app.app_id); // Получаем массив app_id
                    statCleaningManager.deleteActivityHistoryForApps(app_ids); // Передаем массив app_id
                    selectedAppsToRemove = []; // Очищаем массив
                    statCleaningManager.updateAliases();
                }
            }


        }

        ListView {
            id: listView
            anchors {
                top: deleteButton.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 10
            }
            model: statCleaningModel  // Используем модель
            spacing: 5

            delegate: Item {
                width: ListView.view.width
                height: 50

                Rectangle {
                    width: parent.width
                    height: 50
                    color: "#1E1E1E"
                    border.color: "#333333"
                    radius: 5

                    Row {
                        anchors.fill: parent
                        spacing: 10
                        leftPadding: 10

                        CheckBox {
                            id: checkBox
                            anchors.verticalCenter: parent.verticalCenter

                            Component.onCompleted: {
                                checkBox.checked = selectedAppsToRemove.some(app => app.app_id === model.app_id);
                            }

                            onCheckedChanged: {
                                if (checked) {
                                    selectedAppsToRemove.push({
                                        app_id: model.app_id,
                                        title: model.name,
                                        exePath: model.exePath,
                                        processName: model.processName
                                    });
                                } else {
                                    selectedAppsToRemove = selectedAppsToRemove.filter(app => app.app_id !== model.app_id);
                                }
                            }
                        }

                        Text {
                            text: model.name + " - " + model.exePath
                            font.pixelSize: 14
                            color: "#E0E0E0"
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
        if (statCleaningManager) {
            statCleaningManager.updateAliases(); // Обновляем список приложений
        }
    }
}
