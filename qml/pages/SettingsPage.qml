/*
    Space Inspector - a filesystem structure visualization for SailfishOS
    SPDX-FileCopyrightText: 2024 Mirian Margiani
    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick 2.6
import Sailfish.Silica 1.0
import Opal.ComboData 1.0
import Nemo.Configuration 1.0
import Harbour.SpaceInspector.Constants 1.0

Page {
    id: root
    allowedOrientations: Orientation.All

    ConfigurationGroup {
        id: config
        path: "/apps/harbour-space-inspector"
        property int defaultView: ViewMode.Box
    }

    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: column.height + Theme.horizontalPageMargin

        VerticalScrollDecorator { flickable: flick }

        Column {
            id: column
            width: parent.width

            // This avoid stuttering when opening the combo box
            height: Math.max(root.height - Theme.horizontalPageMargin,
                             childrenRect.height)

            PageHeader {
                title: qsTr("Settings")
            }

            ComboBox {
                label: qsTr("Default view")

                property ComboData cdata
                ComboData { dataRole: "value" }
                onValueChanged: config.defaultView = cdata.currentData
                Component.onCompleted: cdata.reset(config.defaultView)

                menu: ContextMenu {
                    MenuItem {
                        property int value: ViewMode.Box
                        text: qsTr("Box view")
                    }
                    MenuItem {
                        property int value: ViewMode.List
                        text: qsTr("List view")
                    }
                }
            }
        }
    }
}
