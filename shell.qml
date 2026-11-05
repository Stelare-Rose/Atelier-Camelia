import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.components
import qs.services
import qs.modules.bar
import qs.modules.notifications

ShellRoot {
  Variants {
    model: Quickshell.screens

    delegate: Scope {
      id: screenScope

      required property ShellScreen modelData

      Bar {
        id: topBar
        screen: screenScope.modelData
        edge: Bar.Top

        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true

          Resources {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
          }

          Workspaces {
            anchors.centerIn: parent
            screen: screenScope.modelData
          }

          Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.barSpacing

            BrightnessItem { screen: screenScope.modelData }
            VolumeItem {}
            Battery {}
            Clock {}
          }
        }
      }

       Bar {
         id: bottomBar
         screen: screenScope.modelData
         edge: Bar.Bottom

         Text { text: "bottom"; color: Theme.foreground }
       }

       NotificationPopups {
         popups: topBar.popups
         screen: screenScope.modelData
         visible: screenScope.modelData.name === Niri.focusedOutput
         topBar: topBar
       }
     }
  }
}
