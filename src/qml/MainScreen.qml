import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.15

import "qrc:/"

Item
{
    id: mainScreen

    property var sceneWidget: null

    function setupSceneWidget(widget)
    {
        sceneWidget = widget

        if(!sceneWidget)
            return

        sceneWidget.parent = this
        sceneWidget.anchors.margins = 2
        sceneWidget.anchors.left = mainScreen.left
        sceneWidget.anchors.right = mainScreen.right
        sceneWidget.anchors.top = mainScreen.top
        sceneWidget.anchors.bottom = mainScreen.bottom
    }
}
