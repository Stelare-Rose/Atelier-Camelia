pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property var workspaces: []
  property var windows: []

  readonly property bool available: !!Quickshell.env("NIRI_SOCKET")


  function workspacesOn(outputName) {
    return workspaces
    .filter(workspace => workspace.output === outputName)
    .sort((a, b) => a.idx - b.idx);
  }

  function windowsOn(workspaceId) {
    return windows.filter(window => window.workspace_id === workspaceId);
  }

  function columnsOn(workspaceId) {
    const columns = [];

    for (const window of windowsOn(workspaceId)) {
      const position = window.layout?.pos_in_scrolling_layout;
      if (!position)
      continue;

      const column = position[0] - 1;
      const row = position[1] - 1;

      if (!columns[column])
      columns[column] = [];
      columns[column][row] = window;
    }

    return columns
    .filter(column => column)
    .map(column => column.filter(window => window));
  }

  function floatingOn(workspaceId) {
    return windowsOn(workspaceId).filter(window => !window.layout?.pos_in_scrolling_layout);
  }

  function action(...args) {
    Quickshell.execDetached(["niri", "msg", "action", ...args]);
  }

  function focusWindow(window) {
    action("focus-window", "--id", String(window.id));
  }

  function focusWorkspace(workspace) {
    Quickshell.execDetached([
      "sh", "-c",
      "niri msg action focus-monitor \"$1\" && niri msg action focus-workspace \"$2\"",
      "sh", workspace.output, String(workspace.idx)
    ]);
  }

  Process {
    running: root.available
    command: ["niri", "msg", "--json", "event-stream"]
    stdout: SplitParser {
      onRead: line => root._handleEvent(JSON.parse(line))
    }
  }

  function _handleEvent(event) {
    const type = Object.keys(event)[0];
    const data = event[type];

    switch (type) {
      case "WorkspacesChanged":
      workspaces = data.workspaces;
      break;
      case "WorkspaceActivated":
      _activateWorkspace(data.id, data.focused);
      break;
      case "WorkspaceActiveWindowChanged":
      workspaces = _patch(workspaces, data.workspace_id, { active_window_id: data.active_window_id });
      break;
      case "WorkspaceUrgencyChanged":
      workspaces = _patch(workspaces, data.id, { is_urgent: data.urgent });
      break;
      case "WindowsChanged":
      windows = data.windows;
      break;
      case "WindowOpenedOrChanged":
      _upsertWindow(data.window);
      break;
      case "WindowClosed":
      windows = windows.filter(window => window.id !== data.id);
      break;
      case "WindowFocusChanged":
      windows = windows.map(window => Object.assign({}, window, { is_focused: window.id === data.id }));
      break;
      case "WindowUrgencyChanged":
      windows = _patch(windows, data.id, { is_urgent: data.urgent });
      break;
      case "WindowLayoutsChanged":
      _updateLayouts(data.changes);
      break;
    }
  }

  function _patch(list, id, changes) {
    return list.map(item => item.id === id ? Object.assign({}, item, changes) : item);
  }

  function _activateWorkspace(id, focused) {
    const target = workspaces.find(workspace => workspace.id === id);
    if (!target)
    return;

    workspaces = workspaces.map(workspace => {
      const copy = Object.assign({}, workspace);
      if (workspace.output === target.output)
      copy.is_active = workspace.id === id;
      if (focused)
      copy.is_focused = workspace.id === id;
      return copy;
    });
  }

  function _upsertWindow(changed) {
    let found = false;

    windows = windows.map(window => {
      if (window.id === changed.id) {
        found = true;
        return changed;
      }
      if (changed.is_focused && window.is_focused)
      return Object.assign({}, window, { is_focused: false });
      return window;
    });

    if (!found)
    windows = windows.concat([changed]);
  }

  function _updateLayouts(changes) {
    const layouts = new Map(changes);
    windows = windows.map(window => layouts.has(window.id)
    ? Object.assign({}, window, { layout: layouts.get(window.id) })
    : window);
  }
}
