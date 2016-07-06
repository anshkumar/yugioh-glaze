import VPlay 2.0
import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import "../common"

SceneBase {
    id: selectPuzzleScene

    // signal indicating that a level has been selected
    signal puzzlePressed(string selectedPuzzle)

    state: "exited"

    XmlListModel {
        id: puzzleModel
        source: "../../assets/puzzle.xml"
        query: "/data/item"
        XmlRole { name: "title"; query: "title/string()" }
    }

    Component {
        id: puzzleDelegate
        ClickableImage {
            id: wrapper
            text: title; source: "../../assets/img/qt.png"
            onClicked: {
                GridView.view.currentIndex = index;
                var selectedPuzzle = index<9 ? "QB00"+(index+1) : "QB0"+(index+1);
                puzzlePressed(selectedPuzzle)
            }
        }
    }

    GridView {
        id: gView
        anchors {
            top: gameWindowAnchorItem.top
            left: gameWindowAnchorItem.left
            right: gameWindowAnchorItem.right
            bottom: button.top
            bottomMargin: 10
        }

        model: puzzleModel
        delegate: puzzleDelegate
        //highlight: Rectangle { color: "lightsteelblue"; radius: 5 }
        focus: true
        clip: true
        //            interactive: false
    }

    // back button to leave scene
    Item {
        id: button
        height: b1.height
        anchors.left: parent.gameWindowAnchorItem.left
        anchors.bottom: gameWindowAnchorItem.bottom
        anchors.bottomMargin: 30
        MenuButton {
            id: b1
            text: qsTr("Back")
            onClicked: {
                selectPuzzleScene.state = "exited";
                sceneChangeTimer.start();
//                backButtonPressed()
            }

            Timer {
              id: sceneChangeTimer
              interval: b1.slideDuration
              onTriggered: gameWindow.state = "menu"
            }
        }
    }

    states: [
        State {
            name: "entered"
            PropertyChanges{ target: gView; opacity: 1}
            StateChangeScript {
               script: {
                   b1.slideIn();
               }
            }
        },
        State {
            name: "exited"
            PropertyChanges { target: gView; opacity: 0}
            StateChangeScript {
                script: {
                    b1.slideOut();
                }
            }
        }
    ]

    transitions: Transition {
      NumberAnimation {
        duration: 900
        property: "opacity"
        easing.type: Easing.InOutQuad
      }
    }
}
