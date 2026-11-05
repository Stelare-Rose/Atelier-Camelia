import QtQuick
import Quickshell
import Quickshell.Io

// Brightness control for one screen: the kernel backlight for built-in panels,
// DDC/CI over I2C for external monitors.
Scope {
  id: root

  required property ShellScreen modelData
  readonly property ShellScreen screen: modelData

  readonly property bool builtIn: /^(eDP|LVDS|DSI)/.test(screen.name)
  readonly property int bus: Brightness.ddcBuses[screen.name] ?? -1
  readonly property string backend: builtIn ? "backlight" : (bus >= 0 ? "ddc" : "")
  readonly property bool available: backend !== "" && _loaded

  // 0 to 1
  property real brightness: 0

  property real _max: 100
  property bool _loaded: false
  property bool _dirty: false

  function refresh() {
    if (backend !== "")
    getProcess.running = true;
  }

  // Updates the value immediately so the UI is responsive, then applies it
  // to the hardware after a short pause (ddcutil is far too slow to call per slider step)
  function setBrightness(value) {
    brightness = Math.max(0, Math.min(1, value));
    applyTimer.restart();
  }

  onBackendChanged: refresh()

  Timer {
    id: applyTimer
    interval: 150
    onTriggered: {
      // If a write is still in progress, queue one more for when it finishes
      if (setProcess.running)
      root._dirty = true;
      else
      setProcess.running = true;
    }
  }

  Process {
    id: getProcess
    command: root.backend === "backlight"
    ? ["brightnessctl", "-m", "-c", "backlight", "info"]
    : ["ddcutil", "--bus", String(root.bus), "getvcp", "10", "--brief"]
    stdout: StdioCollector {
      onStreamFinished: root._parseGet(text)
    }
  }

  Process {
    id: setProcess
    command: root.backend === "backlight"
    ? ["brightnessctl", "-q", "-c", "backlight", "set", Math.round(root.brightness * 100) + "%"]
    : ["ddcutil", "--bus", String(root.bus), "--noverify", "setvcp", "10", String(Math.round(root.brightness * root._max))]
    onExited: {
      if (root._dirty) {
        root._dirty = false;
        running = true;
      }
    }
  }

  function _parseGet(data) {
    if (backend === "backlight") {
      // "<device>,backlight,<current>,<percent>,<max>"
      const fields = data.trim().split(",");
      _max = Number(fields[4]);
      brightness = Number(fields[2]) / _max;
    } else {
      // "VCP 10 C <current> <max>"
      const fields = data.trim().split(/\s+/);
      _max = Number(fields[4]);
      brightness = Number(fields[3]) / _max;
    }

    _loaded = true;
  }
}
