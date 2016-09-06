import VPlay 2.0
import QtQuick 2.0
import "../common"

SceneBase {
    id: gameScene

    property real cardWidth: 45
    property real cardHeight: 65
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
    property bool cardSelectDialogBoxCancelable: true
    property var selectedCards: []
    property bool selectReady: false

    //Messages
    property int msg_retry:				1
    property int msg_hint:				2
    property int msg_waiting:			3
    property int msg_start:				4
    property int msg_win:				5
    property int msg_update_data:		6
    property int msg_update_card:		7
    property int msg_request_deck:		8
    property int msg_select_battlecmd:	10
    property int msg_select_idlecmd:	11
    property int msg_select_effectyn:	12
    property int msg_select_yesno:		13
    property int msg_select_option:		14
    property int msg_select_card:		15
    property int msg_select_chain:		16
    property int msg_select_place:		18
    property int msg_select_position:	19
    property int msg_select_tribute:	20
    property int msg_sort_chain:		21
    property int msg_select_counter:	22
    property int msg_select_sum:		23
    property int msg_select_disfield:	24
    property int msg_sort_card:			25
    property int msg_confirm_decktop:	30
    property int msg_confirm_cards:		31
    property int msg_shuffle_deck:		32
    property int msg_shuffle_hand:		33
    property int msg_refresh_deck:		34
    property int msg_swap_grave_deck:	35
    property int msg_shuffle_set_card:	36
    property int msg_reverse_deck:		37
    property int msg_deck_top:			38
    property int msg_new_turn:			40
    property int msg_new_phase:			41
    property int msg_move:				50
    property int msg_pos_change:		53
    property int msg_set:				54
    property int msg_swap:				55
    property int msg_field_disabled:	56
    property int msg_summoning:			60
    property int msg_summoned:			61
    property int msg_spsummoning:		62
    property int msg_spsummoned:		63
    property int msg_flipsummoning:		64
    property int msg_flipsummoned:		65
    property int msg_chaining:			70
    property int msg_chained:			71
    property int msg_chain_solving:		72
    property int msg_chain_solved:		73
    property int msg_chain_end:			74
    property int msg_chain_negated:		75
    property int msg_chain_disabled:	76
    property int msg_card_selected:		80
    property int msg_random_selected:	81
    property int msg_become_target:		83
    property int msg_draw:				90
    property int msg_damage:			91
    property int msg_recover:			92
    property int msg_equip:				93
    property int msg_lpupdate:			94
    property int msg_unequip:			95
    property int msg_card_target:		96
    property int msg_cancel_target:		97
    property int msg_pay_lpcost:		100
    property int msg_add_counter:		101
    property int msg_remove_counter:	102
    property int msg_attack:			110
    property int msg_battle:			111
    property int msg_attack_disabled:	112
    property int msg_damage_step_start:	113
    property int msg_damage_step_end:	114
    property int msg_missed_effect:		120
    property int msg_be_chain_target:	121
    property int msg_create_relation:	122
    property int msg_release_relation:	123
    property int msg_toss_coin:			130
    property int msg_toss_dice:			131
    property int msg_announce_race:		140
    property int msg_announce_attrib:	141
    property int msg_announce_card:		142
    property int msg_announce_number:	143
    property int msg_card_hint:			160
    property int msg_tag_swap:			161
    property int msg_reload_field:		162
    property int msg_ai_name:			163
    property int msg_show_hint:			164
    property int msg_match_kill:		170
    property int msg_custom_msg:		180

    //Phase
    property int phase_draw:		0x01
    property int phase_standby:		0x02
    property int phase_main1:		0x04
    property int phase_battle:		0x08
    property int phase_damage:		0x10
    property int phase_damage_cal:	0x20
    property int phase_main2:		0x40
    property int phase_end:			0x80

    function setPuzzle(fileName) {
        game.startSinglePlay(fileName);
    }

    function cardSelectDialogBoxBehavior(list, lModel, viewMode) {
        if(list.count > 0) {
            if(cardSelectDialogBox.slidedOut === true && viewMode === true) {
                cardSelectDialogBox.model = lModel;
                cardSelectDialogBox.slideIn();
            }
            else {
                if(duelInfo.getCurMsg() === msg_select_card) {
                    if(selectedCards.length == 0) {
                        if(cardSelectDialogBoxCancelable) {
                            game.setResponseI(-1);
                            cardSelectDialogBox.slideOut();
                            gameScene.clearSelectedCards();
                        }
                    }
                    if(selectReady) {
                        var respBuf = [];
                        respBuf[0] = selectedCards.length;
                        for(var i = 0; i < selectedCards.length; i += 1)
                            respBuf[i + 1] = selectedCards[i].selectSeq;
                        game.setResponseB(respBuf, selectedCards.length + 1);
                        cardSelectDialogBox.slideOut();
                        gameScene.clearSelectedCards();
                    }
                }else {
                    cardSelectDialogBox.slideOut();
                    gameScene.clearSelectedCards();
                }
            }
        }
    }

    // select item
    signal selectCard(variant userData)
    onSelectCard: {
        gameScene.selectedCards.push(userData)
        console.log("# Currently " + gameScene.selectedCards.length + " items are selected");
    }

    // deselect item
    signal deselectCard(variant userData)
    onDeselectCard: {
        for (var i = 0; i < gameScene.selectedCards.length; i += 1) {
            //             console.log("# Checking index "  + index + " with user " + aSelectedItemList[index].userId + " comparing with " + userData.userId);
            if (gameScene.selectedCards[i].selectSeq == userData) {
                gameScene.selectedCards.splice(i, 1);
                break;
            }
        }
        console.log("# Currently " + gameScene.selectedCards.length + " items are selected");
    }

    // signal to clear
    signal clearSelectedCards()
    onClearSelectedCards: {
        gameScene.selectedCards = [];
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
        Image {
            id: charBack1
            source: "../../assets/img/gamescreen_char_bg.png"
            anchors {
                right: parent.right
                bottom: parent.bottom
            }
            height: player1Image.height
            width: 300
        }
        Image {
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
        Image {
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
        Image {
            source: "../../assets/img/gamescreen_lifepoints_cover.png"
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
            source: "../../assets/img/gs_char_border.png"
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
        Image {
            id: charBack2
            source: "../../assets/img/gamescreen_char_bg.png"
            anchors {
                top: parent.top
                right: parent.right
            }
            height: player2Image.height
            width: 300
        }
        Image {
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
        Image {
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
        Image {
            source: "../../assets/img/gamescreen_lifepoints_cover.png"
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
            source: "../../assets/img/gs_char_border.png"
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

    Image {
        id: description
        source: "../../assets/img/gs_card_info.png"
        height: 370
        width: detailWidth
        anchors {
            left: gameScene.gameWindowAnchorItem.left
            verticalCenter: gameScene.gameWindowAnchorItem.verticalCenter
        }
        Image {
            id: desCardImg
            anchors {
                top: parent.top
                topMargin: desImgTopMargin
                left: parent.left
                leftMargin: desImgLeftMargin
            }
            scale: desImgScale
        }
        Image {
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

        Image {
            id: extraCardZone1
            width: cardHeight + 20
            height: cardHeight + 20
            source: "../../assets/img/gs_cardslot_player.png"
            anchors {
                bottom: parent.bottom
                bottomMargin: 5
                left: duelField.left
            }
            Image {
                height: cardHeight
                fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent
                source: "../../assets/img/gs_icon_card_summon.png"
            }
            Item {
                width: cardWidth; height: cardHeight
                anchors.centerIn: parent
                ListView {
                    id: extraCardZone1List
                    anchors.fill: parent
                    model: clientField.extra1
                    spacing: -cardHeight + 0.5
                    delegate: Image {
                        width: cardWidth
                        height: cardHeight
                        source: "../../assets/img/0000.png"
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: cardSelectDialogBoxBehavior(extraCardZone1List, clientField.extra1, true)
                }
                Image {
                    id: extraRotationAnimation
                    anchors.fill: parent
                    source: "../../assets/img/act.png"
                    enabled: false
                    visible: false
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
                            return "../../assets/img/gs_cardslot_player.png";
                        }
                        else
                            return "";
                    }
                    ClientCard {
//                        cWidth: cardWidth; cHeight: cardHeight;
                        anchors.centerIn: parent
                        isEnableDown: false
                        source: {
                            if(index == 6 && code != 0)
                                return "../../assets/pics/"+ code +".jpg";
                            return "";
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
                            return "../../assets/img/gs_cardslot_player.png";
                        }
                        else
                            return "";
                    }
                    Image {
                        height: cardHeight
                        fillMode: Image.PreserveAspectFit
                        anchors.centerIn: parent
                        source: (index === 5)?"../../assets/img/gs_icon_card_spell.png":""
                        ClientCard {
                            CommandMenu {
                                anchors.bottom: parent.top
                                width: parent.width
                            }
//                            width: cardWidth; height: cardHeight;
                            anchors.centerIn: parent
                            isEnableDown: false
                            source: {
                                if(index === 5 && code != 0)
                                    return "../../assets/pics/"+ code +".jpg";
                                return "";
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
                Column {
                    CommandMenu {
                        id: spell1CommandMenu
                        width: cardWidth
                    }
                    Image {
                        width: cardHeight + 20
                        height: cardHeight + 20
                        source: "../../assets/img/gs_cardslot_player.png"
                        ClientCard {
                            isEnableDown: false
//                            width: cardWidth; height: cardHeight
                            anchors.centerIn: parent
                            source: (code != 0)?"../../assets/pics/"+ code +".jpg":""
                            flipped: (position & pos_facedown)? true: false;
                            Image {
                                id: spellZoneEquipImg1
                                fillMode: Image.PreserveAspectFit
                                anchors.fill: parent
                            }
//                            onShowMenu: spell1CommandMenu.showMenu(flag)
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
                Image {
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
//                        width: cardWidth; height: cardHeight;
                        anchors.centerIn: parent
                        isEnableDown: false
                        source: {
                            if(index === 7 && code != 0)
                                return "../../assets/pics/"+ code +".jpg";
                            return "";
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
                Image {
                    width: cardHeight + 20
                    height: cardHeight + 20
                    source: "../../assets/img/gs_cardslot_player.png"
                    ClientCard {
                        isEnableDown: false
                        //                            width: cardWidth; height: cardHeight
                        //                            anchors.centerIn: parent
                        source:(code != 0)?"../../assets/pics/"+ code +".jpg":""
                        rotation: (position & pos_defence)? 90: 0;
                        flipped: (position & pos_facedown)? true: false;
                        Image {
                            id: monsterZoneEquipImg1
                            fillMode: Image.PreserveAspectFit
                            anchors.fill: parent
                        }
                        //                            onShowMenu: monster1CommandMenu.showMenu(flag)
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

        Item {
            id: controlZone
            anchors {
                left: duelField.left
                right: duelField.right
                bottom: monsterZone1.top
                bottomMargin: 5
                top: monsterZone2.bottom
                topMargin: 5
            }
            Row {
                anchors.fill: parent
                spacing: 5
                GameScreenButton {
                    id: drawButton
                    height: controlZone.height;
                    width: controlZone.width/6 - 5;
                    text: "DRAW"
                }
                GameScreenButton {
                    id: standbyButton
                    height: controlZone.height;
                    width: controlZone.width/6 - 5;
                    text: "STANDBY"
                }
                GameScreenButton {
                    id: main1Button
                    height: controlZone.height;
                    width: controlZone.width/6 - 5;
                    text: "MAIN1"
                }
                GameScreenButton {
                    id: battleButton
                    height: controlZone.height;
                    width: controlZone.width/6 - 5;
                    text: "BATTLE"
                }
                GameScreenButton {
                    id: main2Button
                    height: controlZone.height;
                    width: controlZone.width/6 - 5;
                    text: "MAIN2"
                }
                GameScreenButton {
                    id: endButton
                    height: controlZone.height;
                    width: controlZone.width/6 - 5;
                    text: "END"
                }
            }
        }

        Image {
            id: graveyardCardZone1
            width: cardHeight + 20
            height: cardHeight + 20
            anchors {
                top: monsterZone1.top
                right: rscaleCardZone1.right
                //                left: monsterZone1.right
            }
            source: "../../assets/img/gs_cardslot_player.png"
            Image {
                height: cardHeight
                fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent
                source: "../../assets/img/gs_icon_card_graveyard.png"
            }
            Item {
                width: cardWidth; height: cardHeight
                anchors.centerIn: parent
                ListView {
                    id: graveyardCardZone1List
                    anchors.fill: parent
                    model: clientField.grave1
                    spacing: -cardHeight + 0.5
                    delegate: Image {
                        width: cardWidth; height: cardHeight;
                        source: (code != 0)? "../../assets/pics/"+ code +".jpg": ""
                        anchors.centerIn: parent
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: cardSelectDialogBoxBehavior(graveyardCardZone1List, clientField.grave1, true)
                }
                Image {
                    id: graveRotationAnimation
                    anchors.fill: parent
                    source: "../../assets/img/act.png"
                    enabled: false
                    visible: false
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

        Image {
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
                    id: deckCardZone1List
                    anchors.fill: parent
                    model: clientField.deck1
                    spacing: -cardHeight + 0.5
                    delegate: Image {
                        width: cardWidth
                        height: cardHeight
                        source: "../../assets/img/0000.png"
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: cardSelectDialogBoxBehavior(deckCardZone1List, clientField.deck1, duelInfo.isSingleMode())
                }
                Image {
                    id: deckRotationAnimation
                    anchors.fill: parent
                    source: "../../assets/img/act.png"
                    enabled: false
                    visible: false
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

        Image {
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
                    id: deckCardZone2List
                    anchors.fill: parent
                    model: clientField.deck2
                    spacing: -cardHeight + 0.5
                    delegate: Image {
                        width: cardWidth
                        height: cardHeight
                        source: "../../assets/img/0000.png"
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: cardSelectDialogBoxBehavior(deckCardZone2List, clientField.deck2, duelInfo.isSingleMode())
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
                            return "../../assets/img/gs_cardslot_opponent.png";
                        }
                        else
                            return "";
                    }
                    ClientCard {
//                        width: cardWidth; height: cardHeight;
                        anchors.centerIn: parent
                        isEnableDown: false
                        source: {
                            if(index === 7 && code != 0)
                                return "../../assets/pics/"+ code +".jpg";
                            return "";
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

            source: "../../assets/img/gs_cardslot_opponent.png"
            Image {
                height: cardHeight
                fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent
                source: "../../assets/img/gs_icon_card_graveyard.png"
            }
            Item {
                width: cardWidth; height: cardHeight
                anchors.centerIn: parent
                ListView {
                    id: graveyardCardZone2List
                    anchors.fill: parent
                    model: clientField.grave2
                    spacing: -cardHeight + 0.5
                    delegate: Image {
                        width: cardWidth; height: cardHeight;
                        source: (code != 0)? "../../assets/pics/"+ code +".jpg": ""
                        anchors.centerIn: parent
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: cardSelectDialogBoxBehavior(graveyardCardZone2List, clientField.grave2, true)
                }
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
                Image {
                    width: cardHeight + 20
                    height: cardHeight + 20
                    source: "../../assets/img/gs_cardslot_opponent.png"
                    ClientCard {
                        isEnableDown: false
//                        width: cardWidth; height: cardHeight
                        anchors.centerIn: parent
                        source: (code != 0)?"../../assets/pics/"+ code +".jpg":""
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
                right: duelField.right
                //                left: spellZone2.right
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
                            return "../../assets/img/gs_cardslot_opponent.png";
                        }
                        else
                            return "";
                    }
                    ClientCard {
//                        width: cardWidth; height: cardHeight;
                        anchors.centerIn: parent
                        isEnableDown: false
                        source: {
                            if(index === 6 && code != 0)
                                return "../../assets/pics/"+ code +".jpg";
                            return "";
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
                Image {
                    width: cardHeight + 20
                    height: cardHeight + 20
                    source: "../../assets/img/gs_cardslot_opponent.png"
                    ClientCard {
                        isEnableDown: false
//                        width: cardWidth; height: cardHeight
                        anchors.centerIn: parent
                        source: (code != 0)?"../../assets/pics/"+ code +".jpg":""
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
                right: lscaleCardZone2.right
                //                left: monsterZone2.right
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
                            return "../../assets/img/gs_cardslot_opponent.png";
                        }
                        else
                            return "";
                    }
                    Image {
                        height: cardHeight
                        fillMode: Image.PreserveAspectFit
                        anchors.centerIn: parent
                        source: (index === 5)?"../../assets/img/gs_icon_card_spell.png":""
                        ClientCard {
//                            width: cardWidth; height: cardHeight;
                            anchors.centerIn: parent
                            isEnableDown: false
                            source: {
                                if(index === 5 && code != 0)
                                    return "../../assets/pics/"+ code +".jpg";
                                return "";
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
            source: "../../assets/img/gs_cardslot_opponent.png"
            anchors {
                top: parent.top
                topMargin: 5
                right: lscaleCardZone2.right
                //                left: lscaleCardZone2.left
            }
            Image {
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
                    id: extraCardZone2List
                    anchors.fill: parent
                    model: clientField.extra2
                    spacing: -cardHeight + 0.5
                    delegate: Image {
                        width: cardWidth
                        height: cardHeight
                        source: "../../assets/img/0000.png"
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: cardSelectDialogBoxBehavior(extraCardZone2List, clientField.extra2, true)
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
                Column {
//                    CommandMenu {
//                        id: hand1CommandMenu
//                        width: cardWidth
//                        height: 20
//                    }

                    ClientCard {
                        isEnableDown: true
//                        width: cardWidth; height: cardHeight
                        source: (code != 0)?"../../assets/pics/"+ code +".jpg":""/*:parent.flipped=true*/; //Will issue warning
//                        onShowMenu: hand1CommandMenu.showMenu(flag)
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
//                    width: cardWidth; height: cardHeight
                    source: (code != 0)?"../../assets/pics/"+ code +".jpg":""/*:parent.flipped=true*/; //Will issue warning
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
        id: messageDialogBox
        width: 384
        height: 100
    }

    DialogBox {
        id: cardSelectDialogBox
        width: duelField.width
        height: 270
        source: ""
        offsetX: -40
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
                    messageDialogBox.activateMessage(qsTr("You Win!"));
                    break;
                case 2:
                    messageDialogBox.activateMessage(qsTr("You Lose!"));
                    break;
                case 3:
                    messageDialogBox.activateMessage(qsTr("Draw Game"));
                    break;
                case 4:
                    messageDialogBox.activateMessage(qsTr("Draw Phase"));
                    break;
                case 5:
                    messageDialogBox.activateMessage(qsTr("Standby Phase"));
                    break;
                case 6:
                    messageDialogBox.activateMessage(qsTr("Main Phase 1"));
                    break;
                case 7:
                    messageDialogBox.activateMessage(qsTr("Battle Phase"));
                    break;
                case 8:
                    messageDialogBox.activateMessage(qsTr("Main Phase 2"));
                    break;
                case 9:
                    messageDialogBox.activateMessage(qsTr("End Phase"));
                    break;
                case 10:
                    messageDialogBox.activateMessage(qsTr("Next Players Turn"));
                    break;
                case 11:
                    messageDialogBox.activateMessage(qsTr("Duel Start"));
                    break;
                case 12:
                    messageDialogBox.activateMessage(qsTr("Duel1 Start"));
                    break;
                case 13:
                    messageDialogBox.activateMessage(qsTr("Duel2 Start"));
                    break;
                case 14:
                    messageDialogBox.activateMessage(qsTr("Duel3 Start"));
                    break;
                }
            }
            }
        }
        onQclientAnalyzeChanged: {
            switch(duelInfo.getCurMsg()) {
            case msg_select_idlecmd: {
                var pbuf = game.getBuffer();
                if(pbuf){
                    battleButton.visible = true;
                    battleButton.isEnabled = true;
                    battleButton.isPressed = false;
                }
                pbuf = game.getBuffer();
                if(pbuf) {
                    endButton.visible = true;
                    endButton.isEnabled = true;
                    endButton.isPressed = false;
                }
                break;
            }

            case msg_new_phase: {
                var phase = game.getBuffer();
                switch(phase) {
                case phase_draw:
                    drawButton.visible = true;
                    break;
                case phase_standby:
                    standbyButton.visible = true;
                    break;
                case phase_main1:
                    main1Button.visible = true;
                    break;
                case phase_battle:
                    battleButton.visible = true;
                    battleButton.isPressed = true;
                    battleButton.isEnabled = false;
                    break;
                case phase_main2:
                    main2Button.visible = true;
                    main2Button.isPressed = true;
                    main2Button.isEnabled = false;
                    break;
                case phase_end:
                    endButton.visible = true;
                    endButton.isPressed = true;
                    endButton.isEnabled = false;
                }
            }
            }
        }
        onQshowWCardSelectChanged: {
            cardSelectDialogBox.model = clientField.selectableCards;
            cardSelectDialogBoxFixed = clientField.selectCancelable();
            cardSelectDialogBox.slideIn();
        }

    }

    Connections {
        target: duelInfo
        onLp1Changed: {
            if(parseInt(lp1Text.text) > duelInfo.getLp1() && duelInfo.getLp1() < 8000)
                progressBar1.x -= progressBar1.width*(1 - duelInfo.getLp1()/8000);
            else if(parseInt(lp1Text.text) > duelInfo.getLp1() && duelInfo.getLp1() >= 8000)
                progressBar1.x = player1Image.width;
            else if(parseInt(lp1Text.text) < duelInfo.getLp1() && duelInfo.getLp1() < 8000)
                progressBar1.x += progressBar1.width*(1 - duelInfo.getLp1()/8000);
            else if(parseInt(lp1Text.text) < duelInfo.getLp1() && duelInfo.getLp1() >= 8000)
                progressBar1.x = player1Image.width;
            else if(parseInt(lp1Text.text) === duelInfo.getLp1())
            {}
            lp1Text.text = duelInfo.getLp1();
        }
        onLp2Changed: {
            if(parseInt(lp2Text.text) > duelInfo.getLp2() && duelInfo.getLp2() < 8000)
                progressBar2.x -= progressBar2.width*(1 - duelInfo.getLp2()/8000);
            else if(parseInt(lp2Text.text) > duelInfo.getLp2() && duelInfo.getLp2() >= 8000)
                progressBar2.x = player2Image.width;
            else if(parseInt(lp2Text.text) < duelInfo.getLp2() && duelInfo.getLp2() < 8000)
                progressBar2.x += progressBar2.width*(1 - duelInfo.getLp2()/8000);
            else if(parseInt(lp2Text.text) < duelInfo.getLp2() && duelInfo.getLp2() >= 8000)
                progressBar2.x = player2Image.width;
            else if(parseInt(lp2Text.text) === duelInfo.getLp2())
            {}
            lp2Text.text = duelInfo.getLp2();
        }
        onClientNameChanged: {
            clientname = duelInfo.getClientName();
        }
    }

    Connections {
        target: clientField
        onDeckActivateChanged: {
            if(clientField.getDeckAct())
                deckRotationAnimation.visible = true
            else
                deckRotationAnimation.visible = false;
        }
        onGraveActivateChanged: {
            if(clientField.getGraveAct())
                graveRotationAnimation.visible = true;
            else
                graveRotationAnimation.visible = false;
        }
        onRemovedActivateChanged: { //TODO:: add animation to removed
            if(clientField.getRemovedAct())
                removedRotationAnimation.visible = true;
            else
                removedRotationAnimation.visible = false;
        }
        onExtraActivatedChanged: {
            if(clientField.getExtraAct())
                extraRotationAnimation.visible = true;
            else
                extraRotationAnimation.visible = false;
        }
        onPzoneActivatedChanged: {  //TODO:: add animation to pzone
            if(clientField.getPzoneAct())
                pzoneRotationAnimation.visible = true;
            else
                pzoneRotationAnimation.visible = false;
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
