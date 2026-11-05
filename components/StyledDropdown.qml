import QtQuick
import QtQuick.Layouts
import qs.config

ColumnLayout {
  id: root

  property var model: []
  property var current: null
  property var label: item => String(item)
  property int maxVisible: 5
  property int itemHeight: 28

  property bool expanded: false

  signal selected(var item)

  // Animated separately: Behaviors can't go directly on Layout properties
  property real listHeight: expanded ? Math.min(list.count, maxVisible) * itemHeight : 0

  Behavior on listHeight {
    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
  }

  spacing: 2

  // The closed state: current choice plus a chevron
  Rectangle {
    Layout.fillWidth: true
    implicitHeight: root.itemHeight
    radius: Theme.workspaceRadius
    color: headerArea.containsMouse ? Theme.shade(Theme.surface, 0.1) : Theme.surface

    RowLayout {
      anchors {
        fill: parent
        leftMargin: 8
        rightMargin: 8
      }

      StyledText {
        Layout.fillWidth: true
        text: root.current ? root.label(root.current) : "None"
        elide: Text.ElideRight
      }

      StyledText {
        isMono: true
        text: root.expanded ? "\u{F0143}" : "\u{F0140}" // nf-md-chevron_up / chevron_down
      }
    }

    MouseArea {
      id: headerArea

      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: root.expanded = !root.expanded
    }
  }

  // The options, scrollable once there are more than maxVisible
  ListView {
    id: list

    Layout.fillWidth: true
    Layout.preferredHeight: root.listHeight
    visible: root.listHeight > 0
    clip: true
    model: root.model

    delegate: Rectangle {
      id: option

      required property var modelData

      readonly property bool isCurrent: modelData === root.current

      width: list.width
      height: root.itemHeight
      radius: Theme.workspaceRadius
      color: optionArea.containsMouse ? Theme.shade(Theme.surface, 0.1) : "transparent"

      StyledText {
        anchors.verticalCenter: parent.verticalCenter
        x: 8
        width: parent.width - 16
        elide: Text.ElideRight
        text: root.label(option.modelData)
        color: option.isCurrent ? Theme.accent : Theme.foreground
      }

      MouseArea {
        id: optionArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          root.selected(option.modelData);
          root.expanded = false;
        }
      }
    }
  }
}
