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

  implicitHeight: card.height

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
      running: !root.critical && !hover.hovered
      interval: root.timeout
      onTriggered: Notifications.hidePopup(root.notification)
    }

    // Clicking the card dismisses it (action buttons sit on top and take their own clicks)
    MouseArea {
      anchors.fill: parent
      onClicked: root.notification?.dismiss()
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

        RowLayout {
          Layout.fillWidth: true
          Layout.topMargin: 6
          visible: actionRepeater.count > 0
          spacing: 6

          Repeater {
            id: actionRepeater

            model: root.notification?.actions ?? []

            delegate: Rectangle {
              id: action

              required property var modelData

              Layout.fillWidth: true
              implicitHeight: 28
              radius: Theme.workspaceRadius
              color: actionArea.containsMouse ? Theme.shade(Theme.surface, 0.15) : Theme.surface

              StyledText {
                anchors.centerIn: parent
                text: action.modelData.text
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
