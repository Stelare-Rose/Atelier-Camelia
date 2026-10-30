import QtQuick
import qs.config
import qs.components
import qs.services

Rectangle {
  id: root

  required property var windows

  readonly property bool hasFocus: windows.some(window => window.is_focused)
  readonly property int spacing: 2
  readonly property real iconSize: Math.min(
    Theme.workspaceIconSize,
    (height - Theme.workspaceColumnPadding * 2 - spacing * (windows.length - 1)) / windows.length
  )

  implicitWidth: Theme.workspaceIconSize + Theme.workspaceColumnPadding * 2
  radius: Theme.workspaceColumnRadius
  color: hasFocus ? Theme.surface : "transparent"

  Column {
    anchors.centerIn: parent
    spacing: root.spacing

    Repeater {
      model: root.windows

      delegate: WindowIcon {
        required property var modelData

        appId: modelData.app_id
        implicitSize: root.iconSize
        opacity: modelData.is_focused ? 1 : 0.7
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: Niri.focusWindow(root.windows.find(window => window.is_focused) ?? root.windows[0])
  }
}
