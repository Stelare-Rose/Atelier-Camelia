pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property bool open: false
  property string mode: "apps" // "apps" or "clipboard"
  property string query: ""

  // What the list shows. Every result has the same shape:
  //   { name, description, icon (icon name) or glyph (Nerd Font), activate(), remove()? }
  readonly property var results: mode === "clipboard" ? _clipboardResults : _appResults

  function show(newMode) {
    mode = newMode;
    query = "";
    open = true;

    if (newMode === "clipboard")
      cliphistList.running = true;
  }

  function close() {
    open = false;
  }

  function toggle(newMode) {
    if (open && mode === newMode)
      close();
    else
      show(newMode);
  }

  IpcHandler {
    target: "launcher"

    function toggle(): void {
      Launcher.toggle("apps");
    }

    function toggleClipboard(): void {
      Launcher.toggle("clipboard");
    }

    function close(): void {
      Launcher.close();
    }
  }
  function launch(entry) {
    AppUsage.record(entry.id);
    entry.execute();
    close();
  }

  function run(command) {
    Quickshell.execDetached(["sh", "-c", command]);
    close();
  }

  function copy(text) {
    Quickshell.execDetached(["wl-copy", "--", text]);
    close();
  }

  // ─ Apps mode ─

  readonly property var _apps: DesktopEntries.applications.values.filter(entry => !entry.noDisplay)

  readonly property var _appResults: {
    const text = query.trim();
    const items = [];

    // "> command" runs a shell command
    if (text.startsWith(">")) {
      const command = text.slice(1).trim();
      if (command) {
        items.push({
          name: command,
          description: "Run command",
          glyph: "\u{F018D}", // nf-md-console
          activate: () => run(command)
        });
      }
      return items;
    }

    // Calculator answer first, so Enter copies it
    if (_calcInput === text && _calcResult !== "") {
      const answer = _calcResult;
      items.push({
        name: answer,
        description: "Result · Enter to copy",
        glyph: "\u{F00EC}", // nf-md-calculator
        activate: () => copy(answer)
      });
    }

    // Open windows next, so you can jump to one instead of launching a new copy
    for (const window of _matchingWindows(text)) {
      items.push({
        name: window.title || window.app_id,
        description: "Switch to · " + _appNameFor(window.app_id),
        icon: window.app_id,
        activate: () => {
          Niri.focusWindow(window);
          close();
        }
      });
    }

    // Then apps, ranked by how well they match plus how often they're used
    const scored = [];
    for (const entry of _apps) {
      const score = _score(entry, text);
      if (score > 0)
        scored.push({ entry: entry, score: score + AppUsage.bonus(entry.id) });
    }

    scored.sort((a, b) => b.score - a.score || a.entry.name.localeCompare(b.entry.name));

    for (const result of scored.slice(0, 50)) {
      const entry = result.entry;
      items.push({
        name: entry.name,
        description: entry.comment || entry.genericName || "",
        icon: entry.icon,
        activate: () => launch(entry)
      });
    }

    return items;
  }

  // How well an app matches the query; 0 means no match
  function _score(entry, text) {
    if (!text)
      return 1; // empty search: everything, ordered by usage

    const search = text.toLowerCase();
    const name = entry.name.toLowerCase();

    if (name.startsWith(search))
      return 100;
    if (name.includes(search))
      return 80;

    const extra = [entry.genericName ?? "", ...(entry.keywords ?? [])].join(" ").toLowerCase();
    if (extra.includes(search))
      return 50;

    if (_isSubsequence(search, name))
      return 20; // "ffx" matches "firefox"

    return 0;
  }

  function _isSubsequence(needle, haystack) {
    let position = 0;
    for (const character of haystack) {
      if (character === needle[position])
        position++;
      if (position === needle.length)
        return true;
    }
    return false;
  }

  // Open windows whose title or app matches the query (all of them for an empty query)
  function _matchingWindows(text) {
    const search = text.toLowerCase();

    return Niri.windows.filter(window => {
      if (!search)
        return true;
      const title = (window.title ?? "").toLowerCase();
      const app = (window.app_id ?? "").toLowerCase();
      return title.includes(search) || app.includes(search);
    });
  }

  // A friendly app name for a window, e.g. "org.mozilla.firefox" → "Firefox"
  function _appNameFor(appId) {
    return DesktopEntries.heuristicLookup(appId)?.name ?? appId ?? "";
  }

  // ─ Calculator (qalc) ─
  //
  // qalc handles units ("5 km to mi"), currencies ("100 USD to EUR"),
  // bitwise operators ("0b1010 xor 0b0110"), functions, constants and more.
  // It runs as a separate process, so results arrive a moment after typing.

  // The input the current result belongs to, and the result itself
  property string _calcInput: ""
  property string _calcResult: ""

  // Set when the query changes while qalc is still busy
  property bool _calcDirty: false

  onQueryChanged: {
    if (mode === "apps")
      calcDelay.restart();
  }

  // Wait for a pause in typing before calculating
  Timer {
    id: calcDelay
    interval: 120
    onTriggered: root._startCalc()
  }

  function _startCalc() {
    const text = query.trim();

    // Only things with a number in them are worth asking qalc about;
    // commands are never maths
    if (!/\d/.test(text) || text.startsWith(">")) {
      _calcInput = text;
      _calcResult = "";
      return;
    }

    if (qalc.running) {
      _calcDirty = true;
      return;
    }

    qalc.command = ["qalc", "-t", text];
    qalc.running = true;
  }

  Process {
    id: qalc

    property string input: command[2] ?? ""

    stdout: StdioCollector {
      onStreamFinished: {
        const output = text.trim();

        // Ignore errors, and answers that just repeat the input (i.e. it wasn't maths)
        const useful = output !== ""
          && !/error|warning/i.test(output)
          && output !== qalc.input;

        root._calcInput = qalc.input;
        root._calcResult = useful ? output : "";
      }
    }

    onExited: {
      if (root._calcDirty) {
        root._calcDirty = false;
        root._startCalc();
      }
    }
  }

  // ─ Clipboard mode ─

  property var _clipboardLines: []

  Process {
    id: cliphistList
    command: ["cliphist", "list"]
    stdout: StdioCollector {
      onStreamFinished: root._clipboardLines = text.split("\n").filter(line => line)
    }
  }

  readonly property var _clipboardResults: {
    const search = query.trim().toLowerCase();

    return _clipboardLines
      .filter(line => !search || line.toLowerCase().includes(search))
      .slice(0, 100)
      .map(line => ({
        // cliphist lines are "<id>\t<preview>"
        name: line.slice(line.indexOf("\t") + 1),
        description: "",
        glyph: "\u{F0192}", // nf-md-content_paste
        activate: () => _copyClip(line),
        remove: () => _deleteClip(line)
      }));
  }

  // cliphist decode/delete take the full list line on stdin
  function _copyClip(line) {
    Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | cliphist decode | wl-copy", "sh", line]);
    close();
  }

  function _deleteClip(line) {
    Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | cliphist delete", "sh", line]);
    _clipboardLines = _clipboardLines.filter(item => item !== line);
  }
}
