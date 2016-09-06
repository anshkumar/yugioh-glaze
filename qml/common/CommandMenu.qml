import QtQuick 2.0

Rectangle {
    id: commandMenu


    property int pos_facedown: 0xa
    property int pos_attack: 0x3

    ListModel {
        id: menuListModel
    }

    Component {
        id: menuListDelegate

        Item {
            width: menuList.width
            height: 80

            Text {
                anchors.centerIn: parent
                text: commandText
                font.family: contentFont.name
                //                font.bold: true
                font.pixelSize: 12
            }

            MouseArea {
                anchors.fill: parent
            }
        }
    }

    ListView {
        id: menuList
        model: menuListModel
        delegate: menuListDelegate
        anchors.fill: parent
    }

    function showMenu(flag) {
        if(flag & command_activate)
            menuListModel.append({"commandText" : "Activate"});
        if(flag & command_summon)
            menuListModel.append({"commandText" : "Normal Summon"});
        if(flag & command_spsummon)
            menuListModel.append({"commandText" : "Special Summon"});
        if(flag & command_mset)
            menuListModel.append({"commandText" : "Set"});
        if(flag & command_sset)
            menuListModel.append({"commandText" : "Set"});
        if(flag & command_repos) {
            if(position & pos_facedown)
                menuListModel.append({"commandText" : "Flip Summon"});
            else if(position & pos_attack)
                menuListModel.append({"commandText" : "To Defense"});
            else
                menuListModel.append({"commandText" : "To Attack"});
        }
        if(flag & command_attack)
            menuListModel.append({"commandText" : "Attack"});
        if(flag & command_list)
            menuListModel.append({"commandText" : "View"});

    }
}
