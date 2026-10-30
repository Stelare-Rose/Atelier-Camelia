import QtQuick
import qs.components

Row {
  id: root

  required property string icon
  required property string label
  property color textColor

  spacing: 4

  StyledText {
    anchors.verticalCenter: parent.verticalCenter
    isMono: true
    text: root.icon
    color: root.textColor
  }

  StyledText {
    anchors.verticalCenter: parent.verticalCenter
    text: root.label
    color: root.textColor
  }
}
