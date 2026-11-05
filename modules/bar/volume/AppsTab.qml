import QtQuick
import Quickshell
import qs.config
import qs.components
import qs.services

ListView {
  id: root

  clip: true
  spacing: 6

  model: ScriptModel {
    values: Audio.playbackStreams.concat(Audio.recordingStreams)
  }

  delegate: AppRow {
    required property var modelData

    stream: modelData
    width: ListView.view.width
  }

  StyledText {
    anchors.centerIn: parent
    visible: root.count === 0
    text: "No apps are using audio"
    color: Theme.muted
  }
}
