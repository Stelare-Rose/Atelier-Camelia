import Quickshell
import Quickshell.Hyprland
import QtQuick


PanelWindow {
  id: bar
  property date someProperty
  anchors {
    top: true
    left: true
    right: true
  }
  property bool revealed: false
  property bool locked: false
  exclusionMode: locked ? ExclusionMode.Auto : ExclusionMode.Ignore
  implicitHeight: (revealed || locked) ? 28 : 0
  color: "transparent"
  
  GlobalShortcut {
    appid: "atelier-camelia"
    name: "barReveal"
    onPressed: bar.revealed = true
    onReleased: bar.revealed = false
  }

  GlobalShortcut {
    appid: "atelier-camelia"
    name: "barLock"
    onPressed: bar.locked = !bar.locked
  }
  Behavior on implicitHeight {
    NumberAnimation {
      duration: 150
      easing.type: Easing.OutCubic
    }
  }

  Rectangle {
    anchors.topMargin: 2
    anchors.leftMargin: 8
    anchors.rightMargin: 8
    anchors.bottomMargin: 2
    anchors.fill: parent
    radius: 16
    color: "#F8F4E9"
    Row {
      anchors.centerIn: parent
      spacing: 20

      Text {
        text: "meep moop"
        color: "black"
      }

      Text {
        text: someProperty
        color: "black"
      }
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: someProperty = new Date()
  }
}
