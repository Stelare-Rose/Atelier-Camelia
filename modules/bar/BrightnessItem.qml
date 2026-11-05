import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.components
import qs.services
import qs.utils

StatItem {
  id: root

  required property ShellScreen screen

  readonly property var monitor: Brightness.forScreen(screen)
  readonly property alias popup: popup

  visible: monitor?.available ?? false
  icon: "\u{F00DF}" // nf-md-brightness_6
  label: Format.percent(monitor?.brightness ?? 0)
  textColor: Theme.accent

  HoverHandler {
    id: hover
  }

  // Scroll on the bar item to adjust without opening anything
  WheelHandler {
    onWheel: event => root.monitor.setBrightness(root.monitor.brightness + (event.angleDelta.y > 0 ? 0.05 : -0.05))
  }

  BarPopup {
    id: popup

    anchorItem: root
    triggerHovered: hover.hovered

    // Pick up changes made elsewhere (monitor buttons, keyboard keys)
    onOpenChanged: {
      if (open)
      root.monitor?.refresh();
    }

    RowLayout {
      width: 220
      spacing: Theme.barSpacing

      StyledText {
        isMono: true
        text: root.icon
      }

      StyledSlider {
        id: slider

        Layout.fillWidth: true
        from: 0
        to: 1
        onMoved: root.monitor.setBrightness(value)

        // Follow the monitor's value, except while being dragged
        Binding on value {
          value: root.monitor?.brightness ?? 0
          when: !slider.pressed
        }
      }

      StyledText {
        text: root.label
      }
    }
  }
}
