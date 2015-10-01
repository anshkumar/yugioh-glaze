import QtQuick 2.0

Item {
   id: scrollbar

    property Flickable flk : undefined
    property int basicWidth: 10
    property int expandedWidth: 10
    property alias color : scrl.color
    property alias radius : scrl.radius

    width: basicWidth
    anchors.left: flk.right;
    anchors.top: flk.top
    anchors.bottom: flk.bottom

    clip: true
    visible: flk.visible
    z:1

    Image {
        source: "file:img/gs_cardinfo_slider.png"
        visible: flk.visibleArea.heightRatio < 1.0
        anchors.fill: parent
    }

    Binding {
        target: scrollbar
        property: "width"
        value: expandedWidth
        when: ma.drag.active || ma.containsMouse
    }
    Behavior on width {NumberAnimation {duration: 150}}

    Rectangle {
        id: scrl
        clip: true
        anchors.left: parent.left
        anchors.leftMargin: 2
        anchors.right: parent.right
        anchors.rightMargin: 2
        height: flk.visibleArea.heightRatio * flk.height
        visible: flk.visibleArea.heightRatio < 1.0
        radius: 5
        color: "#00f9ff"

        opacity: ma.pressed ? 1 : ma.containsMouse ? 0.65 : 0.4
        Behavior on opacity {NumberAnimation{duration: 150}}

        Binding {
            target: scrl
            property: "y"
            value: !isNaN(flk.visibleArea.heightRatio) ? (ma.drag.maximumY * flk.contentY) / (flk.contentHeight * (1 - flk.visibleArea.heightRatio)) : 0
            when: !ma.drag.active
        }

        Binding {
            target: flk
            property: "contentY"
            value: ((flk.contentHeight * (1 - flk.visibleArea.heightRatio)) * scrl.y) / ma.drag.maximumY
            when: ma.drag.active && flk !== undefined
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            drag.target: parent
            drag.axis: Drag.YAxis
            drag.minimumY: 2
            drag.maximumY: flk.height - scrl.height - 2
            preventStealing: true
        }
    }
}
