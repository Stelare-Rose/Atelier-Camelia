import QtQuick
import Quickshell.Services.UPower
import qs.config
import qs.utils

StatItem {
  id: root

  readonly property var device: UPower.displayDevice
  readonly property real level: device.percentage
  readonly property bool charging: device.state === UPowerDeviceState.Charging

  readonly property list<string> levelIcons: [
    "\u{F008E}", "\u{F007A}", "\u{F007B}", "\u{F007C}", "\u{F007D}", "\u{F007E}",
    "\u{F007F}", "\u{F0080}", "\u{F0081}", "\u{F0082}", "\u{F0079}"
  ]

  visible: device.isLaptopBattery
  icon: charging ? "\u{F0084}" : levelIcons[Math.round(level * 10)] // nf-md-battery_charging
  label: Format.percent(level)

  textColor: {
    if (charging)
    return Theme.success;
    if (level <= 0.15)
    return Theme.error;
    return Theme.foreground;
  }
}
