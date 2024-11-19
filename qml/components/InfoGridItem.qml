/*
    Space Inspector - a filesystem structure visualization for SailfishOS
    SPDX-FileCopyrightText: 2024 Mirian Margiani
    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick 2.2
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1

Item {
    id: root

    property GridLayout grid
    property string label
    property string value
    property bool busy: false

    // note: GridLayout items are added upside down,
    // from bottom to top.

    Label {
        id: valueLabel
        parent: grid
        leftPadding: root.busy ? spinner.width + Theme.paddingMedium : 0
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
        text: value
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeMedium
        wrapMode: Text.Wrap

        BusyIndicator {
            id: spinner
            anchors {
                left: parent.left
                bottom: parent.baseline
            }
            visible: root.busy
            size: BusyIndicatorSize.ExtraSmall
            running: visible
        }
    }

    Label {
        id: labelLabel
        parent: grid
        Layout.fillWidth: false
        Layout.alignment: Qt.AlignRight
        anchors.baseline: valueLabel.baseline
        text: label
        color: Theme.secondaryHighlightColor
        font.pixelSize: Theme.fontSizeSmall
        horizontalAlignment: Text.AlignRight
    }
}
