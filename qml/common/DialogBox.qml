import VPlay 2.0
import QtQuick 2.0
import QtQuick.Controls 1.4

Image {
    id: dialogBox
    width: 384
    height: 100
    x: __outslidedX
    anchors.verticalCenter: gameWindowAnchorItem.verticalCenter
    property int delay: 0
    property int offsetX: 0
    property int __outslidedX:  slideInFromRight ? -outslidedXBase * (1  + delay / slideDuration) : outslidedXBase * (1  + delay / slideDuration)
    property int outslidedXBase:  dialogBox.width
    property bool slideInFromRight: true
    property int slideDuration: 800
    property bool slidedOut: true
    property var model: ""
    source: "../../assets/img/text-dialog-background.png"
    Text {
        id: dialog
        anchors.centerIn: parent
        color: "white"
        font.family: contentFont.name
        font.pixelSize: 22
    }

    Item {
        height: parent.height
        width: (horizontalCardList.count*177 > duelField.width-20-graveyardCardZone1.width) ? duelField.width-20-graveyardCardZone1.width : horizontalCardList.count*177
        anchors.centerIn: parent
        ScrollViewVPlay {
            anchors.fill: parent
            flickableItem.interactive: true
        ListView {
            id: horizontalCardList
            anchors.fill: parent
            delegate: Item {
                width: 177; height: 254
                ClientCard {
                anchors.fill: parent
                cWidth: 177
                cHeight: 254
                source: (code != 0)?"../../assets/pics/"+ code +".jpg":""
                Image {
                    anchors.fill: parent
                    source: "../../assets/img/act.png"
                    enabled: false
                    visible: {
                        if(cmdFlag & 0x0001)    //command_activate
                            return true;
                        else
                            return false;
                    }

                    fillMode: Image.PreserveAspectFit
                    RotationAnimation on rotation {
                              loops: Animation.Infinite
                              from: 0
                              to: 360
                              duration: 3000
                          }
                }
                }
            }
            model: dialogBox.model
            orientation: Qt.Horizontal
            spacing: 5
            focus: true
        }
        }
    }

    function activateMessage(message) {
        dialog.text = message;
        slideIn();
        timer.start();
    }
    Behavior on x {
      SmoothedAnimation { duration: slideDuration; easing.type: Easing.InOutQuad }
    }

    function slideIn() {
      dialogBox.slidedOut = false
      if(slideInFromRight) {
        x = description.width + duelField.width/2 + offsetX - dialogBox.width/2 + 20
      } else {
        x = __outslidedX+gameWindow.width/2-offsetX-dialogBox.width
      }
    }

    function slideOut() {
      dialogBox.slidedOut = true
      if(slideInFromRight) {
        x = __outslidedX
      } else {
        x = __outslidedX
      }
    }
    Timer {
        id: timer
        interval: 2000
        onTriggered: {
            slideOut();
        }
    }
}
