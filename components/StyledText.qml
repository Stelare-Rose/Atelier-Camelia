import QtQuick
import qs.config

Text {
  id: root
  property bool isMono: false

  color: Theme.text
  font.family: root.isMono ? Theme.fontMono : Theme.fontSans
  font.pixelSize: Theme.sizeNormal
  renderType: Text.NativeRendering
}
