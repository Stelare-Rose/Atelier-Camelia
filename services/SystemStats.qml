pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property real cpu: 0
  property real gpu: 0

  property real memoryUsed: 0
  property real memoryTotal: 0
  property real diskUsed: 0
  property real diskTotal: 0

  readonly property real memory: memoryTotal > 0 ? memoryUsed / memoryTotal : 0
  readonly property real disk: diskTotal > 0 ? diskUsed / diskTotal : 0

  property int interval: 2000
  property string diskMount: "/"
  property string gpuBusyPath: "/sys/class/drm/card1/device/gpu_busy_percent"

  property real _lastCpuTotal: 0
  property real _lastCpuIdle: 0

  Timer {
    interval: root.interval
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      stat.reload();
      meminfo.reload();
      gpuBusy.reload();
      df.running = true;
    }
  }

  FileView {
    id: stat
    path: "/proc/stat"
    onLoaded: root._parseCpu(text())
  }

  FileView {
    id: meminfo
    path: "/proc/meminfo"
    onLoaded: root._parseMemory(text())
  }

  property bool gpuAvailable: _gpuBackend !== ""
  property string _gpuBackend: "" 
  property string _gpuPath: ""
  property string _intelBuffer: ""
  property int _intelDepth: 0

  Timer {
    interval: root.interval
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      stat.reload();
      meminfo.reload();
      df.running = true;

      if (root._gpuBackend === "sysfs")
      gpuBusy.reload();
      else if (root._gpuBackend === "nvidia")
      nvidiaSmi.running = true;
    }
  }

  Process {
    id: gpuDetect
    running: true
    command: ["sh", "-c", "for f in /sys/class/drm/card*/device/gpu_busy_percent; do [ -r \"$f\" ] && echo \"sysfs $f\" && exit; done; command -v nvidia-smi > /dev/null && echo nvidia && exit; grep -qs 0x8086 /sys/class/drm/card*/device/vendor && command -v intel_gpu_top > /dev/null && echo intel"]
    stdout: StdioCollector {
      onStreamFinished: root._setupGpu(text.trim())
    }
  }

  FileView {
    id: gpuBusy
    path: root._gpuPath
    onLoaded: root.gpu = Number(text()) / 100
  }

  Process {
    id: intelGpuTop
    running: root._gpuBackend === "intel"
    command: ["intel_gpu_top", "-J", "-s", String(root.interval)]
    stdout: SplitParser {
      onRead: line => root._feedIntel(line)
    }
    onExited: code => console.warn("intel_gpu_top exited with code", code, "- did you run setcap?")
  }

  Process {
    id: nvidiaSmi
    command: ["nvidia-smi", "--query-gpu=utilization.gpu", "--format=csv,noheader,nounits"]
    stdout: StdioCollector {
      onStreamFinished: root.gpu = Number(text.trim()) / 100
    }
  }

  Process {
    id: df
    command: ["df", "-B1", "--output=used,size", root.diskMount]
    stdout: StdioCollector {
      onStreamFinished: root._parseDisk(text)
    }
  }

  function _parseCpu(data) {
    const fields = data.split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
    const idle = fields[3] + fields[4];
    const total = fields.reduce((sum, value) => sum + value, 0);

    const deltaTotal = total - _lastCpuTotal;
    const deltaIdle = idle - _lastCpuIdle;

    if (_lastCpuTotal > 0 && deltaTotal > 0)
    cpu = 1 - deltaIdle / deltaTotal;

    _lastCpuTotal = total;
    _lastCpuIdle = idle;
  }

  function _parseMemory(data) {
    // Values in /proc/meminfo are in kB
    const total = Number(data.match(/MemTotal:\s+(\d+)/)[1]) * 1024;
    const available = Number(data.match(/MemAvailable:\s+(\d+)/)[1]) * 1024;
    memoryTotal = total;
    memoryUsed = total - available;
  }

  function _parseDisk(data) {
    // Second line: "<used> <size>"
    const values = data.trim().split("\n")[1].trim().split(/\s+/).map(Number);
    diskUsed = values[0];
    diskTotal = values[1];
  }

  // intel_gpu_top -J prints a never-ending JSON array, one object per sample,
  // spread over many lines. Collect lines until the braces balance, then parse.
  function _feedIntel(line) {
    const opens = (line.match(/{/g) || []).length;
    const closes = (line.match(/}/g) || []).length;

    // Skip the "[" and "," lines between samples
    if (_intelDepth === 0 && opens === 0)
    return;

    _intelBuffer += line + "\n";
    _intelDepth += opens - closes;

    if (_intelDepth !== 0)
    return;

    const json = _intelBuffer.trim().replace(/^[\[,]\s*/, "").replace(/,\s*$/, "");
    _intelBuffer = "";

    try {
      const sample = JSON.parse(json);
      const busy = Object.values(sample.engines).map(engine => engine.busy);
      gpu = Math.max(...busy) / 100;
    } catch (error) {
      console.warn("Could not parse intel_gpu_top sample:", error);
    }
  }

  function _setupGpu(result) {
    if (result.startsWith("sysfs ")) {
      _gpuPath = result.slice(6);
      _gpuBackend = "sysfs";
    } else if (result === "nvidia") {
      _gpuBackend = "nvidia";
    } else if (result === "intel") {
      _gpuBackend = "intel";
    }
  }
}
