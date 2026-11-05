import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components
import qs.services
import qs.utils
import qs.modules.bar.volume

StatItem {
  id: root

  readonly property real volume: Audio.sink?.audio?.volume ?? 0
  readonly property bool muted: Audio.sink?.audio?.muted ?? false
  readonly property bool micMuted: Audio.source?.audio?.muted ?? false

  readonly property alias popup: popup

  icon: {
    if (muted || volume === 0)
    return "\u{F0581}"; // nf-md-volume_off
    if (volume < 0.34)
    return "\u{F057F}"; // nf-md-volume_low
    if (volume < 0.67)
    return "\u{F0580}"; // nf-md-volume_medium
    return "\u{F057E}"; // nf-md-volume_high
  }
  label: muted ? "Muted" : Format.percent(volume)
  textColor: muted ? Theme.muted : Theme.accent

  HoverHandler {
    id: hover
  }

  WheelHandler {
    onWheel: event => Audio.setVolume(Audio.sink, root.volume + (event.angleDelta.y > 0 ? 0.05 : -0.05))
  }

  // Mic indicator: shown while something is recording, red if the mic is muted
  StyledText {
    anchors.verticalCenter: parent.verticalCenter
    visible: Audio.micInUse
    isMono: true
    text: root.micMuted ? "\u{F036D}" : "\u{F036C}" // nf-md-microphone_off / microphone
    color: root.micMuted ? Theme.error : Theme.accent
  }

  BarPopup {
    id: popup

    anchorItem: root
    triggerHovered: hover.hovered

    ColumnLayout {
      width: 300
      spacing: Theme.barSpacing

      StyledTabBar {
        id: tabs

        Layout.fillWidth: true
        tabs: ["Output", "Input", "Apps"]
      }

      // Fixed height, so the card doesn't jump in size when switching tabs
      StackLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: 260
        currentIndex: tabs.currentIndex

        DeviceTab {
          input: false
        }

        DeviceTab {
          input: true
        }

        AppsTab {}
      }
    }
  }
}
