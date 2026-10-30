import QtQuick

Timer {
  property var value
  interval: 1000
  running: true
  repeat: true
  onTriggered: console.log("debug =", value)
}

