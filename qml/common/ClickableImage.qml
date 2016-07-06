import QtQuick 2.0

Item {
    id: root
    width: container.childrenRect.width
    height: container.childrenRect.height
    property alias text: label.text
    property alias source: image.source
    signal clicked
    property bool framed: false

    Rectangle {
        anchors.fill: parent
        visible: root.framed
        color: "white"
    }

    Column {
        id: container
        Image {
            id: image
            scale: 0.8
            Behavior on scale {
                NumberAnimation {duration: 200}
            }
        }
        Text {
            id: label
            width: image.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            color: "white"
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            image.scale = 1
        }
        onExited: {
            image.scale = 0.8
        }
        onClicked: parent.clicked()
    }
}
