import VPlay 2.0
import QtQuick 2.0

MultiResolutionImage {
    id: dialogBox
    width: 384
    height: 100
    x: __outslidedX
    anchors.verticalCenter: gameWindowAnchorItem.verticalCenter
    property int delay: 0
    property int offsetX: 0
    property int __outslidedX:  slideInFromRight ? -outslidedXBase * (1  + delay / slideDuration) : outslidedXBase * (1  + delay / slideDuration)
    property int outslidedXBase:  384
    property bool slideInFromRight: true
    property int slideDuration: 800
    property bool slidedOut: false
    source: "../../assets/img/text-dialog-background.png"
    Text {
        id: dialog
        anchors.centerIn: parent
        color: "white"
        font.family: contentFont.name
        font.pixelSize: 22
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
        x = gameWindow.width/2 + offsetX - 384/2
      } else {
        x = __outslidedX+gameWindow.width/2-offsetX-384
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
