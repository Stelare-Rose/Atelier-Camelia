import QtQuick
import qs.config
import qs.components
import qs.services

Rectangle {
  id: root

  required property var workspace

  readonly property var columns: Niri.columnsOn(workspace.id)
  readonly property var floating: Niri.floatingOn(workspace.id)
  readonly property bool empty: columns.length === 0 && floating.length === 0

  implicitHeight: Theme.barThickness - Theme.barSidePadding * 2
  implicitWidth: empty ? implicitHeight : content.implicitWidth + Theme.workspacePadding * 2
  radius: Theme.workspaceRadius

  color: {
    if (workspace.is_focused)
    return Qt.alpha(Theme.accent, 0.35);
    if (workspace.is_active)
    return Theme.surfaceAlt;
    return "transparent";
  }

  border.width: workspace.is_urgent ? 2 : 0
  border.color: Theme.error

  Behavior on implicitWidth {
    NumberAnimation { duration: Theme.revealDuration; easing.type: Easing.OutCubic }
  }

  Behavior on color {
    ColorAnimation { duration: Theme.revealDuration }
  }

  // Clicking empty space in the pill switches workspace;
  // clicking a column focuses that column's window instead
  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: Niri.focusWorkspace(root.workspace)
  }

  // Empty workspace: just a dot
  Rectangle {
    visible: root.empty
    anchors.centerIn: parent
    width: 6
    height: 6
    radius: 3
    color: root.workspace.is_active ? Theme.foreground : Theme.muted
  }

  Row {
    id: content

    anchors.centerIn: parent
    height: parent.height - Theme.workspacePadding * 2
    spacing: Theme.workspaceColumnSpacing

    Repeater {
      model: root.columns

      delegate: WorkspaceColumn {
        required property var modelData

        windows: modelData
        height: content.height
      }
    }

    // Floating windows, dimmed, after the columns
    Repeater {
      model: root.floating

      delegate: WindowIcon {
        required property var modelData

        anchors.verticalCenter: parent.verticalCenter
        appId: modelData.app_id
        implicitSize: Theme.workspaceIconSize
        opacity: 0.5
      }
    }
  }
}
