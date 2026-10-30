pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property bool pinned: false

  IpcHandler {
    target: "bars"

    function togglePinned(): void {
      root.pinned = !root.pinned;
    }
  }
}
