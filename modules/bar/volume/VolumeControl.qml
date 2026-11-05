import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components
import qs.services
import qs.utils

RowLayout {
  id: root

  required property var node
  property bool input: false

  readonly property real volume: node?.audio?.volume ?? 0
  readonly property bool muted: node?.audio?.muted ?? false

  spacing: Theme.barSpacing

  // Click the icon to mute
  StyledText {
    isMono: true
    text: {
      if (root.input)
      return root.muted ? "\u{F036D}" : "\u{F036C}"; // nf-md-microphone_off / microphone
      return root.muted ? "\u{F0581}" : "\u{F057E}"; // nf-md-volume_off / volume_high
    }
    color: root.muted ? Theme.muted : Theme.foreground

    TapHandler {
      onTapped: Audio.toggleMute(root.node)
    }
  }

  StyledSlider {
    id: slider

    Layout.fillWidth: true
    from: 0
    to: Audio.maxVolume
    enabled: !!root.node?.audio
    onMoved: Audio.setVolume(root.node, value)

    // Follow the real volume, except while being dragged
    Binding on value {
      value: root.volume
      when: !slider.pressed
    }
  }

  PercentInput {
    Layout.preferredWidth: 40
    value: root.volume
    maximum: Audio.maxVolume
    color: root.muted ? Theme.muted : Theme.foreground
    onValueEntered: value => Audio.setVolume(root.node, value)
  }
}
