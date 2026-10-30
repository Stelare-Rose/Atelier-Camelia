import QtQuick
import qs.config
import qs.services
import qs.utils

Row {
  spacing: Theme.barSpacing

  StatItem {
    icon: "\uf4bc"
    label: Format.percent(SystemStats.cpu)
    textColor: Theme.accent
  }

  StatItem {
    visible: SystemStats.gpuAvailable
    icon: "\udb82\udcae"
    label: Format.percent(SystemStats.gpu)
    textColor: Theme.accent
  }

  StatItem {
    icon: "\uefc5"
    label: Format.usage(SystemStats.memoryUsed, SystemStats.memoryTotal)
    textColor: Theme.accent
  }

  StatItem {
    icon: "\udb80\udeca"
    label: Format.usage(SystemStats.diskUsed, SystemStats.diskTotal)
    textColor: Theme.accent
  }
}
