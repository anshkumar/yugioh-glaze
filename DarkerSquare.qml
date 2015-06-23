import QtQuick 2.0

Rectangle {
    id: root
    width: 48
    height: 48
    color: "#222020"
    border.color: Qt.lighter(color)
    property alias text: label.text

    Text {
        id: label
        anchors.centerIn: parent
        text: qsTr("")
    }
}
