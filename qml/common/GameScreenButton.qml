import VPlay 2.0
import QtQuick 2.0

Item {
    id: button
    property string text;
    visible: false
    property bool isEnabled: false
    property bool isPressed: true

    Rectangle {
        anchors.fill: parent
        color: "black"
        border.color: isPressed ? "" : "#00f9ff"
        border.width: 5
        radius: 10
        Text {
            text: qsTr(button.text)
            anchors.centerIn: parent
            font.family: contentFont.name
            font.pixelSize: 18
            color: "#233241"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if(isEnabled) {

                }
            }
        }
    }
}
