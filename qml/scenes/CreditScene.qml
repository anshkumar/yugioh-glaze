import QtQuick 2.0
import VPlay 2.0
import "../common/"

// This scene is only displayed if there is no gamecenter connection
SceneBase {
  id: creditsScene

  state: "exited"

  Column {
    id: leftColumn
    x: 30
    y: 20
    spacing: 10

    Text {
      text: qsTr("Team:\nVedanshu")
      color: "white"
      font.family: contentFont.name
      font.pixelSize: 22
    }

    Column {
      Text {
        text: qsTr("Graphics:\nWolfgang Hoffelner")
        color: "white"
        font.family: contentFont.name
        font.pixelSize: 22
      }

//      Image {
//        source: "../../assets/img/woho-logo.png"
//        height: 40
//        fillMode: Image.PreserveAspectFit

//        MouseArea {
//          anchors.fill: parent
//          onClicked: nativeUtils.openUrl("http://www.wo-ho.at")
//        }
//      }
    }



    Text {
      text: qsTr("Sounds:\nMartin Lenzelbauer")
      color: "white"
      font.family: contentFont.name
      font.pixelSize: 22
    }
  }

  Column {
    id: rightColumn
    x: creditsScene.width/ 2 + 30
    y: 20
    spacing: 20

    Text {
      text: qsTr("Initial YGOPRO Team:\nRoman Divotkey")
      color: "white"
      font.family: contentFont.name
      font.pixelSize: 22
    }
  }


  Item {
    id: button
    height: b1.height
    anchors.left: creditsScene.gameWindowAnchorItem.left
    anchors.bottom: creditsScene.gameWindowAnchorItem.bottom
    anchors.bottomMargin: 30

    MenuButton {
      id: b1

      text: qsTr("Back")

      onClicked: {
        creditsScene.state = "exited"
        sceneChangeTimer.start()
      }

      Timer {
        id: sceneChangeTimer
        interval: b1.slideDuration
        onTriggered: gameWindow.state = "menu"
      }
    }
  }

  Column {
    id: logoColumn
    anchors.top: button.top
    anchors.topMargin: -8
    anchors.left: rightColumn.left
    spacing: 8

    Text {
      text: qsTr("Proudly developed with")
      color: "white"
      font.family: contentFont.name
      font.pixelSize: 22
    }

    Image {
      source: "../../assets/img/vplay.png"
      // the image size is bigger (for hd2 image), so only a single image no multiresimage can be used
      // this scene is not performance sensitive anyway!
      fillMode: Image.PreserveAspectFit
      height: 55

      MouseArea {
        anchors.fill: parent
        onClicked: nativeUtils.openUrl("http://v-play.net/showcases/?utm_medium=game&utm_source=squaby&utm_campaign=squaby#squaby");
      }
    }
  }

  // Called when scene is displayed
  function enterScene() {
    state = "entered"
  }

  states: [
    State {
      name: "entered"
      PropertyChanges { target: leftColumn; opacity: 1 }
      PropertyChanges { target: rightColumn; opacity: 1 }
      PropertyChanges { target: logoColumn; opacity: 1 }
      StateChangeScript {
        script: {
          b1.slideIn();
        }
      }
    },
    State {
      name: "exited"
      PropertyChanges { target: leftColumn; opacity: 0 }
      PropertyChanges { target: rightColumn; opacity: 0 }
      PropertyChanges { target: logoColumn; opacity: 0 }
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
