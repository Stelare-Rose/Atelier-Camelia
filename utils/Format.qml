pragma Singleton

import Quickshell

Singleton {
  function gigabytes(bytes) {
    const value = bytes / 1024 ** 3;
    return value >= 100 ? value.toFixed(0) : value.toFixed(1);
  }

  function usage(used, total) {
    return gigabytes(used) + "/" + gigabytes(total) + " GB";
  }

  function percent(ratio) {
    return Math.round(ratio * 100) + "%";
  }
}
