import QtQuick 2.0

BorderImage {
    id: mBox
    visible: false
    z: 100
    anchors.centerIn: parent
    height: 300
    width: 800
    source: "file:img/menubox.png"
    scale: 0.5
    property string text: ""
    signal clicked;
    border { left: 200; top: 110; right: 200; bottom: 110 }
    horizontalTileMode: BorderImage.Stretch
    verticalTileMode: BorderImage.Stretch
    FontLoader {
        id: contentFont
        source: "file:fonts/ChaneyWide.ttf"
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
