import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Item {
    Rectangle {
        anchors.fill: parent
        color: "#121212"  // Темный фон (почти черный)

        // Сообщение, если список пуст
        Label {
            id: emptyListMessage
            anchors.centerIn: parent
            text: "Нет отслеживаемых приложений"
            font.pixelSize: 20
            color: "#E0E0E0"  // Светло-серый цвет текста
            visible: trackedAppsModel ? trackedAppsModel.count === 0 : true // Проверка на null
        }

        // Список отслеживаемых приложений
        ListView {
            id: listView
            anchors.fill: parent
            anchors.margins: 20  // Отступы от краев
            model: trackedAppsModel // Используем trackedAppsModel
            visible: trackedAppsModel ? trackedAppsModel.count > 0 : false // Проверка на null
            spacing: 10 // Отступ между элементами
            clip: true  // Обрезаем содержимое, если оно выходит за пределы

            delegate: Item {
                id: delegateItem
                width: ListView.view.width - 40  // Ширина с учетом отступов
                height: expanded ? 140 : 70 // Высота зависит от состояния (раскрыто/свернуто)
                property bool expanded: false // Состояние раскрытия

                // Тень для ячейки
                Rectangle {
                    id: shadow
                    anchors.fill: parent
                    color: "transparent"
                    radius: 10  // Скругление углов
                    layer.enabled: true
                    layer.effect: DropShadow {
                        color: "#40000000"  // Легкая тень
                        radius: 5
                        samples: 10
                        verticalOffset: 2
                    }
                }

                // Основная ячейка
                Rectangle {
                    width: parent.width
                    height: parent.height
                    color: "#1E1E1E"  // Темный фон ячейки
                    border.color: "#333333"  // Темно-серая граница
                    radius: 10  // Скругление углов

                    // Основной контент (псевдоним, кнопка редактирования и стрелочка)
                    RowLayout {
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            margins: 15
                        }
                        height: 40

                        // Псевдоним приложения
                        Text {
                            text: alias
                            font.pixelSize: 16
                            font.bold: true
                            color: "#E0E0E0"  // Светло-серый цвет текста
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        // Кнопка редактирования (карандашик)
                        Button {
                            width: 30
                            height: 30
                            text: "✏️"  // Иконка карандаша
                            onClicked: {
                                // Передаем данные в диалог
                                editAliasDialog.appName = name
                                editAliasDialog.appProcessName = processName
                                editAliasDialog.appExePath = exePath
                                editAliasDialog.open()
                            }
                            background: Rectangle {
                                color: "transparent"
                                border.color: "#333333"  // Темно-серая граница
                                radius: 15
                            }
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 14
                                color: "#E0E0E0"  // Светло-серый цвет текста
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        // Стрелочка вниз
                        Button {
                            width: 30
                            height: 30
                            text: delegateItem.expanded ? "▲" : "▼" // Меняем стрелочку в зависимости от состояния
                            onClicked: {
                                delegateItem.expanded = !delegateItem.expanded // Переключаем состояние
                            }
                            background: Rectangle {
                                color: "transparent"
                                border.color: "#333333"  // Темно-серая граница
                                radius: 15
                            }
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 14
                                color: "#E0E0E0"  // Светло-серый цвет текста
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    // Дополнительная информация (путь и процесс)
                    Column {
                        id: additionalInfo
                        visible: delegateItem.expanded // Показываем только при раскрытии
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            topMargin: 60 // Отступ от верха
                            leftMargin: 15
                            rightMargin: 15
                        }
                        spacing: 10

                        // Путь
                        Text {
                            text: "Путь: " + exePath
                            font.pixelSize: 14
                            color: "#B0B0B0"  // Серый цвет текста
                            elide: Text.ElideRight
                        }

                        // Имя процесса
                        Text {
                            text: "Процесс: " + processName
                            font.pixelSize: 14
                            color: "#B0B0B0"  // Серый цвет текста
                            elide: Text.ElideRight
                        }
                    }
                }

                // Анимация раскрытия
                Behavior on height {
                    NumberAnimation { duration: 200 } // Плавное изменение высоты за 200 мс
                }
            }
        }
    }

    // Диалог для редактирования псевдонима
    Dialog {
        id: editAliasDialog
        title: "Редактировать псевдоним"
        standardButtons: Dialog.Ok | Dialog.Cancel
        width: 300
        height: 200

        // Свойства для хранения данных
        property string appName: ""
        property string appProcessName: ""
        property string appExePath: ""

        contentItem: ColumnLayout {
            spacing: 10

            TextField {
                id: aliasInput
                placeholderText: "Введите новый псевдоним"
                font.pixelSize: 14
                color: "#E0E0E0"  // Светло-серый цвет текста
                placeholderTextColor: "#808080"  // Серый цвет плейсхолдера
                background: Rectangle {
                    color: "#1E1E1E"  // Темный фон
                    radius: 5  // Скругление углов
                    border.color: "#333333"  // Темно-серая граница
                }
            }
        }

        background: Rectangle {
            color: "#1E1E1E"  // Темный фон диалога
            radius: 5  // Скругление углов
        }

        onAccepted: {
            // Обновляем псевдоним в базе данных
            trackedAppsManager.addOrUpdateAlias(appName, appProcessName, appExePath, aliasInput.text)
            trackedAppsManager.updateTrackedApps()  // Обновляем список приложений
        }
    }

    Component.onCompleted: {
        if (trackedAppsManager) {
            trackedAppsManager.updateTrackedApps();
        }
    }
}