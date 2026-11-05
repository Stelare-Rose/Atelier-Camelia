pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Remembers how often each app is launched, saved across restarts
Singleton {
  id: root

  // Ranking boost for an app: grows with use, but slowly, so text matches still matter most
  function bonus(id) {
    const count = adapter.counts[id] ?? 0;
    return Math.log2(1 + count) * 10;
  }

  function record(id) {
    const counts = Object.assign({}, adapter.counts);
    counts[id] = (counts[id] ?? 0) + 1;
    adapter.counts = counts;
  }

  FileView {
    path: Quickshell.statePath("app-usage.json")
    blockLoading: true

    // Save whenever the counts change
    onAdapterUpdated: writeAdapter()

    // First run: create the file
    onLoadFailed: error => {
      if (error === FileViewError.FileNotFound)
        writeAdapter();
    }

    adapter: JsonAdapter {
      id: adapter

      property var counts: ({})
    }
  }
}
