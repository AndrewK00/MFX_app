import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import MFX.UI.Components.Templates 1.0 as MFXUICT
import MFX.UI.Styles 1.0 as MFXUIS

Item {
    id: preferences

    anchors.fill: parent

    signal canBeDestroyed()

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4

        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 2

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                radius: 2
                color: "#222222"

                ListView {
                    id: menuListView

                    anchors.fill: parent
                    anchors.topMargin: 6
                    anchors.bottomMargin: 6

                    currentIndex: 0

                    interactive: height < contentHeight

                    contentHeight: childrenRect.height

                    clip: true

                    model: [
                        qsTr("Com Port DMX"),
                        qsTr("Ethernet"),
                        qsTr("Language"),
                        qsTr("Profile Cloud"),
                        qsTr("MIDI connection")
                    ]

                    delegate: Item {
                        id: menuListViewDelegate

                        anchors.left: parent.left
                        anchors.right: parent.right

                        property bool isCurrentItem:  index === menuListView.currentIndex

                        height: 20

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8

                            spacing: 0

                            Text {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter

                                lineHeightMode: Text.FixedHeight
                                lineHeight: 12

                                font.family: MFXUIS.Fonts.robotoRegular.name
                                font.pixelSize: 10

                                elide: Text.ElideRight

                                color: menuListViewDelegate.isCurrentItem ? "#FFFFFF" : "#80FFFFFF"

                                text: modelData
                            }

                            MFXUICT.LayoutSpacer {}

                            MFXUICT.ColoredIcon {
                                Layout.preferredHeight: 8
                                Layout.maximumHeight: 8
                                Layout.minimumHeight: 8
                                Layout.alignment: Qt.AlignVCenter

                                color: "#FFFFFF"

                                visible: menuListViewDelegate.isCurrentItem

                                source: "qrc:/icons/preferences/preferences_list_selected_row_indicator_icon.svg"
                            }
                        }

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                menuListView.currentIndex = index
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                radius: 2
                color: "#222222"

                Item {
                    anchors.fill: parent

                    visible: menuListView.currentIndex === 0

                    Flickable {
                        anchors.fill: parent
                        anchors.leftMargin: 5
                        anchors.rightMargin: 5
                        anchors.topMargin: 10
                        anchors.bottomMargin: 10

                        interactive: height < contentHeight
                        clip: true
                        contentHeight: comPortPageLayout.height

                        ColumnLayout {
                            id: comPortPageLayout

                            anchors.left: parent.left
                            anchors.right: parent.right

                            height: childrenRect.height

                            spacing: 0

                            Text {
                                Layout.fillWidth: true
                                Layout.preferredHeight: implicitHeight
                                Layout.maximumHeight: implicitHeight
                                Layout.minimumHeight: implicitHeight

                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter

                                font.family: MFXUIS.Fonts.robotoRegular.name
                                font.pixelSize: 10

                                color: "#FFFFFF"

                                text: qsTr("COM port")
                            }

                            MFXUICT.LayoutSpacer {
                                fixedHeight: 4
                            }

                            MFXUICT.ComboBox {
                                Layout.fillWidth: true
                                Layout.preferredHeight: implicitHeight
                                Layout.maximumHeight: implicitHeight
                                Layout.minimumHeight: implicitHeight

                                currentIndex: 0

                                model: ListModel {
                                    ListElement { text: "COM1"; value: 1 }
                                    ListElement { text: "COM2"; value: 2 }
                                    ListElement { text: "COM3"; value: 2 }
                                    ListElement { text: "COM4"; value: 2 }
                                    ListElement { text: "COM5"; value: 2 }
                                    ListElement { text: "COM6"; value: 2 }
                                    ListElement { text: "COM7"; value: 2 }
                                    ListElement { text: "COM8"; value: 2 }
                                    ListElement { text: "COM9"; value: 2 }
                                    ListElement { text: "COM10"; value: 2 }
                                    ListElement { text: "COM11"; value: 2 }
                                }
                            }
                        }
                    }
                }

                Item {
                    anchors.fill: parent

                    visible: menuListView.currentIndex === 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 5
                        anchors.rightMargin: 5
                        anchors.topMargin: 10
                        anchors.bottomMargin: 10

                        spacing: 0

                        Text {
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight
                            Layout.maximumHeight: implicitHeight
                            Layout.minimumHeight: implicitHeight

                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter

                            font.family: MFXUIS.Fonts.robotoRegular.name
                            font.pixelSize: 10

                            color: "#FFFFFF"

                            text: qsTr("IP address")
                        }

                        MFXUICT.LayoutSpacer {
                            fixedHeight: 4
                        }

                        MFXUICT.TextField {
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight
                            Layout.maximumHeight: implicitHeight
                            Layout.minimumHeight: implicitHeight

                            text: "1.1.1.1"
                        }

                        MFXUICT.LayoutSpacer {
                            fixedHeight: 8
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight
                            Layout.maximumHeight: implicitHeight
                            Layout.minimumHeight: implicitHeight

                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter

                            font.family: MFXUIS.Fonts.robotoRegular.name
                            font.pixelSize: 10

                            color: "#FFFFFF"

                            text: qsTr("Subnet mask")
                        }

                        MFXUICT.LayoutSpacer {
                            fixedHeight: 4
                        }

                        MFXUICT.TextField {
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight
                            Layout.maximumHeight: implicitHeight
                            Layout.minimumHeight: implicitHeight

                            text: "255.255.255.0"
                        }

                        MFXUICT.LayoutSpacer {
                            fixedHeight: 8
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight
                            Layout.maximumHeight: implicitHeight
                            Layout.minimumHeight: implicitHeight

                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter

                            font.family: MFXUIS.Fonts.robotoRegular.name
                            font.pixelSize: 10

                            color: "#FFFFFF"

                            text: qsTr("Gateway")
                        }

                        MFXUICT.LayoutSpacer {
                            fixedHeight: 4
                        }

                        MFXUICT.TextField {
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight
                            Layout.maximumHeight: implicitHeight
                            Layout.minimumHeight: implicitHeight

                            text: "192.168.1.1"
                        }

                        MFXUICT.LayoutSpacer { }

                        Text {
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight
                            Layout.maximumHeight: implicitHeight
                            Layout.minimumHeight: implicitHeight

                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter

                            font.family: MFXUIS.Fonts.robotoRegular.name
                            font.pixelSize: 10

                            color: "#FFFFFF"

                            text: qsTr("Universe")
                        }

                        MFXUICT.LayoutSpacer {
                            fixedHeight: 4
                        }

                        MFXUICT.TextField {
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight
                            Layout.maximumHeight: implicitHeight
                            Layout.minimumHeight: implicitHeight

                            text: "1"
                        }
                    }
                }

                Item {
                    anchors.fill: parent

                    visible: menuListView.currentIndex === 2

                    ListView {
                        id: languagesListView

                        anchors.fill: parent
                        anchors.leftMargin: 5
                        anchors.rightMargin: 5
                        anchors.topMargin: 10
                        anchors.bottomMargin: 10

                        currentIndex: 0

                        interactive: height < contentHeight
                        clip: true
                        contentHeight: comPortPageLayout.height

                        spacing: 2

                        model: ListModel {
                            ListElement { text: qsTr("English"); icon: "qrc:/icons/preferences/preferences_language_settings_english_flag_icon.svg" }
                            ListElement { text: qsTr("Русский"); icon: "qrc:/icons/preferences/preferences_language_settings_russian_flag_icon.svg" }
                        }

                        delegate: Item {
                            id: languagesListViewDelegate

                            anchors.left: parent.left
                            anchors.right: parent.right

                            height: 20

                            property bool isCurrentItem: index === languagesListView.currentIndex

                            RowLayout {
                                anchors.fill: parent

                                spacing: 0

                                MFXUICT.ColoredIcon {
                                    Layout.preferredHeight: 12
                                    Layout.maximumHeight: 12
                                    Layout.minimumHeight: 12
                                    Layout.preferredWidth: 12
                                    Layout.maximumWidth: 12
                                    Layout.minimumWidth: 12

                                    source: model.icon

                                    opacity: languagesListViewDelegate.isCurrentItem ? 1.0 : 0.5
                                }

                                MFXUICT.LayoutSpacer {
                                    fixedWidth: 5
                                }

                                Text {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    horizontalAlignment: Text.AlignLeft
                                    verticalAlignment: Text.AlignVCenter

                                    font.family: MFXUIS.Fonts.robotoRegular.name
                                    font.pixelSize: 10

                                    color: "#FFFFFF"

                                    text: model.text

                                    opacity: languagesListViewDelegate.isCurrentItem ? 1.0 : 0.5
                                }

                                Item {
                                    Layout.preferredHeight: 12
                                    Layout.maximumHeight: 12
                                    Layout.minimumHeight: 12
                                    Layout.preferredWidth: 12
                                    Layout.maximumWidth: 12
                                    Layout.minimumWidth: 12
                                    Layout.alignment: Qt.AlignVCenter

                                    Rectangle {
                                        anchors.fill: parent

                                        visible: !languagesListViewDelegate.isCurrentItem

                                        color: "#111111"

                                        radius: 2
                                    }

                                    Rectangle {
                                        anchors.fill: parent

                                        visible: languagesListViewDelegate.isCurrentItem

                                        color: "#2F80ED"

                                        radius: 2

                                        MFXUICT.ColoredIcon {
                                            anchors.top: parent.top
                                            anchors.topMargin: 3
                                            anchors.horizontalCenter: parent.horizontalCenter

                                            width: 6

                                            color: "#FFFFFF"

                                            source: "qrc:/icons/components/checkbox_indicator_icon.svg"
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    languagesListView.currentIndex = index
                                }
                            }
                        }
                    }
                }

                Item {
                    id: cloudLoginPage

                    anchors.fill: parent

                    visible: menuListView.currentIndex === 3

                    property bool errorState: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 5
                        anchors.rightMargin: 5
                        anchors.topMargin: 10
                        anchors.bottomMargin: 10

                        spacing: 0

                        MFXUICT.LayoutSpacer {
                            fixedHeight: 6
                        }

                        MFXUICT.ColoredIcon {
                            Layout.preferredWidth: 38
                            Layout.maximumWidth: 38
                            Layout.minimumWidth: 38
                            Layout.preferredHeight: 38
                            Layout.maximumHeight: 38
                            Layout.minimumHeight: 38
                            Layout.alignment: Qt.AlignHCenter

                            source: "qrc:/icons/preferences/preferences_cloud_login_icon.svg"
                        }

                        MFXUICT.LayoutSpacer {
                            fixedHeight: 6
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight
                            Layout.maximumHeight: implicitHeight
                            Layout.minimumHeight: implicitHeight

                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter

                            font.family: MFXUIS.Fonts.robotoRegular.name
                            font.pixelSize: 10

                            color: "#FFFFFF"

                            text: qsTr("Enter your account")
                        }

                        MFXUICT.LayoutSpacer {
                            fixedHeight: 8
                        }

                        MFXUICT.TextField {
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight
                            Layout.maximumHeight: implicitHeight
                            Layout.minimumHeight: implicitHeight

                            text: ""
                            placeholderText: qsTr("Email or Login")
                        }

                        MFXUICT.LayoutSpacer {
                            fixedHeight: 4
                        }

                        MFXUICT.TextField {
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight
                            Layout.maximumHeight: implicitHeight
                            Layout.minimumHeight: implicitHeight

                            text: ""
                            placeholderText: qsTr("Password")
                        }

                        MFXUICT.LayoutSpacer {
                            fixedHeight: 8
                        }

                        CheckBox {
                            id: saveAccountCheckbox

                            Layout.fillWidth: true
                            Layout.preferredHeight: 10
                            Layout.maximumHeight: 10
                            Layout.minimumHeight: 10

                            leftPadding: 0
                            leftInset: 0

                            indicator: Rectangle {
                                implicitHeight: 10
                                implicitWidth: 10

                                x: 0
                                y: (parent.height - height) / 2

                                radius: 2

                                color: saveAccountCheckbox.checked ? "#2F80ED" : "#111111"

                                MFXUICT.ColoredIcon {
                                    anchors.top: parent.top
                                    anchors.topMargin: 3
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    width: 6

                                    visible: saveAccountCheckbox.checked

                                    color: "#FFFFFF"

                                    source: "qrc:/icons/components/checkbox_indicator_icon.svg"
                                }
                            }

                            contentItem: Text {
                                anchors.left: saveAccountCheckbox.indicator.right
                                anchors.leftMargin: 6

                                height: implicitHeight
                                width: saveAccountCheckbox.width - 6

                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter

                                font.family: MFXUIS.Fonts.robotoRegular.name
                                font.pixelSize: 10

                                color: "#FFFFFF"

                                text: saveAccountCheckbox.text
                            }

                            text: qsTr("Save account")
                        }

                        MFXUICT.LayoutSpacer { }

                        Text {
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight
                            Layout.maximumHeight: implicitHeight
                            Layout.minimumHeight: implicitHeight

                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter

                            font.family: MFXUIS.Fonts.robotoRegular.name
                            font.pixelSize: 8

                            wrapMode: Text.WordWrap

                            color: "#EB5757"

                            text: qsTr("Error. Wrong login or password")

                            visible: cloudLoginPage.errorState
                        }

                        MFXUICT.LayoutSpacer { }

                        MfxButton {

                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                            Layout.maximumHeight: 20
                            Layout.minimumHeight: 20

                            checkable: false

                            fontFamilyName: MFXUIS.Fonts.robotoMedium.name
                            textSize: 8
                            color: "#2F80ED"
                            pressedColor: "#649ce8"

                            text: qsTr("Login")
                        }

                        MFXUICT.LayoutSpacer {
                            fixedHeight: 4
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 16
                            Layout.maximumHeight: 16
                            Layout.minimumHeight: 16

                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter

                            font.family: MFXUIS.Fonts.robotoRegular.name
                            font.pixelSize: 8

                            color: "#2F80ED"

                            text: qsTr("Forgot password")
                        }

                    }

                }

                Item {
                    anchors.fill: parent

                    visible: menuListView.currentIndex === 4

                    Flickable {
                        anchors.fill: parent
                        anchors.leftMargin: 5
                        anchors.rightMargin: 5
                        anchors.topMargin: 10
                        anchors.bottomMargin: 10

                        interactive: height < contentHeight
                        clip: true
                        contentHeight: midiConnectionPageLayout.height

                        ColumnLayout {
                            id: midiConnectionPageLayout

                            anchors.left: parent.left
                            anchors.right: parent.right

                            height: childrenRect.height

                            spacing: 0

                            Text {
                                Layout.fillWidth: true
                                Layout.preferredHeight: implicitHeight
                                Layout.maximumHeight: implicitHeight
                                Layout.minimumHeight: implicitHeight

                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter

                                font.family: MFXUIS.Fonts.robotoRegular.name
                                font.pixelSize: 10

                                color: "#FFFFFF"

                                text: qsTr("Device name")
                            }

                            MFXUICT.LayoutSpacer {
                                fixedHeight: 4
                            }

                            MFXUICT.ComboBox {
                                Layout.fillWidth: true
                                Layout.preferredHeight: implicitHeight
                                Layout.maximumHeight: implicitHeight
                                Layout.minimumHeight: implicitHeight

                                currentIndex: 0

                                model: ListModel {
                                    ListElement { text: "COM1"; value: 1 }
                                    ListElement { text: "COM2"; value: 2 }
                                    ListElement { text: "COM3"; value: 2 }
                                    ListElement { text: "COM4"; value: 2 }
                                    ListElement { text: "COM5"; value: 2 }
                                    ListElement { text: "COM6"; value: 2 }
                                    ListElement { text: "COM7"; value: 2 }
                                    ListElement { text: "COM8"; value: 2 }
                                    ListElement { text: "COM9"; value: 2 }
                                    ListElement { text: "COM10"; value: 2 }
                                    ListElement { text: "COM11"; value: 2 }
                                }
                            }

                            MFXUICT.LayoutSpacer {
                                fixedHeight: 8
                            }

                            Text {
                                Layout.fillWidth: true
                                Layout.preferredHeight: implicitHeight
                                Layout.maximumHeight: implicitHeight
                                Layout.minimumHeight: implicitHeight

                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter

                                font.family: MFXUIS.Fonts.robotoRegular.name
                                font.pixelSize: 10

                                color: "#FFFFFF"

                                text: qsTr("Device input")
                            }

                            MFXUICT.LayoutSpacer {
                                fixedHeight: 4
                            }

                            MFXUICT.ComboBox {
                                Layout.fillWidth: true
                                Layout.preferredHeight: implicitHeight
                                Layout.maximumHeight: implicitHeight
                                Layout.minimumHeight: implicitHeight

                                currentIndex: 0

                                model: ListModel {
                                    ListElement { text: "COM1"; value: 1 }
                                    ListElement { text: "COM2"; value: 2 }
                                    ListElement { text: "COM3"; value: 2 }
                                    ListElement { text: "COM4"; value: 2 }
                                    ListElement { text: "COM5"; value: 2 }
                                    ListElement { text: "COM6"; value: 2 }
                                    ListElement { text: "COM7"; value: 2 }
                                    ListElement { text: "COM8"; value: 2 }
                                    ListElement { text: "COM9"; value: 2 }
                                    ListElement { text: "COM10"; value: 2 }
                                    ListElement { text: "COM11"; value: 2 }
                                }
                            }
                        }
                    }
                }

            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            Layout.maximumHeight: 48
            Layout.minimumHeight: 48

            MfxButton {
                id: applyButton

                anchors.centerIn: parent
                width: 140
                height: 24

                checkable: false

                fontFamilyName: MFXUIS.Fonts.robotoRegular.name
                textSize: 8
                color: "#2F80ED"
                pressedColor: "#649ce8"

                text: qsTr("Apply")

                onClicked: {
                }
            }
        }
    }
}