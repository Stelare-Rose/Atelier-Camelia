import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services
import qs.modules.bar

PanelWindow {
  id: root

  // What the popups stack below; both optional
  property Bar topBar: null
  property CalendarPopup calendar: null

  readonly property int shadowRoom: Theme.shadowBlurMax + Theme.shadowOffset

  readonly property real barBottom: topBar ? Math.max(0, topBar.thickness - topBar.offset) : 0

  property real calendarBottom: calendar && calendar.open ? calendar.bottom : 0

  Behavior on calendarBottom {
    NumberAnimation { duration: Theme.revealDuration; easing.type: Easing.OutCubic }
  }

  readonly property real listTop: Math.max(barBottom, calendarBottom) + Theme.barMargin

  anchors {
    top: true
    right: true
    bottom: true
  }

  implicitWidth: Theme.notificationWidth + shadowRoom + Theme.barMargin
  color: "transparent"

  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "camelia-notifications"

  // Only the notifications take input, not the empty column
  mask: Region {
    item: list
  }

  ListView {
    id: list

    x: root.shadowRoom
    y: root.listTop
    width: Theme.notificationWidth
    height: contentHeight
    spacing: Theme.notificationSpacing
    interactive: false

    // ScriptModel turns the plain array into a model with proper add/remove
    // events, so the transitions below can animate
    model: ScriptModel {
      values: Notifications.popups
    }

    delegate: NotificationCard {
      required property var modelData

      notification: modelData
      width: list.width
    }

    add: Transition {
      NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.revealDuration }
      NumberAnimation { property: "x"; from: 40; to: 0; duration: Theme.revealDuration; easing.type: Easing.OutCubic }
    }

    remove: Transition {
      NumberAnimation { property: "opacity"; to: 0; duration: Theme.revealDuration }
      NumberAnimation { property: "x"; to: 40; duration: Theme.revealDuration; easing.type: Easing.InCubic }
    }

    displaced: Transition {
      NumberAnimation { property: "y"; duration: Theme.revealDuration; easing.type: Easing.OutCubic }
    }
  }
}
