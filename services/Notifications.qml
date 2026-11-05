pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    // Notifications currently shown as popups, newest first
    property var popups: []

    // Every notification still held (for a future notification centre)
    readonly property var all: server.trackedNotifications.values

    // Used when the app doesn't specify a timeout
    property int defaultTimeout: 5000

    function hidePopup(notification) {
        popups = popups.filter(item => item !== notification);
    }

    NotificationServer {
        id: server

        actionsSupported: true
        bodyMarkupSupported: true
        imageSupported: true

        onNotification: notification => {
            // Untracked notifications are discarded immediately
            notification.tracked = true;
            notification.closed.connect(() => root.hidePopup(notification));
            root.popups = [notification].concat(root.popups);
        }
    }
}
