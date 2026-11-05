import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components
import qs.services

// Full-screen, transparent overlay on the focused monitor.
// The card sits in the middle; clicking outside it closes the launcher.
PanelWindow {
  id: root

  readonly property int padding: Theme.barSidePadding * 2

  // Drives the animations. Set one frame after the window appears,
  // so the fade doesn't start while the window is still being created.
  property bool revealed: false

  function focusedScreen() {
    for (const screen of Quickshell.screens) {
      if (screen.name === Niri.focusedOutput)
        return screen;
    }
    return Quickshell.screens[0];
  }

  function activateCurrent() {
    Launcher.results[list.currentIndex]?.activate();
  }

  screen: focusedScreen()

  // Set explicitly: shown when opening, hidden only after the fade-out finishes
  visible: false

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "camelia-launcher"
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

  Connections {
    target: Launcher

    function onOpenChanged() {
      if (Launcher.open) {
        fadeTimer.stop();
        search.text = "";
        list.currentIndex = 0;
        root.visible = true;
        revealTimer.restart();
      } else {
        revealTimer.stop();
        root.revealed = false;
        fadeTimer.restart();
      }
    }
  }

  // One frame after opening: start the fade-in and focus the search field
  Timer {
    id: revealTimer
    interval: 16
    onTriggered: {
      root.revealed = true;
      search.forceActiveFocus();
    }
  }

  // Hides the window once the fade-out has finished
  Timer {
    id: fadeTimer
    interval: Theme.revealDuration
    onTriggered: root.visible = false
  }

  // Dimmed backdrop; clicking it closes the launcher
  Rectangle {
    anchors.fill: parent
    color: Qt.rgba(0, 0, 0, 0.25)
    opacity: root.revealed ? 1 : 0

    Behavior on opacity {
      NumberAnimation { duration: Theme.revealDuration; easing.type: Easing.OutCubic }
    }

    MouseArea {
      anchors.fill: parent
      onClicked: Launcher.close()
    }
  }

  Item {
    id: panel

    anchors.centerIn: parent
    width: card.width
    height: card.height

    // Fade only: moving or scaling makes pixel-snapped text shimmer
    opacity: root.revealed ? 1 : 0

    Behavior on opacity {
      NumberAnimation { duration: Theme.revealDuration; easing.type: Easing.OutCubic }
    }

    Shadow {
      target: card
    }

    Rectangle {
      id: card

      width: Theme.launcherWidth
      height: layout.implicitHeight + root.padding * 2
      radius: Theme.barRadius
      color: Theme.background

      // Swallow clicks on the card, so they don't reach the backdrop and close it
      MouseArea {
        anchors.fill: parent
      }

      ColumnLayout {
        id: layout

        anchors {
          left: parent.left
          right: parent.right
          top: parent.top
          margins: root.padding
        }
        spacing: Theme.barSpacing

        // Search field
        Rectangle {
          Layout.fillWidth: true
          implicitHeight: 36
          radius: Theme.workspaceRadius
          color: Theme.surface

          RowLayout {
            anchors {
              fill: parent
              leftMargin: 10
              rightMargin: 10
            }
            spacing: 8

            StyledText {
              isMono: true
              text: Launcher.mode === "clipboard" ? "\u{F0192}" : "\u{F0349}" // nf-md-content_paste / magnify
              color: Theme.muted
            }

            TextField {
              id: search

              Layout.fillWidth: true
              focus: true

              background: null
              padding: 0
              color: Theme.foreground
              font.family: Theme.fontSans
              font.pixelSize: Theme.sizeNormal

              placeholderText: Launcher.mode === "clipboard"
                ? "Search clipboard…"
                : "Search apps · maths · > to run a command"
              placeholderTextColor: Theme.muted

              onTextChanged: {
                Launcher.query = text;
                list.currentIndex = 0;
              }

              Keys.onUpPressed: list.decrementCurrentIndex()
              Keys.onDownPressed: list.incrementCurrentIndex()
              Keys.onTabPressed: list.incrementCurrentIndex()
              Keys.onReturnPressed: root.activateCurrent()
              Keys.onEnterPressed: root.activateCurrent()
              Keys.onEscapePressed: Launcher.close()

              // Left/Right navigate the list once the cursor is at the edge of the text
              Keys.onLeftPressed: event => {
                if (cursorPosition === 0)
                  list.decrementCurrentIndex();
                else
                  event.accepted = false;
              }

              Keys.onRightPressed: event => {
                if (cursorPosition === text.length)
                  list.incrementCurrentIndex();
                else
                  event.accepted = false;
              }

              // Shift+Delete removes the selected clipboard entry; plain Delete edits the text as usual
              Keys.onDeletePressed: event => {
                if (event.modifiers & Qt.ShiftModifier)
                  Launcher.results[list.currentIndex]?.remove?.();
                else
                  event.accepted = false;
              }
            }
          }
        }

        ListView {
          id: list

          Layout.fillWidth: true
          Layout.preferredHeight: Math.min(count, Theme.launcherVisibleItems) * Theme.launcherItemHeight
          visible: count > 0
          clip: true
          highlightMoveDuration: 0
          boundsBehavior: Flickable.StopAtBounds
          model: Launcher.results

          delegate: LauncherItem {
            required property var modelData
            required property int index

            item: modelData
            width: list.width
            height: Theme.launcherItemHeight
            selected: index === list.currentIndex

            onHovered: list.currentIndex = index
            onActivated: modelData.activate()
          }
        }

        StyledText {
          Layout.fillWidth: true
          Layout.topMargin: 4
          Layout.bottomMargin: 4
          visible: list.count === 0
          horizontalAlignment: Text.AlignHCenter
          text: "No results"
          color: Theme.muted
        }
      }
    }
  }
}
