pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
  id: root

  readonly property PwNode sink: Pipewire.defaultAudioSink
  readonly property PwNode source: Pipewire.defaultAudioSource

  readonly property var nodes: Pipewire.nodes.values.filter(node => node.audio)

  readonly property var outputDevices: nodes.filter(node => ["Audio/Sink", "Audio/Duplex"].includes(mediaClass(node)))
  readonly property var inputDevices: nodes.filter(node => mediaClass(node).startsWith("Audio/Source") || mediaClass(node) === "Audio/Duplex")
  readonly property var playbackStreams: nodes.filter(node => mediaClass(node) === "Stream/Output/Audio")

  readonly property var recordingStreams: nodes.filter(node => mediaClass(node) === "Stream/Input/Audio"
  && node.properties["stream.monitor"] !== "true")

  readonly property bool micInUse: recordingStreams.length > 0

  readonly property real maxVolume: 2.0

  function setVolume(node, volume) {
    if (node?.audio)
    node.audio.volume = Math.max(0, Math.min(maxVolume, volume));
  }
  // Volume and mute are only available on nodes that are tracked
  PwObjectTracker {
    objects: root.nodes
  }
  Process {
    id: pactlList
    stdout: StdioCollector {
      onStreamFinished: root._finishMove(text)
    }
  }

  property var _pendingMove: null

  function moveStream(stream, device) {
    const recording = isRecording(stream);

    _pendingMove = {
      id: String(stream.id),
      serial: String(stream.properties["object.serial"]),
      device: device.name,
      recording: recording
    };

    pactlList.command = ["pactl", "-f", "json", "list", recording ? "source-outputs" : "sink-inputs"];
    pactlList.running = true;
  }

  function _finishMove(data) {
    const move = _pendingMove;
    _pendingMove = null;
    if (!move)
    return;

    let entries;
    try {
      entries = JSON.parse(data);
    } catch (error) {
      console.warn("Audio: couldn't read pactl output:", error);
      return;
    }

    const entry = entries.find(item => item.properties["object.id"] === move.id
    || item.properties["object.serial"] === move.serial);

    if (!entry) {
      console.warn("Audio: stream", move.id, "not found in pactl");
      return;
    }

    Quickshell.execDetached([
      "pactl",
      move.recording ? "move-source-output" : "move-sink-input",
      String(entry.index),
      move.device
    ]);
  }
  function setDefaultOutput(node) {
    Pipewire.preferredDefaultAudioSink = node;
  }

  function setDefaultInput(node) {
    Pipewire.preferredDefaultAudioSource = node;
  }

  function toggleMute(node) {
    if (node?.audio)
    node.audio.muted = !node.audio.muted;
  }

  function mediaClass(node) {
    return node?.properties["media.class"] ?? "";
  }

  function isRecording(stream) {
    return mediaClass(stream) === "Stream/Input/Audio";
  }

  function deviceName(node) {
    return node?.description || node?.nickname || node?.name || "Unknown";
  }

  function appName(stream) {
    return stream?.properties["application.name"] || stream?.description || stream?.name || "Unknown";
  }

  function appIcon(stream) {
    const properties = stream?.properties ?? {};
    return properties["application.icon-name"] || properties["application.process.binary"] || appName(stream);
  }
}
