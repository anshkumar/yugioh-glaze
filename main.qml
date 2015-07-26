import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import QtQuick.Window 2.2   // for Screen.width and Screen.height

Image {
    id: root
    width: 1024/*Screen.width*/
    height: 640/*Screen.height*/
    source: "file:img/hexa_bg.png"
    fillMode: Image.PreserveAspectCrop
    property real buttonwide: 300
    property real buttonhigh: 50

    Item {
        id: menu
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: bExit.top
            bottomMargin: 10
        }

        XmlListModel {
            id: puzzleModel
            source: "qrc:/puzzle.xml"
            query: "/data/item"
            XmlRole { name: "title"; query: "title/string()" }
        }

        Component {
            id: puzzleDelegate
            ClickableImage {
                id: wrapper
                text: title; source: "file:img/qt.png"
                onClicked: GridView.view.currentIndex = index
            }
        }

        GridView {
            id: gView
            anchors.fill: parent
            model: puzzleModel
            delegate: puzzleDelegate
            highlight: Rectangle { color: "lightsteelblue"; radius: 5 }
            focus: true
            clip: true
//            interactive: false
            }
    }

    function goAway() {
        gView.visible = false;
        bExit.visible = false;
        bPlay.visible = false;
        cField.visible = true;
    }

    function comeBack() {
        gView.visible = true;
        bExit.visible = true;
        bPlay.visible = true;
        cField.visible = false;
    }

    Button {
        id: bExit
        x: 100
        y: root.height - buttonhigh - 50
        text: qsTr("Quit")
        onClicked: Qt.quit()
    }
    Button {
        id: bPlay
        x: root.width - buttonwide - 25
        y: root.height - buttonhigh - 50
        text: qsTr("Play")
        property string selectedtext
        onClicked: {
            goAway();
            selectedtext = gView.currentIndex<9 ? "QB00"+(gView.currentIndex+1) : "QB0"+(gView.currentIndex+1);
            game.startSinglePlay(selectedtext);
        }
    }

    ClientField {
        id: cField
        visible: false
        anchors.fill: parent
        Image {
            source: "file:img/gs_btn_mainmenu.png"
            scale: 0.75
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.bottomMargin: 10
            anchors.rightMargin: 10
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    cField.exitClicked();
                    game.stopSinglePlay(true);
                    comeBack();
                }
            }
        }
    }
}
