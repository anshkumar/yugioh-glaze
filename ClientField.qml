import QtQuick 2.0

Item {
    property real cardWidth: 70
    property real cardHeight: 102
    property real maxHandWidth: width - 11*cardWidth
    property string charImage1: "file:img/default_avatar_f_0.png"
    property string charImage2: "file:img/default_avatar_m_0.png"
    signal exitClicked;
    property string clientname: ""
    property string hostname: ""

    FontLoader {
        id: contentFont
        source: "file:fonts/ChaneyWide.ttf"
    }
    FontLoader {
        id: descriptionFont
        source: "file:fonts/StoneSerif.ttf"
    }

    Item {
        id: cardplayerDetailZone
        height: parent.height
        width: 300
        Image {
            id: charBack1
            source: "file:img/gamescreen_char_bg.png"
            anchors {
                right: parent.right
                bottom: parent.bottom
            }
            height: player1Image.height
            width: 300
        }
        Image {
            id: charName1
            source: "file:img/gs_char_namebox.png"
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
        Image {
            id: progressBar1
            source: "file:img/gamescreen_lifepoints_meter_player.png"
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
        Image {
            source: "file:img/gamescreen_lifepoints_cover.png"
            width: progressBar1.width + 7
            height: progressBar1.height + 5
            anchors {
                top: progressBar1.top
                left: player1Image.right
            }
        }
        Image {
            id: player1Image
            anchors {
                bottom: parent.bottom
                left: parent.left
            }
            width: 100
            height: 100
            source: "file:img/gs_char_border.png"
            Rectangle {
                width: 88
                height: 88
                color: "black"
                anchors.centerIn: parent
            }

            Image {
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

            Image {
                id: lp1Heart
                source: "file:img/gs_LP_icon_blue.png"
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

        Image {
            id: charBack2
            source: "file:img/gamescreen_char_bg.png"
            anchors {
                top: parent.top
                right: parent.right
            }
            height: player2Image.height
            width: 300
        }
        Image {
            id: charName2
            source: "file:img/gs_char_namebox.png"
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
        Image {
            id: progressBar2
            source: "file:img/gamescreen_lifepoints_meter_opponent.png"
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
        Image {
            source: "file:img/gamescreen_lifepoints_cover.png"
            width: progressBar2.width + 7
            height: progressBar2.height + 5
            anchors {
                top: progressBar2.top
                left: player2Image.right
            }
        }
        Image {
            id: player2Image
            anchors {
                top : parent.top
                left: parent.left
            }
            width: 100
            height: 100
            source: "file:img/gs_char_border.png"
            Rectangle {
                width: 88
                height: 88
                color: "black"
                anchors.centerIn: parent
            }

            Image {
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

            Image {
                id: lp2Heart
                source: "file:img/gs_LP_icon_red.png"
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

        Image {
            id: description
            source: "file:img/gs_card_info.png"
            height: parent.height - player1Image.height - player2Image.height - 30
            anchors {
                right: parent.right
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            Image {
                id: desCardImg
                anchors {
                    top: parent.top
                    topMargin: 20
                    left: parent.left
                    leftMargin: 25
                }
                scale: 0.9
            }
            Image {
                id: desLevelRank
                width: 20
                height: 20
                anchors {
                    left: parent.left
                    leftMargin: 30
                    top: parent.top
                    topMargin: 310
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

            Image {
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
            Image {
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
            Image {
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
            Image {
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
        }
    }

    MessageBox {
        id: messageBox
        onClicked: {
            messageBox.visible = false;
//            game.mySet();
//            game.setQwMessage(false);
        }
    }

    Image {
        id: extraCardZone1
        width: cardHeight + 20
        height: cardHeight + 20
        source: "file:img/gs_cardslot_player.png"
        anchors {
            bottom: parent.bottom
            bottomMargin: 5
            left: cardplayerDetailZone.right
            leftMargin: 10
        }
        Image {
            height: cardHeight
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
            source: "file:img/gs_icon_card_summon.png"
        }
        Item {
            width: cardWidth; height: cardHeight
            anchors.centerIn: parent
            ListView {
                anchors.fill: parent
                model: clientField.extra1
                spacing: -cardHeight + 0.5
                delegate: Image {
                    width: cardWidth
                    height: cardHeight
                    source: "file:img/0000.png"
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
            Image {
                source: {
                    if(index === 6) {
                        width = cardHeight + 20;
                        height = cardHeight + 20;
                        return "file:img/gs_cardslot_player.png";
                    }
                    else
                        return "";
                }
                    ClientCard {
                        width: cardWidth; height: cardHeight;
                        anchors.centerIn: parent
                        isEnableDown: false
                        front: Image {
                            width: cardWidth; height: cardHeight;
                            anchors.centerIn: parent
                            source : (index === 6 && code != 0)?"file:pics/"+ code +".jpg":""
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
            Image {
                source: {
                    if(index === 5) {
                        width = cardHeight + 20;
                        height = cardHeight + 20;
                        return "file:img/gs_cardslot_player.png";
                    }
                    else
                        return "";
                }
                Image {
                    height: cardHeight
                    fillMode: Image.PreserveAspectFit
                    anchors.centerIn: parent
                    source: (index === 5)?"file:img/gs_icon_card_spell.png":""
                    ClientCard {
                        width: cardWidth; height: cardHeight;
                        anchors.centerIn: parent
                        isEnableDown: false
                        front: Image {
                            width: cardWidth; height: cardHeight;
                            anchors.centerIn: parent
                            source : (index === 5 && code != 0)?"file:pics/"+ code +".jpg":""
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
            left: lscaleCardZone1.right
            leftMargin: 5
            top: lscaleCardZone1.top
        }
        Component {
            id: spellZoneDelegate1
            Image {
                width: cardHeight + 20
                height: cardHeight + 20
                source: "file:img/gs_cardslot_player.png"
                ClientCard {
                    isEnableDown: false
                    width: cardWidth; height: cardHeight
                    anchors.centerIn: parent
                    front: Image {
                        width: cardWidth; height: cardHeight;
                        source: (code != 0)?"file:pics/"+ code +".jpg":""
                        anchors.centerIn: parent
                    }
                    flipped: (position & pos_facedown)? true: false;
                    Image {
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
            left: spellZone1.right
        }
        width: cardHeight + 20
        height: cardHeight + 20
        Component {
            id: rscaleCardZoneDelegate1
            Image {
                source: {
                    if(index === 7) {
                        width = cardHeight + 20;
                        height = cardHeight + 20;
                        return "file:img/gs_cardslot_player.png";
                    }
                    else
                        return "";
                }
                    ClientCard {
                        width: cardWidth; height: cardHeight;
                        anchors.centerIn: parent
                        isEnableDown: false
                        front: Image {
                            width: cardWidth; height: cardHeight;
                            anchors.centerIn: parent
                            source : (index === 7 && code != 0)?"file:pics/"+ code +".jpg":""
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
            left: fieldCardZone1.right
            leftMargin: 5
            top: fieldCardZone1.top
        }
        Component {
            id: monsterZoneDelegate1
            Image {
                width: cardHeight + 20
                height: cardHeight + 20
                source: "file:img/gs_cardslot_player.png"
                ClientCard {
                    isEnableDown: false
                    width: cardWidth; height: cardHeight
                    anchors.centerIn: parent
                    front: Image {
                        width: cardWidth; height: cardHeight;
                        source: (code != 0)?"file:pics/"+ code +".jpg":""
                        anchors.centerIn: parent
                    }
                    rotation: (position & pos_defence)? 90: 0;
                    flipped: (position & pos_facedown)? true: false;
                    Image {
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

    Image {
        id: graveyardCardZone1
        width: cardHeight + 20
        height: cardHeight + 20
        anchors {
            top: monsterZone1.top
            left: monsterZone1.right
        }
        source: "file:img/gs_cardslot_player.png"
        Image {
            height: cardHeight
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
            source: "file:img/gs_icon_card_graveyard.png"
        }
        ClientCard {
            width: cardWidth; height: cardHeight;
            anchors.centerIn: parent
            isEnableDown: false
            front: Image {
                width: cardWidth; height: cardHeight;
                anchors.centerIn: parent
            }
        }
    }

    Image {
        id: deckCardZone1
        width: cardHeight + 20
        height: cardHeight + 20
        source: "file:img/gs_cardslot_player.png"
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
                delegate: Image {
                    width: cardWidth
                    height: cardHeight
                    source: "file:img/0000.png"
                }
            }
        }
    }

    Image {
        id: deckCardZone2
        width: cardHeight + 20
        height: cardHeight + 20
        source: "file:img/gs_cardslot_opponent.png"
        anchors {
            top: parent.top
            topMargin: 5
            left: cardplayerDetailZone.right
            leftMargin: 10
        }
        Item {
            width: cardWidth; height: cardHeight
            anchors.centerIn: parent
            ListView {
                anchors.fill: parent
                model: clientField.deck2
                spacing: -cardHeight + 0.5
                delegate: Image {
                    width: cardWidth
                    height: cardHeight
                    source: "file:img/0000.png"
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
            Image {
                source: {
                    if(index === 7) {
                        width = cardHeight + 20;
                        height = cardHeight + 20;
                        return "file:img/gs_cardslot_opponent.png";
                    }
                    else
                        return "";
                }
                    ClientCard {
                        width: cardWidth; height: cardHeight;
                        anchors.centerIn: parent
                        isEnableDown: false
                        front: Image {
                            width: cardWidth; height: cardHeight;
                            anchors.centerIn: parent
                            source : (index === 7 && code != 0)?"file:pics/"+ code +".jpg":""
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

    Image {
        id: graveyardCardZone2
        width: cardHeight + 20
        height: cardHeight + 20
        anchors {
            top: rscaleCardZone2.bottom
            topMargin: 5
            left: rscaleCardZone2.left
        }

        source: "file:img/gs_cardslot_opponent.png"
        Image {
            height: cardHeight
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
            source: "file:img/gs_icon_card_graveyard.png"
        }
        ClientCard {
            width: cardWidth; height: cardHeight;
            anchors.centerIn: parent
            isEnableDown: false
            front: Image {
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
            left: rscaleCardZone2.right
            leftMargin: 5
            top: rscaleCardZone2.top
        }
        Component {
            id: spellZoneDelegate2
            Image {
                width: cardHeight + 20
                height: cardHeight + 20
                source: "file:img/gs_cardslot_opponent.png"
                ClientCard {
                    isEnableDown: false
                    width: cardWidth; height: cardHeight
                    anchors.centerIn: parent
                    front: Image {
                        width: cardWidth; height: cardHeight;
                        source: (code != 0)?"file:pics/"+ code +".jpg":""
                        anchors.centerIn: parent
                    }
                    flipped: (position & pos_facedown)? true: false;
                    Image {
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
            left: spellZone2.right
        }
        width: cardHeight + 20
        height: cardHeight + 20
        Component {
            id: lscaleCardZoneDelegate2
            Image {
                source: {
                    if(index === 6) {
                        width = cardHeight + 20;
                        height = cardHeight + 20;
                        return "file:img/gs_cardslot_opponent.png";
                    }
                    else
                        return "";
                }
                    ClientCard {
                        width: cardWidth; height: cardHeight;
                        anchors.centerIn: parent
                        isEnableDown: false
                        front: Image {
                            width: cardWidth; height: cardHeight;
                            anchors.centerIn: parent
                            source : (index === 6 && code != 0)?"file:pics/"+ code +".jpg":""
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
            left: graveyardCardZone2.right
            leftMargin: 5
            top: graveyardCardZone2.top
        }
        Component {
            id: monsterZoneDelegate2
            Image {
                width: cardHeight + 20
                height: cardHeight + 20
                source: "file:img/gs_cardslot_opponent.png"
                ClientCard {
                    isEnableDown: false
                    width: cardWidth; height: cardHeight
                    anchors.centerIn: parent
                    front: Image {
                        width: cardWidth; height: cardHeight;
                        source: (code != 0)?"file:pics/"+ code +".jpg":""
                        anchors.centerIn: parent
                    }
                    rotation: (position & pos_defence)? 90: 180;
                    flipped: (position & pos_facedown)? true: false;
                    Image {
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
            left: monsterZone2.right
        }
        width: cardHeight + 20
        height: cardHeight + 20
        Component {
            id: fieldCardZoneDelegate2
            Image {
                source: {
                    if(index === 5) {
                        width = cardHeight + 20;
                        height = cardHeight + 20;
                        return "file:img/gs_cardslot_opponent.png";
                    }
                    else
                        return "";
                }
                Image {
                    height: cardHeight
                    fillMode: Image.PreserveAspectFit
                    anchors.centerIn: parent
                    source: (index === 5)?"file:img/gs_icon_card_spell.png":""
                    ClientCard {
                        width: cardWidth; height: cardHeight;
                        anchors.centerIn: parent
                        isEnableDown: false
                        front: Image {
                            width: cardWidth; height: cardHeight;
                            anchors.centerIn: parent
                            source : (index === 5 && code != 0)?"file:pics/"+ code +".jpg":""
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

    Image {
        id: extraCardZone2
        width: cardHeight + 20
        height: cardHeight + 20
        source: "file:img/gs_cardslot_opponent.png"
        anchors {
            top: parent.top
            topMargin: 5
            left: lscaleCardZone2.left
        }
        Image {
            height: cardHeight
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
            source: "file:img/gs_icon_card_summon.png"
            rotation: 180
        }
        Item {
            width: cardWidth; height: cardHeight
            anchors.centerIn: parent
            ListView {
                anchors.fill: parent
                model: clientField.extra2
                spacing: -cardHeight + 0.5
                delegate: Image {
                    width: cardWidth
                    height: cardHeight
                    source: "file:img/0000.png"
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
        anchors.horizontalCenterOffset: 70

        Component {
            id: hand1Delegate
            ClientCard {
                isEnableDown: true
                width: cardWidth; height: cardHeight
                front: Image {
                    id: clientCardImg1
                    width: cardWidth; height: cardHeight;
                    source: (code != 0)?"file:pics/"+ code +".jpg":parent.flipped=true; //Will issue warning
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
        anchors.horizontalCenterOffset: 70

        Component {
            id: hand2Delegate
            ClientCard {
                isEnableDown: true
                downYBehaviour: true
                width: cardWidth; height: cardHeight
                front: Image {
                    id: clientCardImg2
                    width: cardWidth; height: cardHeight;
                    source: (code != 0)?"file:pics/"+ code +".jpg":parent.flipped=true; //Will issue warning
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

    Connections {
        target: game
        onQwMessageChanged: {
//            if(game.qwMessage() === true) {
//                messageBox.text = game.qstMessage();
//                messageBox.visible = true;
//            }
//            else {
//                messageBox.visible = false;
//            }
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

