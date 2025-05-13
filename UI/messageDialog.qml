import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.2

Dialog {
    id: dialog
    title: "Ошибка"
    standardButtons: Dialog.Ok

    contentItem: Text {
        text: "Выберите хотя бы одно приложение"
        wrapMode: Text.WordWrap
    }

    onAccepted: {
        dialog.close()
    }
}
