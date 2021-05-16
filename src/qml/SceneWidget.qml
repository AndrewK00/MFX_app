import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.15

import "qrc:/"

Item
{
    id: sceneWidget
    clip: true

    property alias backgroundImage: backgroundImage
    property var patchIcons: []
    property real scaleFactor: project.property("sceneScaleFactor")

    function loadPatches()
    {
        for(var i = 0; i < sceneWidget.patchIcons.length; i++)
        {
            sceneWidget.patchIcons[i].destroy()
        }

        sceneWidget.patchIcons = []

        for(i = 0; i < project.patchCount(); i++)
        {
            var deviceType = project.patchType(i)
            var imageFile
            if (deviceType === "Sequences")
                imageFile = "qrc:/device_sequences"
            else if (deviceType === "Pyro")
                imageFile = "qrc:/device_pyro"
            else if (deviceType === "Shot")
                imageFile = "qrc:/device_shot"
            else if (deviceType === "Dimmer")
                imageFile = "qrc:/device_dimmer"

            patchIcons.push(Qt.createComponent("PatchIcon.qml").createObject(sceneWidget,
                                                                             {  imageFile: imageFile,
                                                                                 patchId: project.patchPropertyForIndex(i, "ID"),
                                                                                 posXRatio: project.patchPropertyForIndex(i, "posXRatio"),
                                                                                 posYRatio: project.patchPropertyForIndex(i, "posYRatio")}))
        }
    }


    function zoom(step)
    {
        sceneWidget.scaleFactor += step
        project.setProperty("sceneScaleFactor", sceneWidget.scaleFactor)
    }

    function showPatchIcons(groupName, state)
    {
        for(let i = 0; i < patchIcons.length; i++)
        {
            if(project.isGroupContainsPatch(groupName, patchIcons[i].patchId))
            {
                patchIcons[i].visible = state
//                console.log("Patch " + patchIcons[i].patchId + "for group " + groupName + " set visible: " + patchIcons[i].visible);
            }
        }
    }

    function refreshPatchIconsVisibility(changedGroupName, state)
    {
        showPatchIcons(changedGroupName, state)
        for(let i = 0; i < switchGroupsButtons.count; i ++)
        {
            let currButton = switchGroupsButtons.itemAtIndex(i)
            if(currButton && currButton.text !== changedGroupName)
                showPatchIcons(currButton.text, currButton.checked)
        }
    }

    Image
    {
        id: backgroundImage
        width: sourceSize.width * sceneWidget.scaleFactor
        height: sourceSize.height * sceneWidget.scaleFactor
        source: project.property("backgroundImageFile") === "" ? "file:///" + applicationDirPath + "/default.png" : project.property("backgroundImageFile")
    }

    MouseArea
    {
        anchors.margins: 12
        anchors.fill: parent
        propagateComposedEvents: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        hoverEnabled: true

        property int pressedX
        property int pressedY
        property int currentBackgroundImageX
        property int currentBackgroundImageY
        property bool isDraggingMode: false

        onPressed:
        {
            if(mouse.button & Qt.MiddleButton)
            {
                isDraggingMode = true
                pressedX = mouseX
                pressedY = mouseY
                currentBackgroundImageX = backgroundImage.x
                currentBackgroundImageY = backgroundImage.y
            }
        }

        onReleased:
        {
            isDraggingMode = false
        }

        onPositionChanged:
        {
            if(isDraggingMode)
            {
                let dx = mouseX - pressedX
                let dy = mouseY - pressedY

                if(backgroundImage.width <= sceneWidget.width)
                    backgroundImage.x = 0
                else
                {
                    if(dx < 0)
                    {
                        if(!((backgroundImage.x + backgroundImage.width) <= sceneWidget.width))
                        {
                            backgroundImage.x = currentBackgroundImageX + dx
                        }
                    }

                    else if(dx > 0)
                    {
                        if(!(backgroundImage.x > 0))
                        {
                            backgroundImage.x = currentBackgroundImageX + dx
                        }
                    }
                }

                if(backgroundImage.height <= sceneWidget.height)
                    backgroundImage.y = 0

                else
                {
                    if(dy < 0)
                    {
                        if(!((backgroundImage.y + backgroundImage.height) <= sceneWidget.height))
                        {
                            backgroundImage.y = currentBackgroundImageY + dy
                        }
                    }

                    else if(dy > 0)
                    {
                        if(!(backgroundImage.y > 0))
                        {
                            backgroundImage.y = currentBackgroundImageY + dy
                        }
                    }
                }
            }
        }

        onWheel:
        {
            var step = wheel.angleDelta.y > 0 ? 0.05 : -0.05
            var prevWidth = backgroundImage.width
            var prevHeight = backgroundImage.height
            var newWidth = backgroundImage.sourceSize.width * (sceneWidget.scaleFactor + step)
            var newHeight = backgroundImage.sourceSize.height * (sceneWidget.scaleFactor + step)
            var currWidthChange = newWidth - prevWidth
            var currHeightChange = newHeight - prevHeight

            sceneWidget.scaleFactor += step
            project.setProperty("sceneScaleFactor", sceneWidget.scaleFactor)

            if(backgroundImage.width <= sceneWidget.width)
            {
                backgroundImage.x = 0
            }

            else
            {
                let dx = (mouseX - backgroundImage.x) / prevWidth * currWidthChange
                backgroundImage.x -= dx
            }

            if(backgroundImage.height <= sceneWidget.height)
            {
                backgroundImage.y = 0
            }

            else
            {
                let dy = (mouseY - backgroundImage.y) / prevHeight * currHeightChange
                backgroundImage.y -= dy
            }
        }
    }

    Item
    {
        id: sceneFrameItem
        x: project.property("sceneFrameX") * backgroundImage.width
        y: project.property("sceneFrameY") * backgroundImage.height
        width: 200
        height: 100
        visible: false

        function restorePreviousGeometry()
        {
            sceneFrameItem.x = project.property("sceneFrameX") * backgroundImage.width + backgroundImage.x
            sceneFrameItem.y = project.property("sceneFrameY") * backgroundImage.height + backgroundImage.y
            sceneFrameItem.width = project.property("sceneFrameWidth") / project.property("sceneImageWidth") * backgroundImage.width
            sceneFrameItem.height = project.property("sceneFrameHeight") / project.property("sceneFrameWidth") * width
        }

        Rectangle
        {
            id: sceneFrame
            anchors.fill: parent
            color: "transparent"
            border.width: 2
            border.color: "#507FE6"
            radius: 2

            property int minWidth: 100

            MouseArea
            {
                id: bottomResizeArea
                height: 4
                anchors
                {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }
                cursorShape: Qt.SizeVerCursor

                property int prevY

                onPressed:
                {
                    prevY = mouseY
                }

                onMouseYChanged:
                {
                    var dy = mouseY - prevY
                    sceneFrameItem.height += dy
                    sceneFrameItem.width = sceneFrameItem.width * (sceneFrameItem.height + dy) / sceneFrameItem.height
                }
            }

            MouseArea
            {
                id: rightResizeArea
                width: 4
                anchors
                {
                    bottom: parent.bottom
                    right: parent.right
                    top: parent.top
                }
                cursorShape: Qt.SizeHorCursor

                property int prevX

                onPressed:
                {
                    prevX = mouseX
                }

                onMouseYChanged:
                {
                    var dx = mouseX - prevX
                    sceneFrameItem.width += dx
                    sceneFrameItem.height = sceneFrameItem.height * (sceneFrameItem.width + dx) / sceneFrameItem.width
                }
            }
        }

        Rectangle
        {
            id: sceneTitle
            x: sceneFrame.x + sceneFrame.width / 2 - width / 2
            y: sceneFrame.y - height / 2
            width: 62
            height: 20
            color: "#507FE6"
            radius: 26

            Text
            {
                anchors.centerIn: parent
                text: qsTr("SCENE")
                color: "#ffffff"
                font.family: "Roboto"
                font.pixelSize: 12
            }

            MouseArea
            {
                id: mouseArea
                anchors.fill: parent
                preventStealing: true

                drag.target: sceneFrameItem
                drag.axis: Drag.XandYAxis

                drag.minimumX: backgroundImage.mapToItem(sceneWidget, 0, 0).x
                drag.maximumX: sceneWidget.width - sceneFrame.width
                drag.minimumY: sceneWidget.mapToItem(sceneWidget, 0, 0).y + 10
                drag.maximumY: sceneWidget.height - sceneFrame.height

                onReleased:
                {
                    project.setProperty("sceneFrameX", (sceneFrameItem.x / backgroundImage.width))
                    project.setProperty("sceneFrameY", (sceneFrameItem.y / backgroundImage.height))
                }
            }
        }

        Button
        {
            id: applyButton
            x: sceneFrame.x + sceneFrame.width - 50
            y: sceneFrame.y - height / 2
            width: 18
            height: 18

            background: Rectangle
            {
                color: "#27AE60"
                radius: 9
            }

            Image
            {
                anchors.centerIn: parent
                source: "qrc:/apply"
            }

            onClicked:
            {
                project.setProperty("sceneImageHeight", backgroundImage.height / sceneFrame.height * project.property("sceneFrameHeight"))
                project.setProperty("sceneImageWidth", backgroundImage.width / sceneFrame.width * project.property("sceneFrameWidth"))
                sceneFrameItem.visible = false
            }
        }

        Button
        {
            id: cancelButton
            x: sceneFrame.x + sceneFrame.width - 25
            y: sceneFrame.y - height / 2
            width: 18
            height: 18

            background: Rectangle
            {
                color: "#EB5757"
                radius: 9
            }

            Image
            {
                anchors.centerIn: parent
                source: "qrc:/cancel"
            }

            onClicked:
            {
                sceneFrameItem.visible = false
            }
        }

        Component.onCompleted:
        {
            restorePreviousGeometry()
        }
    }


    Button
    {
        id: sceneSettingsButton

        x: 8
        y: 8
        width: 112
        height: 24

        background: Rectangle
        {
            color: "#333333"
            radius: 2
        }

        Image
        {
            x: 6
            y: 6

            source: "qrc:/sceneSettings"
        }

        contentItem: Text
        {
            color: "#ffffff"
            text: "Scene settings"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            leftPadding: 16
            font.family: "Roboto"
            font.pixelSize: 12
        }

        onClicked:
        {
            var sceneSettingsWidget = Qt.createComponent("SceneSettingsWidget.qml").createObject(applicationWindow);
            sceneSettingsWidget.x = applicationWindow.width / 2 - sceneSettingsWidget.width / 2
            sceneSettingsWidget.y = applicationWindow.height / 2 - sceneSettingsWidget.height / 2
        }
    }

    Item
    {
        id: zoomControls
        width: 24
        height: 60

        anchors.leftMargin: 10
        anchors.left: parent.left

        anchors.bottomMargin: 58
        anchors.bottom: parent.bottom

        Rectangle
        {
            y: 20
            width: 24
            height: 30
            color: "#333333"
        }

        Button
        {
            id: zoomInButton

            width: 24
            height: 30

            bottomPadding: 0
            topPadding: 0
            rightPadding: 0
            leftPadding: 0

            text: "+"

            background: Rectangle
            {
                color: parent.pressed ? "#222222" : "#333333"
                radius: 20
            }

            contentItem: Text
            {
                color: parent.enabled ? "#ffffff" : "#777777"
                text: parent.text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font.family: "Roboto"
                font.pixelSize: 16
            }

            onClicked: sceneWidget.zoom(0.05)
        }

        Button
        {
            id: zoomOutButton

            y: 32
            width: 24
            height: 30

            bottomPadding: 0
            topPadding: 0
            rightPadding: 0
            leftPadding: 0

            text: "-"

            background: Rectangle
            {
                color: parent.pressed ? "#222222" : "#333333"
                radius: 20
            }
            contentItem: Text
            {
                color: parent.enabled ? "#ffffff" : "#777777"
                text: parent.text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font.family: "Roboto"
                font.pixelSize: 20
            }

            onClicked: sceneWidget.zoom(-0.05)
        }

        Rectangle
        {
            x: 2
            y: 30
            width: 20
            height: 2
            color: "#222222"
        }

        Button
        {
            id: fitButton

            y: 76
            width: 24
            height: 24

            bottomPadding: 0
            topPadding: 0
            rightPadding: 0
            leftPadding: 0

            text: "-"

            background: Rectangle
            {
                color: parent.pressed ? "#222222" : "#333333"
                radius: 24
            }

            Image
            {
                anchors.centerIn: parent
                source: "qrc:/fit"
            }

            onClicked:
            {

            }
        }

    }

    MfxButton
    {
        id: showAllButton
        width: 48
        checkable: true
        checked: true
        text: qsTr("All")
        anchors.leftMargin: 12
        anchors.bottomMargin: 18
        anchors
        {
            left: zoomControls.right
            bottom: sceneWidget.bottom
        }

        onCheckedChanged:
        {
            for(let i = 0; i < switchGroupsButtons.count; i++)
            {
                switchGroupsButtons.itemAtIndex(i).checked = checked
            }
        }
    }

    Rectangle
    {
        id: backgroundRect
        x: switchGroupsButtons.x
        y: switchGroupsButtons.y
        color: "#222222"
        height: 24
        width: switchGroupsButtons.contentItem.width
        radius: 2
        border.width: 2
        border.color: "#333333"
    }

    ListView
    {
        id: switchGroupsButtons
        orientation: ListView.Horizontal
        width: contentItem.width
        spacing: 2

        anchors.rightMargin: 4
        anchors.leftMargin: 2
        anchors.bottomMargin: 24
        anchors
        {
            left: showAllButton.right
            right: parent.right
            bottom: showAllButton.bottom
        }

        ScrollBar.horizontal: ScrollBar {}

        function refreshList()
        {
            buttonListModel.clear()
            let groupNames = project.groupNames()
            for (let i = 0; i < groupNames.length; i++)
            {
                buttonListModel.append({delegateChecked: showAllButton.checked, delegateWidth: 70, delegateText: groupNames[i]})
            }
        }

        delegate: MfxButton
        {
            checkable: true
            checked: delegateChecked
            width: delegateWidth
            text: delegateText

            onCheckedChanged:
            {
                sceneWidget.refreshPatchIconsVisibility(text, checked)
            }
        }

        model: ListModel
        {
            id: buttonListModel
        }

        Component.onCompleted: refreshList()
    }

    Connections
    {
        target: project
        function onPatchListChanged()
        {
            sceneWidget.loadPatches()
        }
    }

    Connections
    {
        target: project
        function onGroupCountChanged()
        {
            switchGroupsButtons.refreshList()
        }
    }

    Component.onCompleted:
    {
        loadPatches()
    }
}
