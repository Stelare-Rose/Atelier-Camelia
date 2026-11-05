import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

Rectangle {
  id: root

  property bool vertical: false
  property int endPadding: Theme.barEndPadding
  property int sidePadding: Theme.barSidePadding

  // Screen edge the surface is attached to; corners on that side stay square.
  // Edges.None rounds every corner (e.g. a floating surface).
  property int attachedEdge: Edges.None

  default property alias content: layout.data

  color: Theme.background

  topLeftRadius: attachedEdge & (Edges.Top | Edges.Left) ? 0 : Theme.barRadius
  topRightRadius: attachedEdge & (Edges.Top | Edges.Right) ? 0 : Theme.barRadius
  bottomLeftRadius: attachedEdge & (Edges.Bottom | Edges.Left) ? 0 : Theme.barRadius
  bottomRightRadius: attachedEdge & (Edges.Bottom | Edges.Right) ? 0 : Theme.barRadius

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


