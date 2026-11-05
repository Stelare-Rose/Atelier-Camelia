import QtQuick
import QtQuick.Effects
import qs.config

Item {
    id: root

    required property Rectangle target
    property real offsetX: 0
    property real offsetY: Theme.shadowOffset

    anchors.fill: target

    Rectangle {
        id: caster

        anchors.fill: parent
        visible: false
        color: root.target.color
        topLeftRadius: root.target.topLeftRadius
        topRightRadius: root.target.topRightRadius
        bottomLeftRadius: root.target.bottomLeftRadius
        bottomRightRadius: root.target.bottomRightRadius
    }

    MultiEffect {
        anchors.fill: caster
        source: caster
        shadowEnabled: true
        shadowColor: Theme.shadowColor
        shadowBlur: Theme.shadowBlur
        blurMax: Theme.shadowBlurMax
        shadowHorizontalOffset: root.offsetX
        shadowVerticalOffset: root.offsetY
    }
}
