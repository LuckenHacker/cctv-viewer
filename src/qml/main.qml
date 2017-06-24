import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import Qt.labs.settings 1.0
import '../js/script.js' as CCTV_Viewer

ApplicationWindow {
    id: rootWindow

    visible: true
    visibility: rootWindow.fullScreen ? Window.FullScreen : Window.Windowed
    width: rootWindowSettings.width
    height: rootWindowSettings.height
    title: qsTr('CCTV Viewer')

    property bool fullScreen: false

//    Settings {
//        id: generalSettings
//    }

    Settings {
        id: rootWindowSettings

        category: 'RootWindow'
        property int width: 960
        property int height: 540
        property alias fullScreen: rootWindow.fullScreen
    }

    Binding {
        target: rootWindowSettings
        property: 'width'
        value: rootWindow.width
        when: !rootWindow.fullScreen
    }

    Binding {
        target: rootWindowSettings
        property: 'height'
        value: rootWindow.height
        when: !rootWindow.fullScreen
    }

    // DEPRECATED: Transitional code. Must be removed in version 0.1.2
    Settings {
        id: viewportsLayoutSettings

        category: 'ViewportsLayout'

        property int division: 3
        property string aspectRatio: '16:9'
        property string model: ''
    }

    ViewportsLayoutsCollection {
        id: viewportsLayoutsCollection

        onDataChanged: {
            if (currentLayout instanceof Object) {
                var jsModel = currentLayout.model;

                if (currentLayout.division === undefined) {
                    currentLayout.division = viewportsLayout.division;
                }

                if (currentLayout.aspectRatio === undefined) {
                    currentLayout.aspectRatio = viewportsLayout.aspectRatio;
                }

                viewportsLayout.division = currentLayout.division;
                viewportsLayout.aspectRatio = currentLayout.aspectRatio;

                if (jsModel !== undefined) {
                    viewportsLayout.model.setJsModel(jsModel);
                } else {
                    viewportsLayout.model.clear();
                }

            } else {
                viewportsLayout.model.clear();
            }
        }

        Component.onCompleted: {
            // DEPRECATED: Transitional code. Must be removed in version 0.1.2
            if(!String(viewportsLayoutSettings.model).isEmpty()) {
                var jsModel = JSON.parse(viewportsLayoutSettings.model);

                if (!(currentLayout.model instanceof Array)) {
                    set(currentIndex, {
                            division: viewportsLayoutSettings.division,
                            aspectRatio: viewportsLayoutSettings.aspectRatio,
                            model: jsModel
                        });
                }
            }

            viewportsLayout.divisionChanged.connect(function() { viewportsLayoutsCollection.currentLayout.division = viewportsLayout.division; sync(); });
            viewportsLayout.aspectRatioChanged.connect(function() { viewportsLayoutsCollection.currentLayout.aspectRatio = viewportsLayout.aspectRatio; sync(); });
            viewportsLayout.model.changed.connect(function() { viewportsLayoutsCollection.currentLayout.model = viewportsLayout.model.jsModel(); sync(); });
        }
    }

    Shortcut {
        sequence: StandardKey.FullScreen
        onActivated: rootWindow.fullScreen = !rootWindow.fullScreen
    }
    Shortcut {
        sequence: StandardKey.Quit
        onActivated: Qt.quit()
    }

    Item {
        anchors.fill: parent

        // Right-to-left User Interfaces support
        // (NOTE: This is supported by the ApplicationWindow starting from Qt 5.8)
        LayoutMirroring.enabled: CCTV_Viewer.ifRightToLeft(true)
        LayoutMirroring.childrenInherit: CCTV_Viewer.ifRightToLeft(true)

        ViewportsLayout {
            id: viewportsLayout

            focus: true
            division: 3
            anchors.fill: parent
        }

        SideMenu {
            id: submenu

            height: parent.height
            anchors.right: parent.right
        }
    }
}
