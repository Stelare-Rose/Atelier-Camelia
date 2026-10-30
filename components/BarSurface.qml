import QtQuick
import QtQuick.Layouts
import qs.config

Rectangle {
  id: root

  property bool vertical: false
  default property alias content: layout.data

  radius: Theme.barRadius
  color: Theme.background

  property int endPadding: Theme.barEndPadding
  property int sidePadding: Theme.barSidePadding

  border.width: 2
  border.color: Theme.border

  GridLayout {
    id: layout

    anchors.fill: parent
    anchors {
      fill: parent
      leftMargin: root.vertical ? root.sidePadding : root.endPadding
      rightMargin: root.vertical ? root.sidePadding : root.endPadding
      topMargin: root.vertical ? root.endPadding : root.sidePadding
      bottomMargin: root.vertical ? root.endPadding : root.sidePadding
    }
    flow: root.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
    rowSpacing: Theme.barSpacing
    columnSpacing: Theme.barSpacing
  }
}
