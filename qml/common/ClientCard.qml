import QtQuick 2.0

Flipable {
    id: flipable

    property bool flipped: false
    property bool isEnableDown: false
    property bool downYBehaviour: false
    property bool inside: false
    signal showInfo

    //Type
    property int type_monster: 0x1
    property int type_spell: 0x2
    property int type_trap: 0x4
    property int type_normal: 0x10
    property int type_effect: 0x20
    property int type_fusion: 0x40
    property int type_ritual: 0x80
    property int type_trapmonster: 0x100
    property int type_spirit: 0x200
    property int type_union: 0x400
    property int type_dual: 0x800
    property int type_tuner: 0x1000
    property int type_synchro: 0x2000
    property int type_token: 0x4000
    property int type_quickplay: 0x10000
    property int type_continuous: 0x20000
    property int type_equip: 0x40000
    property int type_field: 0x80000
    property int type_counter: 0x100000
    property int type_flip: 0x200000
    property int type_toon: 0x400000
    property int type_xyz: 0x800000
    property int type_pendulum: 0x1000000
    //Attribute
    property int attribute_earth: 0x01
    property int attribute_water: 0x02
    property int attribute_fire: 0x04
    property int attribute_wind: 0x08
    property int attribute_light: 0x10
    property int attribute_dark: 0x20
    property int attribute_devine: 0x40
    //Races
    property int race_warrior: 0x1
    property int race_spellcaster: 0x2
    property int race_fairy: 0x4
    property int race_fiend: 0x8
    property int race_zombie: 0x10
    property int race_machine: 0x20
    property int race_aqua: 0x40
    property int race_pyro: 0x80
    property int race_rock: 0x100
    property int race_windbeast: 0x200
    property int race_plant: 0x400
    property int race_insect: 0x800
    property int race_thunder: 0x1000
    property int race_dragon: 0x2000
    property int race_beast: 0x4000
    property int race_beastwarrior: 0x8000
    property int race_dinosaur: 0x10000
    property int race_fish: 0x20000
    property int race_seaserpent: 0x40000
    property int race_reptile: 0x80000
    property int race_psycho: 0x100000
    property int race_devine: 0x200000
    property int race_creatorgod: 0x400000
    property int race_phantomdragon: 0x800000
    //Positions
    property int pos_faceup_attack: 0x1
    property int pos_facedown_attack: 0x2
    property int pos_faceup_defence: 0x4
    property int pos_facedown_defence: 0x8
    property int pos_faceup: 0x5
    property int pos_facedown: 0xa
    property int pos_attack: 0x3
    property int pos_defence: 0xc
    property int no_flip_effect: 0x10000
    //Locations
    property int location_deck: 0x01
    property int location_hand: 0x02
    property int location_mzone: 0x04
    property int location_szone: 0x08
    property int location_grave: 0x10
    property int location_removed: 0x20
    property int location_extra: 0x40
    property int location_overlay: 0x80
    property int location_onfield: 0x0c
    property int location_fzone: 0x100
    property int location_pzone: 0x200

    back: Image {
        width: parent.width; height: parent.height
        source: "../../assets/img/0000.png"
        anchors.centerIn: parent
    }

    transform: Rotation {
        id: rotation
        origin.x: flipable.width/2
        origin.y: flipable.height/2
        axis.x: 0; axis.y: 1; axis.z: 0     // set axis.y to 1 to rotate around y-axis
        angle: 0    // the default angle
    }

    states: State {
        name: "back"
        PropertyChanges { target: rotation; angle: 180 }
        when: flipable.flipped
    }

    transitions: Transition {
        NumberAnimation { target: rotation; property: "angle"; duration: 200 }
    }

    Timer {
        id: desTimer
        interval: 500
        onTriggered: {
            if(inside === true)
                parent.showInfo();
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            inside = true;
            desTimer.start();
            if(isEnableDown) {
                if(downYBehaviour)
                    parent.y = 30;
                else
                    parent.y = -30;
            }
        }
        onExited: {
            desTimer.stop();
            inside = false;
            parent.y = 0 ;
        }
//        onClicked: flipable.flipped = !flipable.flipped
    }

    Behavior on y {
        NumberAnimation {duration: 150}
    }

    onShowInfo: {
        if(code != 0) {
            desCardImg.source = "../../assets/pics/"+ code +".jpg";
            cardName.text = name;
            cardType.text = formatType;
            desText.text = showingText;            
            if(baseType & type_monster) {
                if(baseAttack >= 0)
                    desAtk.text = "ATK/" + baseAttack;
                else
                    desAtk.text = "ATK/?";
                if(baseDefence >= 0)
                    desDef.text = "DEF/" + baseDefence;
                else
                    desDef.text = "DEF/?";
                if(baseType & type_xyz) {
                    desLevelRank.source = "../../assets/img/rankStar.png";
                    levelRankText.text = "x" + baseRank;
                }
                else {
                    desLevelRank.source = "../../assets/img/levelStar.png";
                    levelRankText.text = "x" + baseLevel;
                }
                if(baseType & type_pendulum) {
                    desLscale.source = "../../assets/img/lscale.png";
                    desRscale.source = "../../assets/img/rscale.png";
                    desLscaleText.text = lscale;
                    desRscaleText.text = rscale;
                }
                //Attribute check
                if(baseAttribute & attribute_earth) {
                    cardLogo1.source = "../../assets/img/cardAttr_5.png";
                    cardLogo1Text.text = "Earth";
                }
                else if(baseAttribute & attribute_water) {
                    cardLogo1.source = "../../assets/img/cardAttr_3.png";
                    cardLogo1Text.text = "Water";
                }
                else if(baseAttribute & attribute_fire) {
                    cardLogo1.source = "../../assets/img/cardAttr_4.png";
                    cardLogo1Text.text = "Fire";
                }
                else if(baseAttribute & attribute_wind) {
                    cardLogo1.source = "../../assets/img/cardAttr_6.png";
                    cardLogo1Text.text = "Wind";
                }
                else if(baseAttribute & attribute_light) {
                    cardLogo1.source = "../../assets/img/cardAttr_1.png";
                    cardLogo1Text.text = "Light";
                }
                else if(baseAttribute & attribute_dark) {
                    cardLogo1.source = "../../assets/img/cardAttr_2.png";
                    cardLogo1Text.text = "Dark";
                }
                else if(baseAttribute & attribute_devine) {
                    cardLogo1.source = "../../assets/img/cardAttr_7.png";
                    cardLogo1Text.text = "Devine";
                }
                //Race check
                if(baseRace & race_warrior) {
                    cardLogo2.source = "../../assets/img/monster_icon_warrior.png";
                    cardLogo2Text.text = "Warrior";
                }
                else if(baseRace & race_spellcaster) {
                    cardLogo2.source = "../../assets/img/monster_icon_spellcaster.png";
                    cardLogo2Text.text = "Spell Caster";
                }
                else if(baseRace & race_fairy) {
                    cardLogo2.source = "../../assets/img/monster_icon_fairy.png";
                    cardLogo2Text.text = "Fairy";
                }
                else if(baseRace & race_fiend) {
                    cardLogo2.source = "../../assets/img/monster_icon_fiend.png";
                    cardLogo2Text.text = "Fiend";
                }
                else if(baseRace & race_zombie) {
                    cardLogo2.source = "../../assets/img/monster_icon_zombie.png";
                    cardLogo2Text.text = "Zombie";
                }
                else if(baseRace & race_machine) {
                    cardLogo2.source = "../../assets/img/monster_icon_machine.png";
                    cardLogo2Text.text = "Machine";
                }
                else if(baseRace & race_aqua) {
                    cardLogo2.source = "../../assets/img/monster_icon_aqua.png";
                    cardLogo2Text.text = "Aqua";
                }
                else if(baseRace & race_pyro) {
                    cardLogo2.source = "../../assets/img/monster_icon_pyro.png";
                    cardLogo2Text.text = "Pyro";
                }
                else if(baseRace & race_rock) {
                    cardLogo2.source = "../../assets/img/monster_icon_rock.png";
                    cardLogo2Text.text = "Rock";
                }
                else if(baseRace & race_windbeast) {
                    cardLogo2.source = "../../assets/img/monster_icon_wingedbeast.png";
                    cardLogo2Text.text = "Winged Beast";
                }
                else if(baseRace & race_plant) {
                    cardLogo2.source = "../../assets/img/monster_icon_plant.png";
                    cardLogo2Text.text = "Plant";
                }
                else if(baseRace & race_insect) {
                    cardLogo2.source = "../../assets/img/monster_icon_insect.png";
                    cardLogo2Text.text = "Insect";
                }
                else if(baseRace & race_thunder) {
                    cardLogo2.source = "../../assets/img/monster_icon_thunder.png";
                    cardLogo2Text.text = "Thunder";
                }
                else if(baseRace & race_dragon) {
                    cardLogo2.source = "../../assets/img/monster_icon_dragon.png";
                    cardLogo2Text.text = "Dragon";
                }
                else if(baseRace & race_beast) {
                    cardLogo2.source = "../../assets/img/monster_icon_beast.png";
                    cardLogo2Text.text = "Beast";
                }
                else if(baseRace & race_beastwarrior) {
                    cardLogo2.source = "../../assets/img/monster_icon_beastwarrior.png";
                    cardLogo2Text.text = "Beast Warrior";
                }
                else if(baseRace & race_dinosaur) {
                    cardLogo2.source = "../../assets/img/monster_icon_dinosaur.png";
                    cardLogo2Text.text = "Dinosaur";
                }
                else if(baseRace & race_fish) {
                    cardLogo2.source = "../../assets/img/monster_icon_fish.png";
                    cardLogo2Text.text = "Fish";
                }
                else if(baseRace & race_seaserpent) {
                    cardLogo2.source = "../../assets/img/monster_icon_seaserpent.png";
                    cardLogo2Text.text = "Sea Serpent";
                }
                else if(baseRace & race_reptile) {
                    cardLogo2.source = "../../assets/img/monster_icon_reptile.png";
                    cardLogo2Text.text = "Reptile";
                }
                else if(baseRace & race_psycho) {
                    cardLogo2.source = "../../assets/img/monster_icon_psychic.png";
                    cardLogo2Text.text = "Psychic";
                }
                else if(baseRace & race_devine) {
                    cardLogo2.source = "../../assets/img/monster_icon_divinebeast.png";
                    cardLogo2Text.text = "Divine Beast";
                }
                else if(baseRace & race_creatorgod) {
                    cardLogo2Text.text = "Creator God";
                }
                else if(baseRace & race_phantomdragon) {
                    cardLogo2Text.text = "Phantom Dragon";
                }
            }
            else {
                desAtk.text = "";
                desDef.text = "";
                desLevelRank.source = "";
                levelRankText.text = "";
                cardLogo1.source = "";
                cardLogo1Text.text = "";
                cardLogo2.source = "";
                cardLogo2Text.text = "";
                desLscale.source = "";
                desLscaleText.text = "";
                desRscale.source = "";
                desRscaleText.text = "";
                if(baseType & type_spell) {
                    cardLogo1.source = "../../assets/img/cardAttr_8.png";
                    cardLogo1Text.text = "Spell";
                    if(baseType & type_field) {
                        cardLogo2.source = "../../assets/img/cardIcon_2.png";
                        cardLogo2Text.text = "Field";
                    }
                    else if(baseType & type_equip) {
                        cardLogo2.source = "../../assets/img/cardIcon_3.png";
                        cardLogo2Text.text = "Equip";
                    }
                    else if(baseType & type_continuous) {
                        cardLogo2.source = "../../assets/img/cardIcon_4.png";
                        cardLogo2Text.text = "Continuous";
                    }
                    else if(baseType & type_quickplay) {
                        cardLogo2.source = "../../assets/img/cardIcon_5.png";
                        cardLogo2Text.text = "Quick-Play";
                    }
                    else if(baseType & type_ritual) {
                        cardLogo2.source = "../../assets/img/cardIcon_6.png";
                        cardLogo2Text.text = "Ritual";
                    }
                }
                else if (baseType & type_trap) {
                    cardLogo1.source = "../../assets/img/cardAttr_9.png";
                    cardLogo1Text.text = "Trap";
                    if(baseType & type_counter) {
                        cardLogo2.source = "../../assets/img/cardIcon_1.png";
                        cardLogo2Text.text = "Counter";
                    }
                    else if(baseType & type_continuous) {
                        cardLogo2.source = "../../assets/img/cardIcon_4.png";
                        cardLogo2Text.text = "Continuous";
                    }
                }
            }
        }
    }
}
