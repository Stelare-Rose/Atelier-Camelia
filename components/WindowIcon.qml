import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.config

Item {
    id: root

    required property string appId
    property real implicitSize: 16

    readonly property string iconSource: {
        if (!root.appId)
            return "";

        const entry = DesktopEntries.heuristicLookup(root.appId);
        return Quickshell.iconPath(entry?.icon ?? root.appId, true);
    }

    implicitWidth: implicitSize
    implicitHeight: implicitSize

    IconImage {
        anchors.fill: parent
        visible: root.iconSource !== ""
        source: root.iconSource
    }

    StyledText {
        anchors.centerIn: parent
        visible: root.iconSource === ""
        isMono: true
        text: "\u{F0AE2}"
        color: Theme.accentFor(root.appId)
        font.pixelSize: root.implicitSize
    }
}
