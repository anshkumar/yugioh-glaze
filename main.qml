import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import QtQuick.Window 2.0   // for Screen.width and Screen.height

Image {
    id: root
    width: 1024/*Screen.width*/
    height: 600/*Screen.height*/
    source: "file:img/hexa_bg.png"
    fillMode: Image.PreserveAspectCrop
    property real buttonwide: 300
    property real buttonhigh: 50
    property real screenWidth: width
    property real screenHeight: height

    Item {
        id: menu
        anchors {
            top: bExit.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
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
        y: /*root.height - buttonhigh -*/ 50
        text: qsTr("Quit")
        onClicked: Qt.quit()
    }
    Button {
        id: bPlay
        x: root.width - buttonwide - 25
        y: /*root.height - buttonhigh -*/ 50
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
    }

    FontLoader {
        id: contentFont
        source: "file:fonts/ChaneyWide.ttf"
    }

    function exitScreenFront() {
        exitScreen.z = 2;
        exitScreen.opacity = 0.8
    }

    function exitScreenBack() {
        exitScreen.z = -1;
        exitScreen.opacity = 0;
    }

    Rectangle {
        id: exitScreen
        anchors.fill: parent
        z:-1
        color: "black"
        opacity: 0
        Row {
            anchors.centerIn: parent
            spacing: 10
            Button {
                text: qsTr("Exit")
                onClicked: {
                    console.log("EXIT");
                    game.stopSinglePlay(true);
                    exitScreenBack()
                    comeBack();
                }
            }
            Button {
                text: qsTr("Cancel")
                onClicked: {
                    exitScreenBack();
                }
            }
        }
        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }

    Keys.onEscapePressed: {
        cField.exitClicked();
        exitScreenFront();
        event.accepted = true;
    }
}
