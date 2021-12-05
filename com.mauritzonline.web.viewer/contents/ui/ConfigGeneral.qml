import QtQuick 2.5
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.5 as Kirigami


Kirigami.FormLayout {
    id: page
    Layout.fillWidth: true
    wideMode: false

    property alias cfg_url: url.text
    property alias cfg_autoRefresh: autoRefresh.currentIndex
    property alias cfg_autoRefreshInterval: autoRefreshInterval.value
    property alias cfg_audioMuted: audioMuted.checked
    property alias cfg_disableScrolling: disableScrolling.checked

    Kirigami.InlineMessage {
        id: inlineMessage
        Layout.fillWidth: true
        visible: true
        text: "After settings are changed you need to reset the view for it to get loaded. Right click an empty area in the webview and press: Reset View"
    }

    TextField {
        id: url
        Layout.fillWidth: true
        Kirigami.FormData.label: "URL to load"
        placeholderText: "Enter desired URL"
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "Auto refresh options"
    }

    ComboBox {
        id: autoRefresh
        model: [
            "Don't auto refresh",
            "Auto refresh to set URL",
            "Auto refresh current page"
        ]
        onCurrentIndexChanged: cfg_autoRefresh = currentIndex
    }

    SpinBox {
        id: autoRefreshInterval
        Kirigami.FormData.label: "Auto refresh interval (seconds) [min: 1, max: 86400]"
        editable: true
        from: 1 // 1 second
        to: 86400 // 1 day
        value: 10 // 10 seconds (default)
        stepSize: 1
        onValueModified: cfg_autoRefreshInterval = value
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "Other options"
    }

    CheckBox {
        id: audioMuted
        checkable: true
        Kirigami.FormData.label: "Audio muted"
    }

    CheckBox {
        id: disableScrolling
        checkable: true
        Kirigami.FormData.label: "Disable scrolling"
    }
}
