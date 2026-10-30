import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components

PanelWindow {
  id: root

  enum Edge {
    Top,
    Bottom,
    Left,
    Right
  }
  property bool keepOpen: false

  readonly property bool held: pinned || keepOpen

  onHeldChanged: {
    if (held) {
      hideTimer.stop();
      revealed = true;
    } else if (!hover.hovered) {
      hideTimer.restart();
    }
  }

  onPinnedChanged: {
    if (pinned) {
      hideTimer.stop();
      revealed = true;
    } else if (!hover.hovered) {
      hideTimer.restart();
    }
  }


  property bool pinned: false
  property int edge: Bar.Top
  property bool autoHide: true

  property int thickness: Theme.barThickness

  readonly property int size: thickness + Theme.barMargin * 2

  property real offset: revealed ? 0 : size

  property int startInset: 0
  property int endInset: 0

  default property alias content: surface.content

  readonly property bool vertical: edge === Bar.Left || edge === Bar.Right
  property bool revealed: !autoHide

  // How far the surface is pushed off-screen

  Behavior on offset {
    NumberAnimation {
      duration: Theme.revealDuration
      easing.type: Easing.OutCubic
    }
  }

  anchors {
    top: edge !== Bar.Bottom
    bottom: edge !== Bar.Top
    left: edge !== Bar.Right
    right: edge !== Bar.Left
  }

  margins {
    top: vertical ? startInset : 0
    bottom: vertical ? endInset : 0
    left: vertical ? 0 : startInset
    right: vertical ? 0 : endInset
  }

  implicitWidth: vertical ? size : 0
  implicitHeight: vertical ? 0 : size
  exclusiveZone: autoHide && !pinned ? 0 : size

  color: "transparent"

  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.namespace: "camelia-bar"

  mask: Region {
    item: root.revealed ? surface : trigger
  }

  Item {
    id: trigger

    width: root.vertical ? Theme.triggerSize : parent.width
    height: root.vertical ? parent.height : Theme.triggerSize
    x: root.edge === Bar.Right ? parent.width - width : 0
    y: root.edge === Bar.Bottom ? parent.height - height : 0
  }

  HoverHandler {
    id: hover
    enabled: root.autoHide
    onHoveredChanged: {
      if (hovered) {
        hideTimer.stop();
        root.revealed = true;
      } else if (!root.held) {
        hideTimer.restart();
      }
    }
  }

  TapHandler {
    acceptedButtons: Qt.MiddleButton
    onTapped: root.pinned = !root.pinned
  }

  Timer {
    id: hideTimer
    interval: Theme.hideDelay
    onTriggered: root.revealed = false
  }

  BarSurface {
    id: surface

    vertical: root.vertical

    width: root.vertical ? root.thickness : parent.width - Theme.barMargin * 2
    height: root.vertical ? parent.height - Theme.barMargin * 2 : root.thickness
    x: root.vertical ? (root.edge === Bar.Right ? parent.width - width : 0) : Theme.barMargin
    y: root.vertical ? Theme.barMargin : (root.edge === Bar.Bottom ? parent.height - height : 0)

    transform: Translate {
      x: root.edge === Bar.Left ? -root.offset : root.edge === Bar.Right ? root.offset : 0
      y: root.edge === Bar.Top ? -root.offset : root.edge === Bar.Bottom ? root.offset : 0
    }
  }
}
