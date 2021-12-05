import QtQuick 2.0
import QtWebEngine 1.5
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    Layout.fillWidth: true
    Layout.fillHeight: true

    Layout.preferredWidth: 640
    Layout.preferredHeight: 360

    // removes border around widget (there is an option to add it back under: Rotate | Configure ... | Show Background)
    Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground | PlasmaCore.Types.ConfigurableBackground

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

    // auto refresh the current page or the set url at the set interval
    Timer {
        id: autoRefreshTimer
        interval: 1000
        repeat: true
        onTriggered: {
            if(plasmoid.configuration.autoRefresh === 1) {
                //console.log("test timer #refresh");
                webview.url = plasmoid.configuration.url;
            } else {
                //console.log("test timer #reload");
                webview.reload();
            }
        }
    }

    WebEngineView {
        id: webview
        anchors.fill: parent
        Component.onCompleted: url = plasmoid.configuration.url;

        onLoadingChanged: {
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

                // disable scrollbar
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

        // INFO: handles "PlasmaComponents.Menu"
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
