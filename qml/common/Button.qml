import QtQuick 2.0
Item {
    id: okbutton
    width: buttonwide-100
    height: buttonhigh
    property string text: ""
    signal clicked;
    Image {
        anchors.left: parent.left
        width: parent.width/3
        height: parent.height - 1
        source: "../../assets/img/mm_btn_small_extension_move.png"
        fillMode: Image.PreserveAspectFit
    }
    Image {
        anchors.right: parent.right
        width: parent.width/3
        height: parent.height - 1
        source: "../../assets/img/mm_btn_small_extension_move.png"
        fillMode: Image.PreserveAspectFit
        mirror: true
    }
    Image {
        id: buttonImg
        width: 2*parent.width/3
        height: parent.height + 3
        anchors.horizontalCenter: parent.horizontalCenter
        source: "../../assets/img/mm_btn_small_inactive.png"
    }
    FontLoader {
        id: contentFont
        source: "../../assets/fonts/ChaneyWide.ttf"
    }
    Text {
        id: buttonText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 7
        font.bold: true
        font.family: contentFont.name
        text: qsTr(parent.text)
        color: "#00f9ff"
        font.pixelSize: 22
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onPressed: {
            buttonText.color = "#11112c";
            buttonImg.source = "../../assets/img/mm_btn_small_active.png";
        }
        onReleased: {
            buttonText.color = "#00f9ff";
            buttonImg.source = "../../assets/img/mm_btn_small_inactive.png";
        }
        onClicked: parent.clicked()
    }
}

