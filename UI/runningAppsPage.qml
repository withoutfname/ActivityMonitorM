import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    // Инициализация массивов для временного хранения отмеченных приложений
    property var runningAppsToAdd: [] // Для страницы "Запущенные приложения"

    Rectangle {
        anchors.fill: parent
        color: "#121212"  // Темный фон (почти черный)

        ColumnLayout {
            anchors.fill: parent
            spacing: 20
            anchors.margins: 20

            // Поле поиска и кнопки
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // Поле поиска
                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: "Поиск по названию"
                    font.pixelSize: 14
                    color: "#E0E0E0"  // Светло-серый цвет текста
                    placeholderTextColor: "#808080"  // Серый цвет плейсхолдера
                    background: Rectangle {
                        color: "#1E1E1E"  // Темный фон
                        radius: 5  // Скругление углов
                        border.color: "#333333"  // Темно-серая граница
                    }
                    onTextChanged: {
                        if (openedWindowsModel) {
                            openedWindowsModel.filter(text);
                        }
                    }
                }

                // Кнопка "Обновить"
                Button {
                    text: "Обновить"
                    font.pixelSize: 14
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
                        runningAppsToAdd = [];
                        openedWindowsManager.updateOpenedWindows(); // Используем openedWindowsManager
                    }
                }

                // Кнопка "Сохранить"
                Button {
                    text: "Сохранить"
                    font.pixelSize: 14
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
                        if (runningAppsToAdd.length === 0) {
                            messageDialog.open();
                        } else {
                            trackedAppsManager.saveAppsToDatabase(runningAppsToAdd); // Сохраняем в БД
                            runningAppsToAdd = []; // Очищаем массив
                            trackedAppsManager.updateTrackedApps(); // Обновляем список отслеживаемых приложений
                            openedWindowsManager.updateOpenedWindows(); // Обновляем список открытых окон
                        }
                    }
                }
            }

            // Список открытых окон
            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: openedWindowsModel
                spacing: 10  // Отступ между элементами
                clip: true  // Обрезаем содержимое, если оно выходит за пределы

                delegate: Rectangle {
                    width: listView.width
                    height: 80
                    color: "#1E1E1E"  // Темный фон
                    border.color: "#333333"  // Темно-серая граница
                    radius: 10  // Скругление углов

                    RowLayout {
                        anchors.fill: parent
                        spacing: 10
                        anchors.margins: 10

                        // Чекбокс для выбора приложения
                        CheckBox {
                            id: checkBox
                            Layout.alignment: Qt.AlignVCenter

                            // Устанавливаем начальное состояние чекбокса
                            Component.onCompleted: {
                                checkBox.checked = runningAppsToAdd.some(app => app.processName === model.processName);
                            }

                            onCheckedChanged: {
                                if (checked) {
                                    // Добавляем приложение в массив, если чекбокс отмечен
                                    runningAppsToAdd.push({
                                        title: model.title,
                                        processName: model.processName,
                                        exePath: model.exePath
                                    });
                                } else {
                                    // Удаляем приложение из массива, если чекбокс снят
                                    runningAppsToAdd = runningAppsToAdd.filter(app => app.processName !== model.processName);
                                }
                            }
                        }

                        // Информация о приложении
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                text: model.title
                                font.pixelSize: 16
                                font.bold: true
                                color: "#E0E0E0"  // Светло-серый цвет текста
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "Процесс: " + model.processName
                                font.pixelSize: 14
                                color: "#B0B0B0"  // Серый цвет текста
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "Путь: " + model.exePath
                                font.pixelSize: 14
                                color: "#B0B0B0"  // Серый цвет текста
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
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
        runningAppsToAdd = [];
        openedWindowsManager.updateOpenedWindows(); // Используем openedWindowsManager
    }
}