import QtQuick

Item {
    id: root

    property color color: "black"
    property int width: 1
    property bool top: false
    property bool bottom: false
    property bool left: false
    property bool right: false

    anchors.fill: parent

    Rectangle {
        visible: root.top
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: root.width
        color: root.color
    }

    Rectangle {
        visible: root.bottom
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: root.width
        color: root.color
    }

    Rectangle {
        visible: root.left
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        width: root.width
        color: root.color
    }

    Rectangle {
        visible: root.right
        anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
        width: root.width
        color: root.color
    }
}
