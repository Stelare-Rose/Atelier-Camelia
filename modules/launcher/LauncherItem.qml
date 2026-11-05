import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

Rectangle {
  id: root

  required property var item
  property bool selected: false

  signal activated()
  signal hovered()

  radius: Theme.workspaceRadius
  color: selected ? Theme.surfaceAlt : "transparent"

  RowLayout {
    anchors {
      fill: parent
      leftMargin: 8
      rightMargin: 8
    }
    spacing: 10

    // App icon, or a Nerd Font glyph for built-in items (calculator, commands, clipboard)
    Item {
      implicitWidth: Theme.launcherIconSize
      implicitHeight: Theme.launcherIconSize

      WindowIcon {
        anchors.fill: parent
        visible: !root.item.glyph
        appId: root.item.icon ?? ""
        implicitSize: Theme.launcherIconSize
      }

      StyledText {
        anchors.centerIn: parent
        visible: !!root.item.glyph
        isMono: true
        text: root.item.glyph ?? ""
        color: Theme.accent
        font.pixelSize: Theme.launcherIconSize * 0.8
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 0

      StyledText {
        Layout.fillWidth: true
        text: root.item.name
        elide: Text.ElideRight
        maximumLineCount: 1
      }

      StyledText {
        Layout.fillWidth: true
        visible: text !== ""
        text: root.item.description
        color: Theme.muted
        font.pixelSize: Theme.sizeSmall
        elide: Text.ElideRight
        maximumLineCount: 1
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onEntered: root.hovered()
    onClicked: root.activated()
  }
}
