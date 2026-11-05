import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.config
import qs.components
import qs.services

// One app's audio stream: its name, volume, and the device it uses
Rectangle {
  id: root

  required property var stream

  readonly property bool recording: Audio.isRecording(stream)
  readonly property var devices: recording ? Audio.inputDevices : Audio.outputDevices
  readonly property var device: {
    const id = root.stream.id;

    for (const group of Pipewire.linkGroups.values) {
      let other = null;
      if (group.source?.id === id)
      other = group.target;
      else if (group.target?.id === id)
      other = group.source;

      // The other end should be a device, not another app's stream
      if (other && !Audio.mediaClass(other).startsWith("Stream/"))
      return other;
    }

    return null;
  }

  implicitHeight: column.implicitHeight + 16
  radius: Theme.workspaceRadius
  color: Theme.surface

  ColumnLayout {
    id: column

    anchors {
      left: parent.left
      right: parent.right
      top: parent.top
      margins: 8
    }
    spacing: 4

    RowLayout {
      Layout.fillWidth: true
      spacing: 6

      WindowIcon {
        appId: Audio.appIcon(root.stream)
        implicitSize: 18
      }

      StyledText {
        Layout.fillWidth: true
        text: Audio.appName(root.stream)
        elide: Text.ElideRight
      }

      // Marks recording streams (e.g. a call app using the mic)
      StyledText {
        visible: root.recording
        isMono: true
        text: "\u{F036C}" // nf-md-microphone
        color: Theme.accent
      }
    }

    VolumeControl {
      Layout.fillWidth: true
      node: root.stream
      input: root.recording
    }

    StyledDropdown {
      Layout.fillWidth: true
      model: root.devices
      current: root.device
      label: node => Audio.deviceName(node)
      onSelected: item => Audio.moveStream(root.stream, item)
    }
  }
}
