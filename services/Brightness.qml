pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  // I2C bus number for each external connector, from ddcutil detect, e.g. { "DP-1": 5 }
  property var ddcBuses: ({})

  function forScreen(screen) {
    for (const monitor of monitors.instances) {
      if (monitor.screen === screen)
      return monitor;
    }
    return null;
  }

  // One controller per screen
  Variants {
    id: monitors
    model: Quickshell.screens
    delegate: BrightnessMonitor {}
  }

  // Find which I2C bus each external monitor is on. This is slow (a second or two),
  // so it runs once; after that every command addresses the bus directly.
  Process {
    running: true
    command: ["ddcutil", "detect", "--brief"]
    stdout: StdioCollector {
      onStreamFinished: root._parseDetect(text)
    }
  }

  function _parseDetect(data) {
    const buses = {};

    // One block per display, starting with "Display N"
    for (const block of data.split(/\n(?=\S)/)) {
      if (!block.startsWith("Display"))
      continue;

      const bus = block.match(/\/dev\/i2c-(\d+)/);
      const connector = block.match(/DRM[_ ]connector:\s+card\d+-(\S+)/);

      if (bus && connector)
      buses[connector[1]] = Number(bus[1]);
    }

    ddcBuses = buses;
  }
}
