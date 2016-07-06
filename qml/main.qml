import VPlay 2.0
import QtQuick 2.0
import "./scenes"

GameWindow {
    id: gameWindow

    screenWidth: 1024
    screenHeight: 600
    property real buttonwide: 300
    property real buttonhigh: 50

    //create and remove entities at runtime
    EntityManager {
        id: entityManager
    }

    FontLoader {
        id: contentFont
        source: "../assets/fonts/ChaneyWide.ttf"
    }

    //menu scene
    MenuScene {
        id: menuScene
        // listen to the button signals of the scene and change the state according to it
        onSelectPuzzlePressed: gameWindow.state = "selectPuzzle"
        onCreditsPressed: gameWindow.state = "credits"

        // the menu scene is our start scene, so if back is pressed there we ask the user if he wants to quit the application
        onBackButtonPressed: {
            nativeUtils.displayMessageBox("Really quit the game?", "", 2);
        }
        // listen to the return value of the MessageBox
        Connections {
            target: nativeUtils
            onMessageBoxFinished: {
                // only quit, if the activeScene is menuScene - the messageBox might also get opened from other scenes in your code
                if(accepted && window.activeScene === menuScene)
                    Qt.quit()
            }
        }
    }

    //scene for selecting puzzles
    SelectPuzzleScene {
        id: selectPuzzleScene
        onPuzzlePressed: {
            // selectedLevel is the parameter of the levelPressed signal
            gameScene.setPuzzle(selectedPuzzle)
            gameWindow.state = "game"

        }
        onBackButtonPressed: gameWindow.state = "menu"
    }

    //credit scene
    CreditScene {
        id: creditsScene
        onBackButtonPressed: gameWindow.state = "menu"
    }

    //game scene to play a puzzle
    GameScene {
        id: gameScene
        onBackButtonPressed: gameWindow.state = "selectPuzzle"
    }

    // default state is menu -> default scene is menuScene
    state: "menu"

    // state machine, takes care reversing the PropertyChanges when changing the state like changing the opacity back to 0
    states: [
        State {
            name: "menu"
            PropertyChanges {target: menuScene; opacity: 1}
            PropertyChanges {target: gameWindow; activeScene: menuScene}
            PropertyChanges {target: menuScene; state: "entered"}
        },
        State {
            name: "selectPuzzle"
            PropertyChanges {target: selectPuzzleScene; opacity: 1}
            PropertyChanges {target: gameWindow; activeScene: selectPuzzleScene}
            PropertyChanges {target: selectPuzzleScene; state: "entered"}
        },
        State {
            name: "credits"
            PropertyChanges {target: creditsScene; opacity: 1}
            PropertyChanges {target: gameWindow; activeScene: creditsScene}
            PropertyChanges {target: creditsScene; state: "entered"}
        },
        State {
            name: "game"
            PropertyChanges {target: gameScene; opacity: 1}
            PropertyChanges {target: gameWindow; activeScene: gameScene}
        }
    ]
}
