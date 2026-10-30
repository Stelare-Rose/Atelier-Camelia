pragma Singleton

import QtQuick
import Quickshell

Singleton {
  id: root

  property bool dark: false

  function toggleMode() {
    dark = !dark;
  }

  readonly property QtObject _accents: QtObject {
    readonly property color strawberry: "#cf8282"
    readonly property color orange: "#d4a266"
    readonly property color lemon: "#e3cd7f"
    readonly property color leaf: "#9ccc96"
    readonly property color mint: "#99cfac"
    readonly property color sky: "#90cdde"
    readonly property color blueberry: "#9bb0de"
    readonly property color grape: "#9b98d6"
    readonly property color plum: "#aa99d1"
    readonly property color lavender: "#cca3d6"
    readonly property color lilac: "#dbb4d3"
    readonly property color pink: "#edb7ca"
  }

  readonly property QtObject _light: QtObject {
    readonly property color foam: "#f8f4e9"
    readonly property color cream: "#f0e8da"
    readonly property color base: "#e6d9c8"
    readonly property color tea: "#decec1"
    readonly property color subtext2: "#6b564b"
    readonly property color subtext1: "#4f453f"
    readonly property color text: "#403732"
    readonly property color highlight: "#383029"
  }

  readonly property QtObject _dark: QtObject {
    readonly property color foam: "#6b564b"
    readonly property color cream: "#4f453f"
    readonly property color base: "#403732"
    readonly property color tea: "#383029"
    readonly property color subtext2: "#decec1"
    readonly property color subtext1: "#e6d9c8"
    readonly property color text: "#f0e8da"
    readonly property color highlight: "#f8f4e9"
  }

  readonly property QtObject _neutrals: dark ? _dark : _light

  readonly property color foam: _neutrals.foam
  readonly property color cream: _neutrals.cream
  readonly property color base: _neutrals.base
  readonly property color tea: _neutrals.tea
  readonly property color subtext2: _neutrals.subtext2
  readonly property color subtext1: _neutrals.subtext1
  readonly property color text: _neutrals.text
  readonly property color highlight: _neutrals.highlight

  readonly property color strawberry: _accents.strawberry
  readonly property color orange: _accents.orange
  readonly property color lemon: _accents.lemon
  readonly property color leaf: _accents.leaf
  readonly property color mint: _accents.mint
  readonly property color sky: _accents.sky
  readonly property color blueberry: _accents.blueberry
  readonly property color grape: _accents.grape
  readonly property color plum: _accents.plum
  readonly property color lavender: _accents.lavender
  readonly property color lilac: _accents.lilac
  readonly property color pink: _accents.pink

  readonly property color background: cream
  readonly property color surface: foam
  readonly property color surfaceAlt: base
  readonly property color border: tea
  readonly property color foreground: text
  readonly property color muted: subtext2
  readonly property color accent: lavender
  readonly property color error: strawberry
  readonly property color warning: orange
  readonly property color success: leaf

  readonly property int barThickness: 36
  readonly property int barMargin: 4
  readonly property int barEndPadding: 14
  readonly property int barSidePadding: 6
  readonly property int barSpacing: 8
  readonly property int barRadius: 16
  readonly property int barSize: barThickness + barMargin * 2
  readonly property int triggerSize: 4

  readonly property int revealDuration: 200
  readonly property int hideDelay: 400

  readonly property string fontSans: "Nunito"
  readonly property string fontMono: "MonaspiceNe Nerd Font Propo"

  readonly property int sizeSmall: 12
  readonly property int sizeNormal: 14
  readonly property int sizeLarge: 16

  readonly property int workspaceSpacing: 6
  readonly property int workspacePadding: 3
  readonly property int workspaceRadius: 8
  readonly property int workspaceIconSize: 16
  readonly property int workspaceColumnPadding: 2
  readonly property int workspaceColumnSpacing: 2
  readonly property int workspaceColumnRadius: 5

  readonly property list<color> accents: [
    strawberry, orange, lemon, leaf, mint, sky,
    blueberry, grape, plum, lavender, lilac, pink
  ]

  function accentFor(key) {
    let hash = 0;
    for (let i = 0; i < key.length; i++)
    hash = (hash * 31 + key.charCodeAt(i)) | 0;
    return accents[Math.abs(hash) % accents.length];
    }
}

