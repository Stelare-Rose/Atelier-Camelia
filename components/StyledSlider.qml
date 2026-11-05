import QtQuick
import QtQuick.Controls
import qs.config

Slider {
  id: root

  implicitHeight: 20

  background: Rectangle {
    x: root.leftPadding
    y: root.topPadding + root.availableHeight / 2 - height / 2
    width: root.availableWidth
    height: 6
    radius: 3
    color: Theme.surfaceAlt

    Rectangle {
      width: root.visualPosition * parent.width
      height: parent.height
      radius: parent.radius
      color: Theme.accent
    }
  }

  handle: Rectangle {
    x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
    y: root.topPadding + root.availableHeight / 2 - height / 2
    width: 14
    height: 14
    radius: 7
    color: Theme.foreground
  }
}
