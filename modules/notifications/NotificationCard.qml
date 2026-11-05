import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs.config
import qs.components
import qs.services

Item {
  id: root

  required property var notification

  readonly property bool critical: notification?.urgency === NotificationUrgency.Critical
  readonly property int timeout: notification?.expireTimeout > 0
    ? notification.expireTimeout * 1000
    : Notifications.defaultTimeout

  // Spread into a plain array so it can be filtered
  readonly property var actions: [...(notification?.actions ?? [])]

  // "default" means "open what this is about": run it by clicking the card, not as a button
  readonly property var defaultAction: actions.find(action => action.identifier === "default") ?? null
  readonly property var buttonActions: actions.filter(action => action.identifier !== "default")

  // How far the card must be swiped (as a fraction of its width) to dismiss it
  readonly property real swipeThreshold: 0.35

  // Swipe feel
  readonly property real heldScale: 0.97 // size while pressed / dragged
  readonly property real maxTilt: 4 // degrees of rotation at a full-width swipe

  implicitHeight: card.height

  // Card and shadow move together, so the shadow follows the tilt and scale too
  Item {
    id: swipeLayer

    width: parent.width
    height: card.height

    // How far along the swipe is, 0 to 1
    readonly property real progress: Math.min(1, x / width)

    opacity: 1 - progress
    rotation: progress * root.maxTilt
    scale: swipe.active || press.pressed ? root.heldScale : 1
    transformOrigin: Item.Left // tilts around the edge it's moving away from

    // Follow the pointer directly while dragging; animate snapping back or flying off
    Behavior on x {
      enabled: !swipe.active
      NumberAnimation { duration: Theme.revealDuration; easing.type: Easing.OutCubic }
    }

    Behavior on scale {
      NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
    }

    // Swipe toward the screen edge to dismiss
    DragHandler {
      id: swipe

      target: swipeLayer
      yAxis.enabled: false
      xAxis.minimum: 0

      onActiveChanged: {
        if (active)
          return;

        if (swipeLayer.progress > root.swipeThreshold) {
          swipeLayer.x = swipeLayer.width;
          dismissTimer.start();
        } else {
          swipeLayer.x = 0;
        }
      }
    }

    // Lets the fly-off animation finish before the notification is removed
    Timer {
      id: dismissTimer
      interval: Theme.revealDuration
      onTriggered: root.notification?.dismiss()
    }

    Shadow {
      target: card
    }

    Rectangle {
      id: card

      width: parent.width
      height: content.implicitHeight + Theme.notificationPadding * 2
      radius: Theme.barRadius
      color: Theme.background
      border.width: root.critical ? 2 : 0
      border.color: Theme.error

      HoverHandler {
        id: hover
      }

      // Hide after the timeout; hovering pauses it, critical ones stay until dismissed
      Timer {
        running: !root.critical && !hover.hovered && !swipe.active
        interval: root.timeout
        onTriggered: Notifications.hidePopup(root.notification)
      }

      // Click to follow through: run the default action if there is one, otherwise just hide the popup.
      // Action pills sit on top and take their own clicks.
      MouseArea {
        id: press

        anchors.fill: parent
        cursorShape: root.defaultAction ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
          if (root.defaultAction)
            root.defaultAction.invoke();
          Notifications.hidePopup(root.notification);
        }
      }

      RowLayout {
        id: content

        anchors {
          left: parent.left
          right: parent.right
          top: parent.top
          margins: Theme.notificationPadding
        }
        spacing: Theme.notificationPadding

        // Notification image if it has one, otherwise the app icon (or a star)
        Item {
          Layout.alignment: Qt.AlignVCenter
          implicitWidth: Theme.notificationIconSize
          implicitHeight: Theme.notificationIconSize

          Image {
            anchors.fill: parent
            visible: source.toString() !== ""
            source: root.notification?.image ?? ""
            fillMode: Image.PreserveAspectCrop
          }

          WindowIcon {
            anchors.fill: parent
            visible: !(root.notification?.image)
            appId: root.notification?.appIcon || root.notification?.appName || ""
            implicitSize: Theme.notificationIconSize
          }
        }

        ColumnLayout {
          Layout.fillWidth: true
          spacing: 2

          StyledText {
            text: root.notification?.appName ?? ""
            color: Theme.muted
            font.pixelSize: Theme.sizeSmall
          }

          StyledText {
            Layout.fillWidth: true
            text: root.notification?.summary ?? ""
            font.bold: true
            elide: Text.ElideRight
          }

          StyledText {
            Layout.fillWidth: true
            visible: text !== ""
            text: root.notification?.body ?? ""
            textFormat: Text.StyledText
            wrapMode: Text.Wrap
            maximumLineCount: 4
            elide: Text.ElideRight
          }

          // Remaining actions as small pills, right-aligned; wraps if there are many
          Flow {
            Layout.fillWidth: true
            Layout.topMargin: 4
            visible: root.buttonActions.length > 0
            layoutDirection: Qt.RightToLeft
            spacing: 4

            Repeater {
              model: root.buttonActions

              delegate: Rectangle {
                id: action

                required property var modelData

                implicitWidth: actionText.implicitWidth + 16
                implicitHeight: 20
                radius: height / 2
                color: actionArea.containsMouse ? Theme.shade(Theme.surface, 0.15) : Theme.surface

                StyledText {
                  id: actionText

                  anchors.centerIn: parent
                  text: action.modelData.text
                  font.pixelSize: Theme.sizeSmall
                }

                MouseArea {
                  id: actionArea

                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: action.modelData.invoke()
                }
              }
            }
          }
        }
      }
    }
  }
}
