/*
 * This file is part of harbour-space-inspector.
 * SPDX-FileCopyrightText: 2020-2024 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import Sailfish.Silica 1.0 as S
import Opal.About 1.0 as A

A.AboutPageBase {
    id: page

    appName: main.appName
    appIcon: 'qrc:/img/harbour-space-inspector.png'
    appVersion: main.appVersion
    appRelease: ""

    // sourcesUrl: "https://github.com/a-dekker/space-inspector"
    // homepageUrl: "https://forum.sailfishos.org/t/..."
    // translationsUrl: "https://hosted.weblate.org/projects/%1".arg(Qt.application.name)
    // changelogList: Qt.resolvedUrl("../Changelog.qml")
    licenses: A.License { spdxId: "GPL-3.0-or-later" }

    _donationsInfoSection.title: qsTr("Do you like this app?")
    donations.text: qsTr("Buy me a beer :)")
    donations.services: [
        A.DonationService {
            name: "Paypal"
            url: "https://www.paypal.me/jklingen/3"
        }
    ]

    description: qsTr("No matter how much storage you have got - it will be full.") +
                 "<br><br>" +
                 qsTr("Space Inspector helps to find large folders and files on your storage.")
    mainAttributions: [
        "2014-2018 Jens Klingen",
        "2020-2026 Arno Dekker",
        "2024-2026 Mirian Margiani"
    ]
    autoAddOpalAttributions: true

    extraSections: [
        A.InfoSection {
            title: qsTr("Questions, problems, suggestions?")

            buttons: [
                A.InfoButton {
                    text: "Github"
                    onClicked: openOrCopyUrl("https://github.com/a-dekker/space-inspector")
                },
                A.InfoButton {
                    text: "Twitter"
                    onClicked: openOrCopyUrl("https://twitter.com/jklingen")
                }
            ]
        }
    ]

    attributions: [
        A.Attribution {
            name: "File Browser core"
            entries: ["2019-2026 Mirian Margiani", "2013-2019 karip"]
            licenses: A.License { spdxId: "GPL-3.0-or-later" }
            sources: "https://github.com/ichthyosaurus/harbour-file-browser"
        },
        A.Attribution {
            name: "Treemap Squared"
            entries: ["2012 Imran Ghory"]
            licenses: A.License { spdxId: "MIT" }
            sources: "https://github.com/imranghory/treemap-squared"
        }
    ]

    contributionSections: [
        A.ContributionSection {
            title: qsTr("Development")
            groups: [
                A.ContributionGroup {
                    title: qsTr("Programming")
                    entries: [
                        "Jens Klingen", "Arno Dekker",
                        "Mirian Margiani", "Kari Pihkala"
                    ]
                },
                A.ContributionGroup {
                    title: qsTr("Icon Design")
                    entries: ["Jens Klingen"]
                }
            ]
        },
        A.ContributionSection {
            title: qsTr("Translations")
            groups: [
                A.ContributionGroup {
                    title: qsTr("Swedish")
                    entries: [
                        "Åke Engelbrektson"
                    ]
                },
                A.ContributionGroup {
                    title: qsTr("Spanish")
                    entries: [
                        "Carlos Gonzalez"
                    ]
                },
                A.ContributionGroup {
                    title: qsTr("German")
                    entries: [
                        "Jens Klingen",
                        "Arno Dekker",
                        "Mirian Margiani"
                    ]
                },
                A.ContributionGroup {
                    title: qsTr("English")
                    entries: [
                        "Jens Klingen",
                        "Mirian Margiani"
                    ]
                },
                A.ContributionGroup {
                    title: qsTr("Chinese")
                    entries: [
                        "dashinfantry"
                    ]
                }
            ]
        }
    ]
}
