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

  function rate(bytesPerSecond) {
    const units = ["B/s", "KB/s", "MB/s", "GB/s"];
    let value = bytesPerSecond;
    let unit = 0;

    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }

    const digits = value < 10 && unit > 0 ? 1 : 0;
    return value.toFixed(digits) + " " + units[unit];
  }
}
