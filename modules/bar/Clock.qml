import QtQuick
import Quickshell
import qs.config

Row {
  id: root

  readonly property alias calendarOpen: calendar.shown
  readonly property alias calendar: calendar

  readonly property bool hovered: clockHover.hovered || calendar.hovered

  onHoveredChanged: {
    if (hovered) {
      closeTimer.stop();
      calendar.open = true;
    } else {
      closeTimer.restart();
    }
  }

  spacing: Theme.barSpacing

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  HoverHandler {
    id: clockHover
  }

  Timer {
    id: closeTimer
    interval: Theme.hideDelay
    onTriggered: calendar.open = false
  }

  StatItem {
    icon: "\u{F00ED}" // nf-md-calendar
    label: Qt.formatDate(clock.date, "ddd d MMM")
    textColor: Theme.accent
  }

  StatItem {
    icon: "\u{F0150}" // nf-md-clock_outline
    label: Qt.formatTime(clock.date, "HH:mm")
    textColor: Theme.accent
  }

  CalendarPopup {
    id: calendar
    anchorItem: root
  }
}
