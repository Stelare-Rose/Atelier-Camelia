import QtQuick
import Quickshell
import qs.config
import qs.services

Row {
  id: root

  required property ShellScreen screen
  property bool showTrailingEmpty: false

  readonly property var workspaces: {
    const list = Niri.workspacesOn(screen.name);
    const last = list[list.length - 1];

    // niri always keeps one empty workspace at the bottom; hide it unless we're on it
    if (!showTrailingEmpty && last && last.active_window_id === null && !last.is_active)
    return list.slice(0, -1);
    return list;
  }

  spacing: Theme.workspaceSpacing

  Repeater {
    model: root.workspaces

    delegate: WorkspaceItem {
      required property var modelData
      workspace: modelData
    }
  }

  WheelHandler {
    onWheel: event => Niri.action(event.angleDelta.y > 0 ? "focus-workspace-up" : "focus-workspace-down")
  }
}
