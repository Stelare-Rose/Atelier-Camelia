import QtQuick
import QtQuick.Layouts
import qs.config

RowLayout {
  id: root

  property list<string> tabs: []
  property int currentIndex: 0

  spacing: 4

  Repeater {
    model: root.tabs

    delegate: Rectangle {
      id: tab

      required property string modelData
      required property int index

      readonly property bool current: index === root.currentIndex

      Layout.fillWidth: true
      implicitHeight: 28
      radius: Theme.workspaceRadius
      color: {
        if (current)
        return Theme.surfaceAlt;
        if (tabArea.containsMouse)
        return Theme.shade(Theme.background, 0.1);
        return "transparent";
      }

      StyledText {
        anchors.centerIn: parent
        text: tab.modelData
        color: tab.current ? Theme.foreground : Theme.muted
      }

      MouseArea {
        id: tabArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.currentIndex = tab.index
      }
    }
  }
}
