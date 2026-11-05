import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components
import qs.utils

PanelWindow {
  id: root

  required property Item anchorItem

  property bool open: false
  readonly property alias hovered: popupHover.hovered

  readonly property bool shown: open || fadeTimer.running
  readonly property int shadowRoom: Theme.shadowBlurMax + Theme.shadowOffset

  readonly property real bottom: margins.top + shadowRoom + card.height

  visible: shown

  Timer {
    id: fadeTimer
    interval: Theme.revealDuration
  }

  property int month: new Date().getMonth()
  property int year: new Date().getFullYear()

  function changeMonth(delta) {
    const date = new Date(year, month + delta, 1);
    month = date.getMonth();
    year = date.getFullYear();
  }

  readonly property var barWindow: anchorItem.QsWindow.window

  // mapToItem() isn't reactive to position changes, so recompute explicitly
  property real anchorRight: 0
  function updateAnchor() {
    anchorRight = anchorItem.mapToItem(null, anchorItem.width, 0).x;
  }

  Connections {
    target: root.anchorItem
    function onXChanged() { root.updateAnchor(); }
    function onWidthChanged() { root.updateAnchor(); }
  }

  Component.onCompleted: updateAnchor()

  screen: barWindow.screen

  anchors {
    top: true
    right: true
  }

  onOpenChanged: {
    if (!open) {
      fadeTimer.restart();
      return;
    }

    fadeTimer.stop();
    updateAnchor();

    const today = new Date();
    month = today.getMonth();
    year = today.getFullYear();
  }

  implicitWidth: card.width + shadowRoom * 2
  implicitHeight: card.height + shadowRoom * 2

  margins.top: barWindow.size - shadowRoom
  margins.right: barWindow.width - anchorRight - shadowRoom
  color: "transparent"

  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.namespace: "camelia-popup"

  mask: open ? cardRegion : emptyRegion

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


      readonly property int cellSize: 28

      width: 260
      implicitHeight: layout.implicitHeight + Theme.barSidePadding * 4
      radius: Theme.barRadius
      color: Theme.background
      Behavior on y {
        NumberAnimation { duration: Theme.revealDuration; easing.type: Easing.OutCubic }
      }
    }

    HoverHandler {
      id: popupHover
    }

    WheelHandler {
      property real acc: 0

      acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
      orientation: Qt.Vertical

      onWheel: event => {
        acc += event.angleDelta.y;
        while (acc >= 120) {
          acc -= 120;
          root.changeMonth(-1);
        }
        while (acc <= -120) {
          acc += 120;
          root.changeMonth(1);
        }
      }
    }

    ColumnLayout {
      id: layout

      anchors.fill: parent
      anchors.margins: Theme.barSidePadding * 2
      spacing: Theme.barSpacing

      // Header: < Month Year >
      RowLayout {
        Layout.fillWidth: true

        StyledText {
          isMono: true
          text: "\u{F0141}" // nf-md-chevron_left
          TapHandler { onTapped: root.changeMonth(-1) }
        }

        StyledText {
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignHCenter
          text: new Date(root.year, root.month, 1).toLocaleDateString(Qt.locale(), "MMMM yyyy")
        }

        StyledText {
          isMono: true
          text: "\u{F0142}" // nf-md-chevron_right
          TapHandler { onTapped: root.changeMonth(1) }
        }
      }

      DayOfWeekRow {
        Layout.fillWidth: true
        locale: grid.locale

        delegate: StyledText {
          required property var model
          horizontalAlignment: Text.AlignHCenter
          text: model.shortName
          color: Theme.muted
        }
      }

      MonthGrid {
        id: grid

        Layout.fillWidth: true
        Layout.preferredHeight: 6 * card.cellSize + 5 * spacing // six weeks
        spacing: 0
        month: root.month
        year: root.year

        delegate: Item {
          id: cell

          required property var model

          implicitWidth: card.cellSize
          implicitHeight: card.cellSize

          Rectangle {
            anchors.centerIn: parent
            width: card.cellSize
            height: card.cellSize
            radius: width / 2
            color: cell.model.today ? Theme.accent : "transparent"
          }

          StyledText {
            anchors.centerIn: parent
            text: cell.model.day
            color: {
              if (cell.model.today)
              return Theme.background;
              if (cell.model.month !== grid.month)
              return Theme.muted;
              return Theme.foreground;
            }
          }
        }      
      }
    }
  }
}
