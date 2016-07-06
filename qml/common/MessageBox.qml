import QtQuick 2.0
import QtQuick.Window 2.0

BorderImage {
    id: mBox
//    visible: false
    z: 1
    x: -width
//    anchors.centerIn: parent
    height: 300
    width: 800
    source: "../../assets/img/menubox.png"
//    scale: 0.5
    property string text: ""
    signal clicked;
    border { left: 200; top: 110; right: 200; bottom: 110 }
    horizontalTileMode: BorderImage.Stretch
    verticalTileMode: BorderImage.Stretch
    Behavior on x {
        NumberAnimation {
            duration: 200
        }
    }

    FontLoader {
        id: contentFont
        source: "../../assets/fonts/ChaneyWide.ttf"
    }
    Text {
        id: messageBoxText
        anchors.top: parent.top
        anchors.topMargin: 80
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr(parent.text)
        font.family: contentFont.name
        color: "#00f9ff"
        font.pixelSize: 24
    }
    Button {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 60
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("OK")
        onClicked: mBox.clicked()
    }
}
