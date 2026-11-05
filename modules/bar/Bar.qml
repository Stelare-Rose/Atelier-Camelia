import QtQuick
import Quickshell
import Quickshell.Wayland
import QtQuick.Effects
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

  property var popups: []

  readonly property bool held: pinned || keepOpen || popups.some(popup => popup.shown)

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

  readonly property int shadowRoom: Theme.shadowBlurMax + Theme.shadowOffset

  readonly property int windowStartMargin: Math.max(0, startInset - shadowRoom)
  readonly property int windowEndMargin: Math.max(0, endInset - shadowRoom)

  readonly property int surfaceStart: startInset - windowStartMargin + Theme.barMargin
  readonly property int surfaceEnd: endInset - windowEndMargin + Theme.barMargin

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

  property real offset: revealed ? 0 : size + shadowRoom

  margins {
    top: vertical ? windowStartMargin : 0
    bottom: vertical ? windowEndMargin : 0
    left: vertical ? 0 : windowStartMargin
    right: vertical ? 0 : windowEndMargin
  }

  implicitWidth: vertical ? size + shadowRoom : 0
  implicitHeight: vertical ? 0 : size + shadowRoom

  // Reserve the bar itself, not the shadow room
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
  Item {
    id: surfaceContainer

    width: root.vertical ? root.thickness : parent.width - root.surfaceStart - root.surfaceEnd
    height: root.vertical ? parent.height - root.surfaceStart - root.surfaceEnd : root.thickness
    x: root.vertical ? (root.edge === Bar.Right ? parent.width - width : 0) : root.surfaceStart
    y: root.vertical ? root.surfaceStart : (root.edge === Bar.Bottom ? parent.height - height : 0) 

    transform: Translate {
      x: root.edge === Bar.Left ? -root.offset : root.edge === Bar.Right ? root.offset : 0
      y: root.edge === Bar.Top ? -root.offset : root.edge === Bar.Bottom ? root.offset : 0
    }

    Shadow {
      target: surface
      offsetX: root.vertical ? (root.edge === Bar.Left ? Theme.shadowOffset : -Theme.shadowOffset) : 0
      offsetY: root.vertical ? 0 : (root.edge === Bar.Top ? Theme.shadowOffset : -Theme.shadowOffset)
    }
    BarSurface {
      id: surface

      anchors.fill: parent
      vertical: root.vertical
      attachedEdge: {
        switch (root.edge) {
          case Bar.Top: return Edges.Top;
          case Bar.Bottom: return Edges.Bottom;
          case Bar.Left: return Edges.Left;
          case Bar.Right: return Edges.Right;
        }
      }
    }
  }}
