import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.15

import "qrc:/"

Item
{
    id: patchScreen

//    Rectangle
//    {
//        width: 22
//        anchors.right: patchScreen.right
//        anchors.top: patchScreen.top
//        anchors.bottom: patchScreen.bottom
//        color: "#444444"
//    }

    SideDockedWindow
    {
        id: deviceLib
        anchors.right: patchScreen.right
        anchors.top: patchScreen.top
        anchors.bottom: patchScreen.bottom

        caption: qsTr("Devices library")
        expandedWidth: 184
    }

    SideDockedWindow
    {
        id: deviceList
        anchors.rightMargin: 2
        anchors.right: deviceLib.left
        anchors.top: patchScreen.top
        anchors.bottom: patchScreen.bottom

        caption: qsTr("Devices list")
        expandedWidth: 348
    }

    Item
    {
        id: sceneWidget

        anchors.margins: 2
        anchors.left: patchScreen.left
        anchors.right: deviceList.left
        anchors.top: patchScreen.top
        anchors.bottom: patchScreen.bottom

        Rectangle
        {
            anchors.fill: parent
            color: "#000000"
        }

    }
}
