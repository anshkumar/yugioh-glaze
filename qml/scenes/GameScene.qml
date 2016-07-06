import VPlay 2.0
import QtQuick 2.0
import "../common"

SceneBase {
    id: gameScene

    property real cardWidth: 50
    property real cardHeight: 73
    property real detailWidth: 300
    property real desImgScale: 0.6
    property real desImgTopMargin: -22
    property real desImgLeftMargin: 20
    property real fieldTopMargin: 0
    property real fieldBottomMargin: 0
    property real maxHandWidth: width - 11*cardWidth
    property string charImage1: "../../assets/img/default_avatar_f_0.png"
    property string charImage2: "../../assets/img/default_avatar_m_0.png"
    signal exitClicked;
    property string clientname: ""
    property string hostname: ""

    function setPuzzle(fileName) {
        game.startSinglePlay(fileName);
    }

    // back button to leave scene
    MenuButton {
        text: "Back"
        anchors.right: gameScene.gameWindowAnchorItem.right
        anchors.rightMargin: 10
        anchors.top: gameScene.gameWindowAnchorItem.top
        anchors.topMargin: 10
        onClicked: backButtonPressed();
    }

    FontLoader {
        id: contentFont
        source: "../../assets/fonts/ChaneyWide.ttf"
    }
    FontLoader {
        id: descriptionFont
        source: "../../assets/fonts/StoneSerif.ttf"
    }

    Item {
        id: player1Descriptions
        anchors.left: gameScene.gameWindowAnchorItem.left
        anchors.top: gameScene.gameWindowAnchorItem.top
        width: detailWidth
        height: 100
        MultiResolutionImage {
            id: charBack1
            source: "../../assets/img/gamescreen_char_bg.png"
            anchors {
                right: parent.right
                bottom: parent.bottom
            }
            height: player1Image.height
            width: 300
        }
        MultiResolutionImage {
            id: charName1
            source: "../../assets/img/gs_char_namebox.png"
            anchors {
                top: player1Image.top
                topMargin: 5
                left: player1Image.right
            }
            height: player1Image.height/4
            width: charBack1.width - 100
            Text {
                anchors.centerIn: parent
                text: qsTr(hostname)
                font {
                    family: contentFont.name
                    bold: true
                    pixelSize: 22
                }
                color: "#1030e5"
            }
        }
        MultiResolutionImage {
            id: progressBar1
            source: "../../assets/img/gamescreen_lifepoints_meter_player.png"
            x: player1Image.width
            width: charName1.width
            height: charName1.height
            anchors {
                top: charName1.bottom
                topMargin: 5
            }
            Behavior on x {
                NumberAnimation { duration: 500 }
            }
        }
        MultiResolutionImage {
            source: "../../assets/img/gamescreen_lifepoints_cover.png"
            width: progressBar1.width + 7
            height: progressBar1.height + 5
            anchors {
                top: progressBar1.top
                left: player1Image.right
            }
        }
        MultiResolutionImage {
            id: player1Image
            anchors {
                bottom: parent.bottom
                left: parent.left
            }
            width: 100
            height: 100
            source: "../../assets/img/gs_char_border.png"
            Rectangle {
                width: 88
                height: 88
                color: "black"
                anchors.centerIn: parent
            }

            MultiResolutionImage {
                source: charImage1
                width: 88
                height: 88
                anchors.centerIn: parent
            }
        }
        Item {
            id: lp1
            width: progressBar1.width
            height: progressBar1.height
            anchors {
                left: player1Image.right
                top: progressBar1.bottom
                topMargin: 5
            }

            MultiResolutionImage {
                id: lp1Heart
                source: "../../assets/img/gs_LP_icon_blue.png"
                width: parent.width/5
                height: parent.height
                anchors {
                    left: parent.left
                    leftMargin: 30
                    top: parent.top
                    topMargin: 5
                }
                RotationAnimation on scale {
                    from: 1
                    to: 0.75
                    duration: 1000
                    loops: Animation.Infinite
                    direction: RotationAnimation.Counterclockwise
                }
            }
            Text {
                id: lp1Text
                text: qsTr("8000")
                anchors {
                    left: lp1Heart.right
                    leftMargin: 10
                    top: lp1.top
                    topMargin: 5
                }
                font {
                    family: contentFont.name
                    bold: true
                    pixelSize: 22
                }
                color: "#1030e5"
            }
        }
    }

    Item {
        id: player2Descriptions
        anchors.left: gameScene.gameWindowAnchorItem.left
        anchors.bottom: gameScene.gameWindowAnchorItem.bottom
        width: detailWidth
        height: 100
        MultiResolutionImage {
            id: charBack2
            source: "../../assets/img/gamescreen_char_bg.png"
            anchors {
                top: parent.top
                right: parent.right
            }
            height: player2Image.height
            width: 300
        }
        MultiResolutionImage {
            id: charName2
            source: "../../assets/img/gs_char_namebox.png"
            anchors {
                top: player2Image.top
                topMargin: 5
                left: player2Image.right
            }
            height: player2Image.height/4
            width: charBack2.width - 100
            Text {
                anchors.centerIn: parent
                text: qsTr(clientname)
                font {
                    family: contentFont.name
                    bold: true
                    pixelSize: 22
                }
                color: "#ff0000"
            }
        }
        MultiResolutionImage {
            id: progressBar2
            source: "../../assets/img/gamescreen_lifepoints_meter_opponent.png"
            x: player2Image.width
            width: charName2.width
            height: charName2.height
            anchors {
                top: charName2.bottom
                topMargin: 5
            }
            Behavior on x {
                NumberAnimation { duration: 500 }
            }
        }
        MultiResolutionImage {
            source: "../../assets/img/gamescreen_lifepoints_cover.png"
            width: progressBar2.width + 7
            height: progressBar2.height + 5
            anchors {
                top: progressBar2.top
                left: player2Image.right
            }
        }
        MultiResolutionImage {
            id: player2Image
            anchors {
                top : parent.top
                left: parent.left
            }
            width: 100
            height: 100
            source: "../../assets/img/gs_char_border.png"
            Rectangle {
                width: 88
                height: 88
                color: "black"
                anchors.centerIn: parent
            }

            MultiResolutionImage {
                source: charImage2
                width: 88
                height: 88
                anchors.centerIn: parent
            }
        }
        Item {
            id: lp2
            width: progressBar2.width
            height: progressBar2.height
            anchors {
                left: player2Image.right
                top: progressBar2.bottom
                topMargin: 5
            }

            MultiResolutionImage {
                id: lp2Heart
                source: "../../assets/img/gs_LP_icon_red.png"
                width: parent.width/5
                height: parent.height
                anchors {
                    left: parent.left
                    leftMargin: 30
                    top: parent.top
                    topMargin: 5
                }
                RotationAnimation on scale {
                    from: 1
                    to: 0.75
                    duration: 1000
                    loops: Animation.Infinite
                    direction: RotationAnimation.Counterclockwise
                }
            }
            Text {
                id: lp2Text
                text: qsTr("8000")
                anchors {
                    left: lp2Heart.right
                    leftMargin: 10
                    top: lp2.top
                    topMargin: 5
                }
                font {
                    family: contentFont.name
                    bold: true
                    pixelSize: 22
                }
                color: "#ff0000"
            }
        }
    }

    MultiResolutionImage {
        id: description
        source: "../../assets/img/gs_card_info.png"
        height: 370
        width: detailWidth
        anchors {
            left: gameScene.gameWindowAnchorItem.left
            verticalCenter: gameScene.gameWindowAnchorItem.verticalCenter
        }
        MultiResolutionImage {
            id: desCardImg
            anchors {
                top: parent.top
                topMargin: desImgTopMargin
                left: parent.left
                leftMargin: desImgLeftMargin
            }
            scale: desImgScale
        }
        MultiResolutionImage {
            id: desLevelRank
            width: 20
            height: 20
            anchors {
                left: parent.left
                leftMargin: 30
                top: desCardImg.bottom
                topMargin: desImgTopMargin
            }
            Text {
                id: levelRankText
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    leftMargin: 25
                }
                color: "white"
                font.pixelSize: 14
                font.bold: true
                font.family: descriptionFont.name
            }
        }
        Text {
            id: desAtk
            font.family: descriptionFont.name
            font.bold: true
            font.pixelSize: 16
            anchors {
                top: desLevelRank.top
                left: desLevelRank.right
                leftMargin: 35
            }
        }
        Text {
            id: desDef
            font.family: descriptionFont.name
            font.bold: true
            font.pixelSize: 16
            anchors {
                top: desAtk.top
                left: desAtk.right
                leftMargin: 5
            }
        }

        MultiResolutionImage {
            id: cardLogo1   // Card attribute (for monster card), spell logo(for spell card) etc
            width: 30
            height: 30
            anchors {
                top: desLevelRank.bottom
                topMargin: 10
                left: desLevelRank.left
            }
            Text {
                id: cardLogo1Text
                font.family: descriptionFont.name
                font.bold: true
                font.pixelSize: 14
                color: "white"
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.right
                    leftMargin: 5
                }
            }
        }
        MultiResolutionImage {
            id: cardLogo2   // Card race(for monster), quick spell etc
            width: 30
            height: 30
            anchors {
                top: cardLogo1.top
                left: cardLogo1.right
                leftMargin: 50
            }
            Text {
                id: cardLogo2Text
                font.family: descriptionFont.name
                font.bold: true
                font.pixelSize: 14
                color: "white"
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.right
                    leftMargin: 5
                }
            }
        }
        MultiResolutionImage {
            id: desLscale
            width: desLevelRank.width
            height: desLevelRank.height
            anchors {
                verticalCenter: cardLogo2.verticalCenter
                left: cardLogo2.right
                leftMargin: 70
            }
            Text {
                id: desLscaleText
                font.family: descriptionFont.name
                font.bold: true
                font.pixelSize: 14
                anchors {
                    top: desLscale.top
                    left: desLscale.right
                    leftMargin: 5
                }
            }
        }
        MultiResolutionImage {
            id: desRscale
            width: desLscale.width
            height: desLscale.height
            anchors {
                top: desLscale.top
                left: desLscale.right
                leftMargin: 20
            }
            Text {
                id: desRscaleText
                font.family: descriptionFont.name
                font.bold: true
                font.pixelSize: 14
                anchors {
                    top: desRscale.top
                    left: desRscale.right
                    leftMargin: 5
                }
            }
        }
        Text {
            id: cardName
            width: parent.width
            height: 15
            anchors {
                top: cardLogo1.bottom
                topMargin: 5
                left: cardLogo1.left
            }
            font.family: descriptionFont.name
            font.bold: true
            font.pixelSize: 14
            color: "yellow"
        }
        Text {
            id: cardType
            width: cardName.width
            height: cardName.height
            anchors {
                top: cardName.bottom
                left: cardName.left
            }
            font.family: descriptionFont.name
            font.bold: true
            font.pixelSize: 14
            color: "lightgreen"
        }
        Flickable {
            id: detailFlick
            anchors {
                top: cardType.bottom
                topMargin: 5
                left: cardType.left
                right: description.right
                bottom: description.bottom
                bottomMargin: 5

            }
            contentWidth: desText.width; contentHeight: desText.height
            flickableDirection: Flickable.VerticalFlick
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            TextEdit{
                id: desText
                wrapMode: TextEdit.Wrap
                width:description.width - 40;
                readOnly:true
            }
        }
        ScrollBar {
            flk: detailFlick
        }
    }

    MessageBox {
        id: messageBox
        anchors.verticalCenter: parent.verticalCenter
        onClicked: {
            messageBox.x = -messageBox.width;
            game.mySet();
            game.setQwMessage(false);
        }
    }

    Item {
        id: duelField
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            left: description.right
            leftMargin: 20
            topMargin: fieldTopMargin
            bottomMargin: fieldBottomMargin
        }

        MultiResolutionImage {
            id: extraCardZone1
            width: cardHeight + 20
            height: cardHeight + 20
            source: "../../assets/img/gs_cardslot_player.png"
            anchors {
                bottom: parent.bottom
                bottomMargin: 5
                left: duelField.left
            }
            MultiResolutionImage {
                height: cardHeight
                fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent
                source: "../../assets/img/gs_icon_card_summon.png"
            }
            Item {
                width: cardWidth; height: cardHeight
                anchors.centerIn: parent
                ListView {
                    anchors.fill: parent
                    model: clientField.extra1
                    spacing: -cardHeight + 0.5
                    delegate: MultiResolutionImage {
                        width: cardWidth
                        height: cardHeight
                        source: "../../assets/img/0000.png"
                    }
                }
            }
        }

        Item {
            id: lscaleCardZone1
            anchors {
                bottom: extraCardZone1.top
                bottomMargin: 5
                left: extraCardZone1.left
            }
            width: cardHeight + 20
            height: cardHeight + 20
            Component {
                id: lscaleCardZoneDelegate1
                MultiResolutionImage {
                    source: {
                        if(index === 6) {
                            width = cardHeight + 20;
                            height = cardHeight + 20;
                            return "../../assets/img/gs_cardslot_player.png";
                        }
                        else
                            return "";
                    }
                    ClientCard {
                        width: cardWidth; height: cardHeight;
                        anchors.centerIn: parent
                        isEnableDown: false
                        front: MultiResolutionImage {
                            width: cardWidth; height: cardHeight;
                            anchors.centerIn: parent
                            source : {
                                if(index == 6 && code != 0)
                                    return "../../assets/pics/"+ code +".jpg";
                                return "";
                            }
                        }
                    }

                }
            }
            ListView {
                delegate:lscaleCardZoneDelegate1
                focus: true
                interactive: false
                model: clientField.szone1
            }
        }

        Item {
            id: fieldCardZone1
            anchors {
                bottom: lscaleCardZone1.top
                bottomMargin: 5
                left: lscaleCardZone1.left
            }
            width: cardHeight + 20
            height: cardHeight + 20
            Component {
                id: fieldCardZoneDelegate1
                MultiResolutionImage {
                    source: {
                        if(index === 5) {
                            width = cardHeight + 20;
                            height = cardHeight + 20;
                            return "../../assets/img/gs_cardslot_player.png";
                        }
                        else
                            return "";
                    }
                    MultiResolutionImage {
                        height: cardHeight
                        fillMode: Image.PreserveAspectFit
                        anchors.centerIn: parent
                        source: (index === 5)?"../../assets/img/gs_icon_card_spell.png":""
                        ClientCard {
                            width: cardWidth; height: cardHeight;
                            anchors.centerIn: parent
                            isEnableDown: false
                            front: MultiResolutionImage {
                                width: cardWidth; height: cardHeight;
                                anchors.centerIn: parent
                                source : {
                                    if(index === 5 && code != 0)
                                        return "../../assets/pics/"+ code +".jpg";
                                    return "";
                                }
                            }
                        }
                    }
                }
            }
            ListView {
                delegate:fieldCardZoneDelegate1
                focus: true
                interactive: false
                model: clientField.szone1
            }
        }

        Item {
            id: spellZone1
            width: (cardHeight+20)*5 + 4*5
            height: cardHeight+20
            anchors {
                //                left: lscaleCardZone1.right
                //                leftMargin: 5
                horizontalCenter: duelField.horizontalCenter
                //                horizontalCenterOffset: 70
                top: lscaleCardZone1.top
            }
            Component {
                id: spellZoneDelegate1
                MultiResolutionImage {
                    width: cardHeight + 20
                    height: cardHeight + 20
                    source: "../../assets/img/gs_cardslot_player.png"
                    ClientCard {
                        isEnableDown: false
                        width: cardWidth; height: cardHeight
                        anchors.centerIn: parent
                        front: MultiResolutionImage {
                            width: cardWidth; height: cardHeight;
                            source: (code != 0)?"../../assets/pics/"+ code +".jpg":""
                            anchors.centerIn: parent
                        }
                        flipped: (position & pos_facedown)? true: false;
                        MultiResolutionImage {
                            id: spellZoneEquipImg1
                            fillMode: Image.PreserveAspectFit
                            anchors.fill: parent
                        }
                    }
                }
            }

            ListView {
                anchors.fill: parent
                delegate: spellZoneDelegate1
                orientation: Qt.Horizontal
                focus: true
                interactive: false
                spacing: 5
                model: clientField.szone1
            }
        }

        Item {
            id: rscaleCardZone1
            anchors {
                top: spellZone1.top
                right: duelField.right
                //                left: spellZone1.right
            }
            width: cardHeight + 20
            height: cardHeight + 20
            Component {
                id: rscaleCardZoneDelegate1
                MultiResolutionImage {
                    source: {
                        if(index === 7) {
                            width = cardHeight + 20;
                            height = cardHeight + 20;
                            return "../../assets/img/gs_cardslot_player.png";
                        }
                        else
                            return "";
                    }
                    ClientCard {
                        width: cardWidth; height: cardHeight;
                        anchors.centerIn: parent
                        isEnableDown: false
                        front: MultiResolutionImage {
                            width: cardWidth; height: cardHeight;
                            anchors.centerIn: parent
                            source : {
                                if(index === 7 && code != 0)
                                    return "../../assets/pics/"+ code +".jpg";
                                return "";
                            }
                        }
                    }

                }
            }
            ListView {
                delegate:rscaleCardZoneDelegate1
                focus: true
                interactive: false
                model: clientField.szone1
            }
        }

        Item {
            id: monsterZone1
            width: (cardHeight+20)*5 + 4*5
            height: cardHeight+20
            anchors {
                horizontalCenter: duelField.horizontalCenter
                //                horizontalCenterOffset: 70
                //                left: fieldCardZone1.right
                //                leftMargin: 5
                top: fieldCardZone1.top
            }
            Component {
                id: monsterZoneDelegate1
                MultiResolutionImage {
                    width: cardHeight + 20
                    height: cardHeight + 20
                    source: "../../assets/img/gs_cardslot_player.png"
                    ClientCard {
                        isEnableDown: false
                        width: cardWidth; height: cardHeight
                        anchors.centerIn: parent
                        front: MultiResolutionImage {
                            width: cardWidth; height: cardHeight;
                            source: (code != 0)?"../../assets/pics/"+ code +".jpg":""
                            anchors.centerIn: parent
                        }
                        rotation: (position & pos_defence)? 90: 0;
                        flipped: (position & pos_facedown)? true: false;
                        MultiResolutionImage {
                            id: monsterZoneEquipImg1
                            fillMode: Image.PreserveAspectFit
                            anchors.fill: parent
                        }
                    }
                }
            }

            ListView {
                anchors.fill: parent
                delegate: monsterZoneDelegate1
                orientation: Qt.Horizontal
                focus: true
                interactive: false
                spacing: 5
                model: clientField.mzone1
            }
        }

        MultiResolutionImage {
            id: graveyardCardZone1
            width: cardHeight + 20
            height: cardHeight + 20
            anchors {
                top: monsterZone1.top
                right: rscaleCardZone1.right
                //                left: monsterZone1.right
            }
            source: "../../assets/img/gs_cardslot_player.png"
            MultiResolutionImage {
                height: cardHeight
                fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent
                source: "../../assets/img/gs_icon_card_graveyard.png"
            }
            ClientCard {
                width: cardWidth; height: cardHeight;
                anchors.centerIn: parent
                isEnableDown: false
                front: MultiResolutionImage {
                    width: cardWidth; height: cardHeight;
                    anchors.centerIn: parent
                }
            }
        }

        MultiResolutionImage {
            id: deckCardZone1
            width: cardHeight + 20
            height: cardHeight + 20
            source: "../../assets/img/gs_cardslot_player.png"
            anchors {
                bottom: parent.bottom
                bottomMargin: 5
                left: graveyardCardZone1.left
            }
            Item {
                width: cardWidth; height: cardHeight
                anchors.centerIn: parent
                ListView {
                    anchors.fill: parent
                    model: clientField.deck1
                    spacing: -cardHeight + 0.5
                    delegate: MultiResolutionImage {
                        width: cardWidth
                        height: cardHeight
                        source: "../../assets/img/0000.png"
                    }
                }
            }
        }

        MultiResolutionImage {
            id: deckCardZone2
            width: cardHeight + 20
            height: cardHeight + 20
            source: "../../assets/img/gs_cardslot_opponent.png"
            anchors {
                top: parent.top
                topMargin: 5
                left: duelField.left
            }
            Item {
                width: cardWidth; height: cardHeight
                anchors.centerIn: parent
                ListView {
                    anchors.fill: parent
                    model: clientField.deck2
                    spacing: -cardHeight + 0.5
                    delegate: MultiResolutionImage {
                        width: cardWidth
                        height: cardHeight
                        source: "../../assets/img/0000.png"
                    }
                }
            }
        }

        Item {
            id: rscaleCardZone2
            anchors {
                top: deckCardZone2.bottom
                topMargin: 5
                left: deckCardZone2.left
            }
            width: cardHeight + 20
            height: cardHeight + 20
            Component {
                id: rscaleCardZoneDelegate2
                MultiResolutionImage {
                    source: {
                        if(index === 7) {
                            width = cardHeight + 20;
                            height = cardHeight + 20;
                            return "../../assets/img/gs_cardslot_opponent.png";
                        }
                        else
                            return "";
                    }
                    ClientCard {
                        width: cardWidth; height: cardHeight;
                        anchors.centerIn: parent
                        isEnableDown: false
                        front: MultiResolutionImage {
                            width: cardWidth; height: cardHeight;
                            anchors.centerIn: parent
                            source : {
                                if(index === 7 && code != 0)
                                    return "../../assets/pics/"+ code +".jpg";
                                return "";
                            }
                        }
                        rotation: 180
                    }

                }
            }
            ListView {
                delegate:rscaleCardZoneDelegate2
                focus: true
                interactive: false
                model: clientField.szone2
            }
        }

        MultiResolutionImage {
            id: graveyardCardZone2
            width: cardHeight + 20
            height: cardHeight + 20
            anchors {
                top: rscaleCardZone2.bottom
                topMargin: 5
                left: rscaleCardZone2.left
            }

            source: "../../assets/img/gs_cardslot_opponent.png"
            MultiResolutionImage {
                height: cardHeight
                fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent
                source: "../../assets/img/gs_icon_card_graveyard.png"
            }
            ClientCard {
                width: cardWidth; height: cardHeight;
                anchors.centerIn: parent
                isEnableDown: false
                front: MultiResolutionImage {
                    width: cardWidth; height: cardHeight;
                    anchors.centerIn: parent
                }
                rotation: 180
            }
        }

        Item {
            id: spellZone2
            width: (cardHeight+20)*5 + 4*5
            height: cardHeight+20
            anchors {
                horizontalCenter: duelField.horizontalCenter
                //                horizontalCenterOffset: 70
                //                left: rscaleCardZone2.right
                //                leftMargin: 5
                top: rscaleCardZone2.top
            }
            Component {
                id: spellZoneDelegate2
                MultiResolutionImage {
                    width: cardHeight + 20
                    height: cardHeight + 20
                    source: "../../assets/img/gs_cardslot_opponent.png"
                    ClientCard {
                        isEnableDown: false
                        width: cardWidth; height: cardHeight
                        anchors.centerIn: parent
                        front: MultiResolutionImage {
                            width: cardWidth; height: cardHeight;
                            source: (code != 0)?"../../assets/pics/"+ code +".jpg":""
                            anchors.centerIn: parent
                        }
                        flipped: (position & pos_facedown)? true: false;
                        MultiResolutionImage {
                            id: spellZoneEquipImg2
                            fillMode: Image.PreserveAspectFit
                            anchors.fill: parent
                        }
                    }
                }
            }

            ListView {
                anchors.fill: parent
                delegate: spellZoneDelegate2
                orientation: Qt.Horizontal
                focus: true
                interactive: false
                spacing: 5
                model: clientField.szone2
                layoutDirection: Qt.RightToLeft
            }
        }

        Item {
            id: lscaleCardZone2
            anchors {
                top: spellZone2.top
                right: duelField.right
                //                left: spellZone2.right
            }
            width: cardHeight + 20
            height: cardHeight + 20
            Component {
                id: lscaleCardZoneDelegate2
                MultiResolutionImage {
                    source: {
                        if(index === 6) {
                            width = cardHeight + 20;
                            height = cardHeight + 20;
                            return "../../assets/img/gs_cardslot_opponent.png";
                        }
                        else
                            return "";
                    }
                    ClientCard {
                        width: cardWidth; height: cardHeight;
                        anchors.centerIn: parent
                        isEnableDown: false
                        front: MultiResolutionImage {
                            width: cardWidth; height: cardHeight;
                            anchors.centerIn: parent
                            source : {
                                if(index === 6 && code != 0)
                                    return "../../assets/pics/"+ code +".jpg";
                                return "";
                            }
                        }
                        rotation: 180
                    }

                }
            }
            ListView {
                delegate:lscaleCardZoneDelegate2
                focus: true
                interactive: false
                model: clientField.szone2
            }
        }

        Item {
            id: monsterZone2
            width: (cardHeight+20)*5 + 4*5
            height: cardHeight+20
            anchors {
                horizontalCenter: duelField.horizontalCenter
                //                horizontalCenterOffset: 70
                //                left: graveyardCardZone2.right
                //                leftMargin: 5
                top: graveyardCardZone2.top
            }
            Component {
                id: monsterZoneDelegate2
                MultiResolutionImage {
                    width: cardHeight + 20
                    height: cardHeight + 20
                    source: "../../assets/img/gs_cardslot_opponent.png"
                    ClientCard {
                        isEnableDown: false
                        width: cardWidth; height: cardHeight
                        anchors.centerIn: parent
                        front: MultiResolutionImage {
                            width: cardWidth; height: cardHeight;
                            source: (code != 0)?"../../assets/pics/"+ code +".jpg":""
                            anchors.centerIn: parent
                        }
                        rotation: (position & pos_defence)? 90: 180;
                        flipped: (position & pos_facedown)? true: false;
                        MultiResolutionImage {
                            id: monsterZoneEquipImg2
                            fillMode: Image.PreserveAspectFit
                            anchors.fill: parent
                        }
                    }
                }
            }

            ListView {
                anchors.fill: parent
                delegate: monsterZoneDelegate2
                orientation: Qt.Horizontal
                focus: true
                interactive: false
                spacing: 5
                model: clientField.mzone2
                layoutDirection: Qt.RightToLeft
            }
        }

        Item {
            id: fieldCardZone2
            anchors {
                top: monsterZone2.top
                right: lscaleCardZone2.right
                //                left: monsterZone2.right
            }
            width: cardHeight + 20
            height: cardHeight + 20
            Component {
                id: fieldCardZoneDelegate2
                MultiResolutionImage {
                    source: {
                        if(index === 5) {
                            width = cardHeight + 20;
                            height = cardHeight + 20;
                            return "../../assets/img/gs_cardslot_opponent.png";
                        }
                        else
                            return "";
                    }
                    MultiResolutionImage {
                        height: cardHeight
                        fillMode: Image.PreserveAspectFit
                        anchors.centerIn: parent
                        source: (index === 5)?"../../assets/img/gs_icon_card_spell.png":""
                        ClientCard {
                            width: cardWidth; height: cardHeight;
                            anchors.centerIn: parent
                            isEnableDown: false
                            front: MultiResolutionImage {
                                width: cardWidth; height: cardHeight;
                                anchors.centerIn: parent
                                source : {
                                    if(index === 5 && code != 0)
                                        return "../../assets/pics/"+ code +".jpg";
                                    return "";
                                }
                            }
                            rotation: 180
                        }
                    }
                }
            }
            ListView {
                delegate:fieldCardZoneDelegate2
                focus: true
                interactive: false
                model: clientField.szone2
            }
        }

        MultiResolutionImage {
            id: extraCardZone2
            width: cardHeight + 20
            height: cardHeight + 20
            source: "../../assets/img/gs_cardslot_opponent.png"
            anchors {
                top: parent.top
                topMargin: 5
                right: lscaleCardZone2.right
                //                left: lscaleCardZone2.left
            }
            MultiResolutionImage {
                height: cardHeight
                fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent
                source: "../../assets/img/gs_icon_card_summon.png"
                rotation: 180
            }
            Item {
                width: cardWidth; height: cardHeight
                anchors.centerIn: parent
                ListView {
                    anchors.fill: parent
                    model: clientField.extra2
                    spacing: -cardHeight + 0.5
                    delegate: MultiResolutionImage {
                        width: cardWidth
                        height: cardHeight
                        source: "../../assets/img/0000.png"
                    }
                }
            }
        }

        Item {
            height: cardHeight
            width: (cardWidth * hand1List.count > maxHandWidth)? maxHandWidth: cardWidth * hand1List.count
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 4
            anchors.horizontalCenter: parent.horizontalCenter
            //            anchors.horizontalCenterOffset: 70

            Component {
                id: hand1Delegate
                ClientCard {
                    isEnableDown: true
                    width: cardWidth; height: cardHeight
                    front: MultiResolutionImage {
                        id: clientCardImg1
                        width: cardWidth; height: cardHeight;
                        source: (code != 0)?"../../assets/pics/"+ code +".jpg":""/*:parent.flipped=true*/; //Will issue warning
                        anchors.centerIn: parent
                    }
                }
            }

            ListView {
                id: hand1List
                anchors.fill: parent
                delegate: hand1Delegate
                orientation: Qt.Horizontal
                focus: true
                interactive: false
                model: clientField.hand1
                spacing: (cardWidth * hand1List.count > maxHandWidth)? -(cardWidth * hand1List.count - maxHandWidth)/(hand1List.count - 1): 2
            }
        }

        Item {
            height: cardHeight
            width: (cardWidth * hand2List.count > maxHandWidth)? maxHandWidth: cardWidth * hand2List.count
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            //            anchors.horizontalCenterOffset: 70

            Component {
                id: hand2Delegate
                ClientCard {
                    isEnableDown: true
                    downYBehaviour: true
                    width: cardWidth; height: cardHeight
                    front: MultiResolutionImage {
                        id: clientCardImg2
                        width: cardWidth; height: cardHeight;
                        source: (code != 0)?"../../assets/pics/"+ code +".jpg":""/*:parent.flipped=true*/; //Will issue warning
                        anchors.centerIn: parent
                    }
                }
            }

            ListView {
                id: hand2List
                anchors.fill: parent
                delegate: hand2Delegate
                orientation: Qt.Horizontal
                focus: true
                interactive: false
                model: clientField.hand2
                spacing: (cardWidth * hand2List.count > maxHandWidth)? -(cardWidth * hand2List.count - maxHandWidth)/(hand2List.count - 1): 2
            }
        }
    }

    DialogBox {
        id: dialogBox
    }

    Connections {
        target: game
        onQwMessageChanged: {
            if(game.qwMessage() === true) {
                messageBox.text = game.qstMessage();
                messageBox.x = gameScene.gameWindowAnchorItem.width/2 - messageBox.width/2
            }
            else {
                messageBox.x = -messageBox.width;
            }
        }
        onQshowCardChanged: {
            var showCard = game.getShowCard();
            switch(showCard) {
            case 101: {
                var showCardCode = game.getShowCardCode();
                switch(showCardCode) {
                case 1:
                    dialogBox.activateMessage(qsTr("You Win!"));
                    break;
                case 2:
                    dialogBox.activateMessage(qsTr("You Lose!"));
                    break;
                case 3:
                    dialogBox.activateMessage(qsTr("Draw Game"));
                    break;
                case 4:
                    dialogBox.activateMessage(qsTr("Draw Phase"));
                    break;
                case 5:
                    dialogBox.activateMessage(qsTr("Standby Phase"));
                    break;
                case 6:
                    dialogBox.activateMessage(qsTr("Main Phase 1"));
                    break;
                case 7:
                    dialogBox.activateMessage(qsTr("Battle Phase"));
                    break;
                case 8:
                    dialogBox.activateMessage(qsTr("Main Phase 2"));
                    break;
                case 9:
                    dialogBox.activateMessage(qsTr("End Phase"));
                    break;
                case 10:
                    dialogBox.activateMessage(qsTr("Next Players Turn"));
                    break;
                case 11:
                    dialogBox.activateMessage(qsTr("Duel Start"));
                    break;
                case 12:
                    dialogBox.activateMessage(qsTr("Duel1 Start"));
                    break;
                case 13:
                    dialogBox.activateMessage(qsTr("Duel2 Start"));
                    break;
                case 14:
                    dialogBox.activateMessage(qsTr("Duel3 Start"));
                    break;
                }
            }
            }
        }
    }

    Connections {
        target: duelInfo
        onLp1Changed: {
            if(parseInt(lp1Text.text) > duelInfo.lp1() && duelInfo.lp1() < 8000)
                progressBar1.x -= progressBar1.width*(1 - duelInfo.lp1()/8000);
            else if(parseInt(lp1Text.text) > duelInfo.lp1() && duelInfo.lp1() >= 8000)
                progressBar1.x = player1Image.width;
            else if(parseInt(lp1Text.text) < duelInfo.lp1() && duelInfo.lp1() < 8000)
                progressBar1.x += progressBar1.width*(1 - duelInfo.lp1()/8000);
            else if(parseInt(lp1Text.text) < duelInfo.lp1() && duelInfo.lp1() >= 8000)
                progressBar1.x = player1Image.width;
            else if(parseInt(lp1Text.text) === duelInfo.lp1())
            {}
            lp1Text.text = duelInfo.lp1();
        }
        onLp2Changed: {
            if(parseInt(lp2Text.text) > duelInfo.lp2() && duelInfo.lp2() < 8000)
                progressBar2.x -= progressBar2.width*(1 - duelInfo.lp2()/8000);
            else if(parseInt(lp2Text.text) > duelInfo.lp2() && duelInfo.lp2() >= 8000)
                progressBar2.x = player2Image.width;
            else if(parseInt(lp2Text.text) < duelInfo.lp2() && duelInfo.lp2() < 8000)
                progressBar2.x += progressBar2.width*(1 - duelInfo.lp2()/8000);
            else if(parseInt(lp2Text.text) < duelInfo.lp2() && duelInfo.lp2() >= 8000)
                progressBar2.x = player2Image.width;
            else if(parseInt(lp2Text.text) === duelInfo.lp2())
            {}
            lp2Text.text = duelInfo.lp2();
        }
        onClientNameChanged: {
            clientname = duelInfo.clientName();
        }
    }
    onExitClicked: {
        progressBar1.x = player1Image.width;
        lp1Text.text = "8000";
        progressBar2.x = player2Image.width;
        lp2Text.text = "8000";
        desCardImg.source = "";
        desLevelRank.source = "";
        levelRankText.text = "";
        desAtk.text = "";
        desDef.text = "";
        cardLogo1.source = "";
        cardLogo1Text.text = "";
        cardLogo2.source = "";
        cardLogo2Text.text = "";
        cardName.text = "";
        cardType.text = "";
        desText.text = "";
    }
}
