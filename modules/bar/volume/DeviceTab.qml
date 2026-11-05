import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components
import qs.services

ColumnLayout {
  id: root

  required property bool input

  readonly property var device: input ? Audio.source : Audio.sink
  readonly property var devices: input ? Audio.inputDevices : Audio.outputDevices

  spacing: Theme.barSpacing

  StyledText {
    text: root.input ? "Default input" : "Default output"
    color: Theme.muted
    font.pixelSize: Theme.sizeSmall
  }

  StyledDropdown {
    Layout.fillWidth: true
    model: root.devices
    current: root.device
    label: node => Audio.deviceName(node)
    onSelected: item => root.input ? Audio.setDefaultInput(item) : Audio.setDefaultOutput(item)
  }

  VolumeControl {
    Layout.fillWidth: true
    node: root.device
    input: root.input
  }

  // Keep everything at the top of the tab
  Item {
    Layout.fillHeight: true
  }
}
