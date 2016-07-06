import VPlay 2.0
import QtQuick 2.0
import "../common"

SceneBase {
  id: menuScene

  state: "exited"

  // signal indicating that the playScene should be displayed
  signal playPressed
  // signal indicating that the selectLevelScene should be displayed
  signal selectPuzzlePressed
  // signal indicating that the creditsScene should be displayed
  signal creditsPressed

  property string exitAction: ""
  // only if this is set to true, the exit dialog should quit the app
  property bool exitDialogShown: false
  property bool vplayLinkShown: false

  MultiResolutionImage {
    id: playerBg
    source: "../../assets/img/backgrounds/boss_ArcanaForceEXTheLightRuler_R.png"
    anchors.left: parent.left
  }

  Column {
    id: menuColumn
    anchors.left: menuScene.gameWindowAnchorItem.left
    y:15
    spacing: 4

    // Play button
    MenuButton {
      id: b1

      offsetX: 30

      text: qsTr("Play")

      onClicked: {
        menuScene.state = "exited"
        exitAction = "playClicked"
      }
    }

    MenuButton {
      id: b2

      offsetX: 30
      delay: 500
      text: qsTr("Puzzles")

      onClicked: {
        menuScene.state = "exited"
        exitAction = "myPuzzlesClicked"
      }
    }

    MenuButton {
      id: b3

      offsetX: 30
      delay: 1000
      text: qsTr("Credits")

      onClicked: {
        menuScene.state = "exited"
        exitAction = "creditsClicked"
      }
    }

} // end of Column

  Connections {
    // nativeUtils should only be connected, when this is the active scene
      target: activeScene === menuScene ? nativeUtils : null
      onMessageBoxFinished: {
        console.debug("the user confirmed the Ok/Cancel dialog with:", accepted)
        if(accepted && exitDialogShown) {
          Qt.quit()
        } else if(accepted && vplayLinkShown) {
          flurry.logEvent("MainScene.Show.VPlayWeb")
          nativeUtils.openUrl("http://");
        }

        // set it to false again
        exitDialogShown = false
        vplayLinkShown = false
      }
  }


  onBackButtonPressed: {
    exitDialogShown = true
    nativeUtils.displayMessageBox(qsTr("Really quit the game?"), "", 2);
    // instead of immediately shutting down the app, ask the user if he really wants to exit the app with a native dialog
    //Qt.quit()
  }

  // Called when scene is displayed
  function enterScene() {
    state = "entered"
  }

  states: [
    State {
      name: "entered"
      PropertyChanges { target: playerBg; opacity: 1 }

      StateChangeScript {
        script: {
          b1.slideIn();
          b2.slideIn();
          b3.slideIn();
          //settingsButton.slideIn();
        }
      }
    },
    State {
      name: "exited"
      PropertyChanges { target: playerBg; opacity: 0 }
      StateChangeScript {
        script: {
          b1.slideOut();
          b2.slideOut();
          b3.slideOut();
          sceneChangeTimer.start()
        }
      }
    }
  ]

  Timer {
    id: sceneChangeTimer
    interval: b3.slideDuration
    onTriggered: {
      if(exitAction === "playClicked") {
        playPressed()
      } else if(exitAction === "myPuzzlesClicked") {
        selectPuzzlePressed()
      } else if(exitAction === "creditsClicked") {
        creditsPressed()
      }
    }
  }

  transitions: Transition {
      NumberAnimation {
        targets: playerBg
        duration: 900
        property: "opacity"
        easing.type: Easing.InOutQuad
      }
    }

}
