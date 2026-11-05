import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.config
import qs.components

BarPopup {
  id: root

  readonly property int cellSize: 28

  // Month being shown, separate from today so you can browse
  property int month: new Date().getMonth()
  property int year: new Date().getFullYear()

  function changeMonth(delta) {
    const date = new Date(year, month + delta, 1);
    month = date.getMonth();
    year = date.getFullYear();
  }

  // Always open on the current month
  onOpenChanged: {
    if (open) {
      const today = new Date();
      month = today.getMonth();
      year = today.getFullYear();
    }
  }

  ColumnLayout {
    width: 240
    spacing: Theme.barSpacing

    // Scroll to change month; accumulates so touchpads don't skip months
    WheelHandler {
      property real accumulated: 0

      acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
      orientation: Qt.Vertical

      onWheel: event => {
        accumulated += event.angleDelta.y;

        while (accumulated >= 120) {
          accumulated -= 120;
          root.changeMonth(-1);
        }

        while (accumulated <= -120) {
          accumulated += 120;
          root.changeMonth(1);
        }
      }
    }

    // Header: < Month Year >
    RowLayout {
      Layout.fillWidth: true

      StyledText {
        isMono: true
        text: "\u{F0141}" // nf-md-chevron_left

        TapHandler {
          onTapped: root.changeMonth(-1)
        }
      }

      StyledText {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        text: new Date(root.year, root.month, 1).toLocaleDateString(Qt.locale(), "MMMM yyyy")
      }

      StyledText {
        isMono: true
        text: "\u{F0142}" // nf-md-chevron_right

        TapHandler {
          onTapped: root.changeMonth(1)
        }
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
      Layout.preferredHeight: 6 * root.cellSize // six weeks
      spacing: 0
      month: root.month
      year: root.year

      delegate: Item {
        id: cell

        required property var model

        implicitWidth: root.cellSize
        implicitHeight: root.cellSize

        // Fixed-size circle, so "today" stays round however wide the cell is
        Rectangle {
          anchors.centerIn: parent
          width: root.cellSize
          height: root.cellSize
          radius: width / 2
          color: cell.model.today ? Theme.accent : "transparent"
        }

        StyledText {
          anchors.fill: parent
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
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
