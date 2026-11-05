import QtQuick
import Quickshell
import qs.config

// Shows a 0–1 value as a percentage. Click to type a new one,
// Enter to apply, Escape to cancel.
TextInput {
  id: root

  property real value: 0
  property real maximum: 1

  // The popup window this input is in; asked for the keyboard while editing
  readonly property var popupWindow: QsWindow.window

  signal valueEntered(real value)

  // Show the live value whenever we're not editing
  Binding on text {
    value: Math.round(root.value * 100) + "%"
    when: !root.activeFocus
  }

  color: Theme.foreground
  font.family: Theme.fontSans
  font.pixelSize: Theme.sizeNormal
  horizontalAlignment: Text.AlignRight
  selectByMouse: true
  validator: RegularExpressionValidator { regularExpression: /^\d{0,3}%?$/ }

  // Start editing with just the number, selected, so typing replaces it.
  // Hand the keyboard back once editing ends.
   onActiveFocusChanged: {
    if (activeFocus) {
      text = String(Math.round(value * 100));
      selectAll();
    } else if (popupWindow && "keyboardGrabbed" in popupWindow) {
      popupWindow.keyboardGrabbed = false;
    }
  }

  onAccepted: {
    const number = parseInt(text);
    if (!isNaN(number))
    valueEntered(Math.min(number / 100, maximum));
    focus = false;
  }

  Keys.onEscapePressed: focus = false
   TapHandler {
    onPressedChanged: {
      if (!pressed)
        return;

      if (root.popupWindow && "keyboardGrabbed" in root.popupWindow)
        root.popupWindow.keyboardGrabbed = true;
      else
        console.warn("PercentInput: window has no keyboardGrabbed property:", root.popupWindow);

      root.forceActiveFocus();
    }
  }
}
