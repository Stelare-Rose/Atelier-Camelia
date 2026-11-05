import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config

// A card that drops down below a widget in the top bar.
// Opens while the widget (triggerHovered) or the card itself is hovered,
// and closes shortly after both are left. Put the content inside it;
// the card sizes itself to fit.
PanelWindow {
  id: root

  required property Item anchorItem
  property bool triggerHovered: false
  property int padding: Theme.barSidePadding * 2

  default property alias content: contentArea.data

  property bool open: false
  readonly property bool hovered: popupHover.hovered

  // Set while something in the popup needs typing input (e.g. PercentInput)
  property bool keyboardGrabbed: false

  // True while open, and for the length of the fade-out after closing
  readonly property bool shown: open || fadeTimer.running

  // Bottom edge of the card in screen coordinates, for things that stack below it
  readonly property real bottom: margins.top + shadowRoom + card.height

  readonly property int shadowRoom: Theme.shadowBlurMax + Theme.shadowOffset
  readonly property var barWindow: anchorItem.QsWindow.window
  readonly property bool wantsOpen: triggerHovered || hovered || keyboardGrabbed

  // mapToItem() isn't reactive, so this is recomputed when the anchor moves or resizes
  property real anchorRight: 0

  function updateAnchor() {
    anchorRight = anchorItem.mapToItem(null, anchorItem.width, 0).x;
  }

  function grabKeyboard() {
    keyboardGrabbed = true;
  }

  function releaseKeyboard() {
    keyboardGrabbed = false;
  }

  screen: barWindow?.screen ?? null

  anchors {
    top: true
    right: true
  }

  margins.top: (barWindow?.size ?? 0) - shadowRoom
  margins.right: (barWindow?.width ?? 0) - anchorRight - shadowRoom

  implicitWidth: card.width + shadowRoom * 2
  implicitHeight: card.height + shadowRoom * 2
  color: "transparent"
  visible: shown

  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.namespace: "stelare-popup"
  WlrLayershell.keyboardFocus: keyboardGrabbed ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  mask: open ? cardRegion : emptyRegion

  onWantsOpenChanged: {
    if (wantsOpen) {
      closeTimer.stop();
      open = true;
    } else {
      closeTimer.restart();
    }
  }

  onOpenChanged: {
    if (open) {
      fadeTimer.stop();
      updateAnchor();
    } else {
      fadeTimer.restart();
      releaseKeyboard();
    }
  }

  // Register with the bar so it stays open while this popup is shown.
  // barWindow is null for a moment at startup, so this runs when it's set.
  onBarWindowChanged: {
    if (barWindow && !barWindow.popups.includes(root))
      barWindow.popups = barWindow.popups.concat([root]);
  }

  Component.onCompleted: updateAnchor()

  Component.onDestruction: {
    if (barWindow)
      barWindow.popups = barWindow.popups.filter(popup => popup !== root);
  }

  Connections {
    target: root.anchorItem

    function onXChanged() {
      root.updateAnchor();
    }

    function onWidthChanged() {
      root.updateAnchor();
    }
  }

  Timer {
    id: closeTimer
    interval: Theme.hideDelay
    onTriggered: root.open = false
  }

  Timer {
    id: fadeTimer
    interval: Theme.revealDuration
  }

  Region {
    id: cardRegion
    item: card
  }

  Region {
    id: emptyRegion
  }

  Item {
    id: panel

    x: root.shadowRoom
    y: root.shadowRoom
    width: card.width
    height: card.height

    opacity: root.open ? 1 : 0

    Behavior on opacity {
      NumberAnimation { duration: Theme.revealDuration; easing.type: Easing.OutCubic }
    }

    transform: Translate {
      y: root.open ? 0 : -8

      Behavior on y {
        NumberAnimation { duration: Theme.revealDuration; easing.type: Easing.OutCubic }
      }
    }

    Shadow {
      target: card
    }

    Rectangle {
      id: card

      width: contentArea.width + root.padding * 2
      height: contentArea.height + root.padding * 2
      radius: Theme.barRadius
      color: Theme.background

      HoverHandler {
        id: popupHover
      }

      Item {
        id: contentArea

        x: root.padding
        y: root.padding
        width: childrenRect.width
        height: childrenRect.height
      }
    }
  }
}
