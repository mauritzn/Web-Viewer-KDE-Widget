import QtQuick 2.0
import QtWebEngine 1.5
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    id: widget
    Layout.fillWidth: true
    Layout.fillHeight: true

    // Main widget panel
    Plasmoid.fullRepresentation: Item {
        id: popupView
        Layout.preferredWidth: plasmoid.configuration.width * PlasmaCore.Units.devicePixelRatio
        Layout.preferredHeight: plasmoid.configuration.height * PlasmaCore.Units.devicePixelRatio
        Plasmoid.hideOnWindowDeactivate: false

        // Link contextmenu (shows if right-clicking a link)
        PlasmaComponents.Menu {
            id: linkContextMenu
            visualParent: webview

            property string link

            PlasmaComponents.MenuItem {
                text: "Open Link in Browser"
                icon: "internet-web-browser"
                onClicked: Qt.openUrlExternally(linkContextMenu.link)
            }

            PlasmaComponents.MenuItem {
                text: "Copy Link Address"
                icon: "edit-copy"
                onClicked: webview.triggerWebAction(WebEngineView.CopyLinkToClipboard)
            }
        }

        // Default contextmenu (doesn't show if right-clicking selected text)
        PlasmaComponents.Menu {
            id: defaultContextMenu
            visualParent: webview

            property string link

            PlasmaComponents.MenuItem {
                text: "Reload current page"
                icon: "view-refresh"
                onClicked: {
                    webview.reload();
                }
            }

            PlasmaComponents.MenuItem {
                text: "Reset view"
                icon: "view-refresh"
                onClicked: {
                    webview.url = plasmoid.configuration.url;
                }
            }
        }

        // Auto refresh the current page or the set url at the set interval
        Timer {
            id: autoRefreshTimer
            interval: plasmoid.configuration.autoRefreshInterval * 1000
            repeat: true
            onTriggered: {
                if(plasmoid.configuration.autoRefresh === 1) {
                    webview.url = plasmoid.configuration.url;
                } else {
                    webview.reload();
                }
            }
        }

        WebEngineView {
            id: webview
            anchors.fill: parent
            Component.onCompleted: url = plasmoid.configuration.url;

            onLoadingChanged: {
                // webpage has loaded
                if (loadRequest.status === WebEngineLoadRequest.LoadSucceededStatus) {
                    // mute/unmute audio
                    if(plasmoid.configuration.audioMuted === true) {
                        webview.audioMuted = true;
                    } else {
                        webview.audioMuted = false;
                    }

                    if(plasmoid.configuration.autoRefresh > 0) {
                        autoRefreshTimer.interval = plasmoid.configuration.autoRefreshInterval * 1000
                        autoRefreshTimer.start();
                    } else {
                        autoRefreshTimer.stop();
                    }

                    // Disable scrollbar
                    // (not perfect, since some websites implement scrolling on other elements and don't use the html/body for scrolling (like YouTube))
                    if(plasmoid.configuration.disableScrolling === true) {
                        /* webview.runJavaScript("var newStyleElement = document.createElement('style');\
                                            newStyleElement.type = 'text/css';\
                                            newStyleElement.appendChild(document.createTextNode(`html, body { overflow: hidden !important; }`));\
                                            document.head.appendChild(newStyleElement);"); */

                        webview.runJavaScript("var __htmlEl = document.querySelector('html');\
                                            var __bodyEl = document.querySelector('body');\
                                            if(__htmlEl && __bodyEl) {\
                                                __htmlEl.style.overflow = 'hidden';\
                                                __bodyEl.style.overflow = 'hidden';\
                                            }");
                    }
                }
            }

            // Handles "PlasmaComponents.Menu"
            onContextMenuRequested: {
                if (request.mediaType === ContextMenuRequest.MediaTypeNone && request.linkUrl.toString() !== "") {
                    linkContextMenu.link = request.linkUrl;
                    linkContextMenu.open(request.x, request.y);
                    request.accepted = true;
                } else if(request.selectedText.toString() === "") {
                    defaultContextMenu.open(request.x, request.y);
                    request.accepted = true;
                }
            }
        }
    }

    // Removes border around widget (there is an option to add it back under: Rotate | Configure ... | Show Background)
    Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground | PlasmaCore.Types.ConfigurableBackground
}
