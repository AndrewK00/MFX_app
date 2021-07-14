import QtQuick 2.12
import QtQuick.Controls 2.12

import WaveformWidget 1.0
import "qrc:/"

Item
{
    id: playerWidget
    clip: true

    property int minHeight: 200
    property int maxHeight: 600
    property int min
    property int max

    property int position: startPositionMarker.position
    property alias waitingText: waitingText

    onMinChanged:
    {
        startPositionMarker.updateVisiblePosition()
        stopPositionMarker.updateVisiblePosition()
        startLoopMarker.updateVisiblePosition()
        stopLoopMarker.updateVisiblePosition()
        positionCursor.updateVisiblePosition()
    }

    onMaxChanged:
    {
        startPositionMarker.updateVisiblePosition()
        stopPositionMarker.updateVisiblePosition()
        startLoopMarker.updateVisiblePosition()
        stopLoopMarker.updateVisiblePosition()
        positionCursor.updateVisiblePosition()
    }

    onPositionChanged:
    {
        positionCursor.position = position
    }

    function hidePlayerElements()
    {
        timeScale.visible = false
        waveformWidget.visible = false
        startPositionMarker.visible = false
        startLoopMarker.visible = false
        stopPositionMarker.visible = false
        stopLoopMarker.visible = false
        positionCursor.visible = false
//        cueViewFlickable.visible = false

        waitingText.visible = true

        for (let txt of timeScale.textMarkers)
        {
          txt.destroy()
        }
        timeScale.textMarkers = []

        timer.text = "00:00:00.00"
    }

    function showPlayerElements()
    {
        timeScale.visible = true
        waveformWidget.visible = true
        startPositionMarker.visible = true
        startLoopMarker.visible = true
        stopPositionMarker.visible = true
        stopLoopMarker.visible = true
        positionCursor.visible = true
//        cueViewFlickable.visible = true
    }


    function projectDuration()
    {
        return project.property("prePlayInterval") + waveformWidget.duration() + project.property("postPlayInterval")
    }

    function msecToPixels(value)
    {
        return playerWidget.width * value / (playerWidget.max - playerWidget.min)
    }

    function pixelsToMsec(pixels)
    {
        return Math.round(Math.round(pixels * (playerWidget.max - playerWidget.min) / playerWidget.width) / 10) * 10
    }

    function zoom(delta)
    {
        let scaleFactor = 0.05

        if(Math.abs(delta) < 5)
            scaleFactor = 0.08
        else if(Math.abs(delta) < 9)
            scaleFactor = 0.1
        else if(Math.abs(delta) < 14)
            scaleFactor = 0.15
        else
            scaleFactor = 0.20

        let currInterval = playerWidget.max - playerWidget.min
        let dWidth = currInterval * scaleFactor
        let zoomCenter = resizingCenterMarker.x / width
        let leftShift = zoomCenter * dWidth
        let rightShift = dWidth - leftShift

        if(delta > 0)
        {
            if((waveformWidget.maxSample() - waveformWidget.minSample()) / waveformWidget.width > 4) // максимальный масштаб - 4 сэмпла на пиксель
            {
                playerWidget.min += Math.round(leftShift)
                playerWidget.max -= Math.round(rightShift)
            }
        }

        else
        {
            if((playerWidget.min - leftShift) >= 0 && (playerWidget.max + rightShift) <= playerWidget.projectDuration())
            {
                playerWidget.min -= Math.round(leftShift)
                playerWidget.max += Math.round(rightShift)
            }

            else
            {
                let leftDist = playerWidget.min
                let rightDist = playerWidget.projectDuration() - playerWidget.max

                if(leftDist < rightDist)
                {
                    dWidth -= leftDist
                    playerWidget.min = 0

                    if((playerWidget.max + dWidth) < playerWidget.projectDuration())
                    {
                        playerWidget.max += dWidth
                    }

                    else
                        playerWidget.max = playerWidget.projectDuration()
                }

                else
                {
                    dWidth -= rightDist
                    playerWidget.max = playerWidget.projectDuration()

                    if((playerWidget.min - dWidth) >= 0)
                    {
                        playerWidget.min -= dWidth
                    }

                    else
                        playerWidget.min = 0
                }
            }
        }
    }

    function move(dx, dy)
    {
        if(Math.abs(dx) > Math.abs(dy)) // Скроллим
        {
            let coeff = 1
            if(Math.abs(dx) < 3)
                coeff = 1
            else if (Math.abs(dx) < 7)
                coeff = 2
            else if (Math.abs(dx) < 16)
                coeff = 3
            else
                coeff = 4

            let currInterval = playerWidget.max - playerWidget.min
            let dX = currInterval / playerWidget.width * Math.abs(dx) * coeff

            if(dx < 0)
            {
                if(playerWidget.max + dX <= playerWidget.projectDuration())
                {
                    playerWidget.max += dX
                    playerWidget.min += dX

                    if(resizingCenterMarker.x - Math.abs(dx) * coeff > 0)
                    {
                        resizingCenterMarker.x -= Math.abs(dx) * coeff
                    }

                    else
                    {
                        resizingCenterMarker.x = 1
                    }
                }
            }

            else
            {
                if(playerWidget.min - dX >= 0)
                {
                    playerWidget.max -= dX
                    playerWidget.min -= dX

                    if(resizingCenterMarker.x + Math.abs(dx) * coeff < width - 9)
                    {
                        resizingCenterMarker.x += Math.abs(dx) * coeff
                    }

                    else
                    {
                        resizingCenterMarker.x = width - 12
                    }
                }
            }
        }

        else // Работаем с зумом
        {
            playerWidget.zoom(dy)
        }
    }

    Timer
    {
        id: playerTimer
        interval: 10
        repeat: true

        onTriggered:
        {
            if(playerWidget.position + interval < project.property("prePlayInterval"))
            {
                playerWidget.position += interval
            }

            else if (playerWidget.position + interval > project.property("prePlayInterval") + waveformWidget.duration())
            {
                if(playerWidget.position + interval < stopPositionMarker.position)
                {
                    playerWidget.position += interval
                }
                else
                {
                    playerWidget.position = stopPositionMarker.position
                    playerTimer.stop()
                    playButton.checked = false
                }
            }

            else
            {
                playerTimer.stop()
                waveformWidget.setPlayerPosition(playerWidget.position - project.property("prePlayInterval"))
                waveformWidget.play()
            }
        }
    }

    Rectangle
    {
        id: mainBackground
        anchors.fill: parent
        color: "#444444"
        radius: 2
    }

    Rectangle
    {
        id: timeScaleBackground
        height: 8
        anchors.topMargin: waveformBackground.anchors.topMargin - height
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        color: "#222222"
    }

    Rectangle
    {
        id: waveformBackground
        anchors.topMargin: 24
        anchors.bottomMargin: 24
        anchors.fill: parent
        color: "#000000"
    }

    MfxMouseArea
    {
        id: playerResizeArea
        height: 4

        property int previousY

        anchors.topMargin: -2
        anchors
        {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        cursor: Qt.SizeVerCursor

        onPressed:
        {
            previousY = mouseY
        }

        onMouseYChanged:
        {
            var dy = mouseY - previousY

            if((playerWidget.height - dy) < playerWidget.minHeight)
                playerWidget.height = playerWidget.minHeight

            else if ((playerWidget.height - dy) <= mainScreen.height - 100)
                playerWidget.height = playerWidget.height - dy
        }
    }

    Item
    {
        id: timeScale
        anchors.fill: timeScaleBackground

        property alias timeScaleMouseArea: timeScaleMouseArea
        property var textMarkers: []

        Component
        {
            id: textMarker
            Text
            {
                id: posTimeText
                color: "#eeeeee"
                padding: 0
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font.family: "Roboto"
                font.pixelSize: 8
            }
        }

        Canvas
        {
            id: timeScaleCanvas
            anchors.fill: parent

            onPaint:
            {
                // Вычисляем кол-во миллисекунд на пиксель

                let max = playerWidget.max
                let min = playerWidget.min
                let msecPerPx = (max - min) / playerWidget.width

                for (let txt of timeScale.textMarkers)
                {
                  txt.destroy()
                }
                timeScale.textMarkers = []
                var ctx = getContext("2d")
                ctx.reset()

                var stepMsec = 0 // шаг делений в мсек

 // малое деление будет равно 1 сек
                if(msecPerPx >= 50)
                {
                    stepMsec = 1000
                }

// малое деление будет равно 0.5 сек
                else if(msecPerPx >= 25)
                {
                    stepMsec = 500
                }

// малое деление будет равно 0.1 сек
                else if (msecPerPx >= 3)
                {
                    stepMsec = 100
                }

// малое деление будет равно 0.01 сек
                else
                {
                    stepMsec = 10
                }

                // стартовая позиция в мсек
                var startMsec = Math.ceil(min / stepMsec) * stepMsec

                // стартовая позиция в пикселях
                var start = (startMsec - min) / msecPerPx

                // шаг делений в пикселях
                var step = stepMsec / msecPerPx

                ctx.miterLimit = 0.1
                ctx.strokeStyle = "#888888"

                var currPos = start;
                var currPosMsec = startMsec
                while(currPos + step < width)
                {
                    let divisionHeight = 2

                    if(!(currPosMsec % (10 * stepMsec)))
                        divisionHeight = 6

                    else if(!(currPosMsec % (5 * stepMsec)))
                        divisionHeight = 4

                    ctx.moveTo(currPos, height)
                    ctx.lineTo(currPos, height - divisionHeight)
                    currPos += step
                    currPosMsec += stepMsec

                    if(divisionHeight === 6) // создаем текстовый маркер
                    {
                        let marker = textMarker.createObject(mainBackground)
                        timeScale.textMarkers.push(marker)

                        if(msecPerPx >= 3)
                        {
                            marker.text = waveformWidget.positionString(currPosMsec - stepMsec, "mm:ss")
                        }

                        else
                        {
                            let timeString = waveformWidget.positionString(currPosMsec - stepMsec, "mm:ss.zzz")
                            marker.text = timeString.slice(0, timeString.length - 2)
                        }
                        marker.y = 2
                        marker.x = currPos - step - marker.width / 2
                    }
                }

                ctx.stroke()
            }
        }


        Connections
        {
            target: playerWidget
            function onMaxChanged()
            {
                timeScaleCanvas.requestPaint()
            }
        }

        Connections
        {
            target: playerWidget
            function onMinChanged()
            {
                timeScaleCanvas.requestPaint()
            }
        }

        ZoomingMouseArea
        {
            id: timeScaleMouseArea
            height: 22
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            hoverEnabled: true
            image: ""

            property alias resizingCenterMarker: resizingCenterMarker

            property int pressedX
            property int pressedY

            Rectangle
            {
                id: resizingCenterMarker
                color: "#27AE60"
                width: 1
                anchors.top: parent.bottom
                height: waveformWidget.height
                visible: false
            }

            onEntered:
            {
                if(!isPressed)
                    cursorImageForTimeScale.visible = true

                cursorImageForTimeScale.x = mouseX
                cursorImageForTimeScale.y = mouseY
            }

            onExited:
            {
                cursorImageForTimeScale.visible = false
            }

            onPressed:
            {
                cursorManager.saveLastPos()
                pressedX = mouseX
                pressedY = mouseY
                playerResizeArea.enabled = false
                playerResizeArea.cursorShape = Qt.BlankCursor
                mainScreen.sceneWidget.enabled = false
                cursorImageForTimeScale.visible = false
                resizingCenterMarker.x = mouseX
                resizingCenterMarker.visible = true
            }

            onPositionChanged:
            {
                cursorImageForTimeScale.x = mouseX
                cursorImageForTimeScale.y = mouseY
            }

            onMoved:
            {
                playerWidget.move(dx, dy)
            }

            onWheel:
            {
                resizingCenterMarker.x = mouseX
                playerWidget.zoom(wheel.angleDelta.y > 0 ? 2 : -2)
            }

            onReleased:
            {
                playerResizeArea.enabled = true
                playerResizeArea.cursorShape = Qt.SizeVerCursor
                mainScreen.sceneWidget.enabled = true
                resizingCenterMarker.visible = false
                cursorImageForTimeScale.visible = true

                cursorManager.moveToLastPos()
                cursorManager.moveCursor(resizingCenterMarker.x - pressedX, 0)
            }
        }
    }

    WaveformWidget
    {
        id: waveformWidget
        anchors.topMargin: 24
        anchors.bottomMargin: 24
        anchors.fill: parent

        anchors.leftMargin: playerWidget.min >= project.property("prePlayInterval") ?
                                0 :
                                msecToPixels(project.property("prePlayInterval") - playerWidget.min)

        anchors.rightMargin: playerWidget.max <= project.property("prePlayInterval") + waveformWidget.duration() ?
                                 0 :
                                 msecToPixels(playerWidget.max - (project.property("prePlayInterval") + waveformWidget.duration()))

        function adjust()
        {
            if(playerWidget.min >= project.property("prePlayInterval"))
            {
                waveformWidget.setMin(playerWidget.min - project.property("prePlayInterval"))
            }

            else
            {
                waveformWidget.setMin(0)
            }

            if(playerWidget.max <= project.property("prePlayInterval") + waveformWidget.duration())
            {
                waveformWidget.setMax(playerWidget.max - project.property("prePlayInterval"))
            }

            else
            {
                waveformWidget.setMax(waveformWidget.duration())
            }
        }

        Connections
        {
            target: project
            function onAudioTrackFileChanged()
            {
//                playButton.checked = false
                waveformWidget.setAudioTrackFile(settingsManager.workDirectory() + "/" + project.property("audioTrackFile"))
            }
        }

        Connections
        {
            target: playerWidget
            function onMinChanged()
            {
               waveformWidget.adjust()
            }
        }

        Connections
        {
            target: playerWidget
            function onMaxChanged()
            {
               waveformWidget.adjust()
            }
        }
    }

    Rectangle
    {
        id: leftShadingRect
        anchors.top: waveformWidget.top
        anchors.bottom: waveformWidget.bottom
        anchors.left: waveformWidget.left
        anchors.right: startPositionMarker.left
        color: "black"
        opacity: 0.5
    }

    Rectangle
    {
        id: rightShadingRect
        anchors.top: waveformWidget.top
        anchors.bottom: waveformWidget.bottom
        anchors.right: waveformWidget.right
        anchors.left: repeatButton.checked ? stopLoopMarker.right : stopPositionMarker.right
        color: "black"
        opacity: 0.5
    }

    Flickable
    {
        id: cueViewFlickable
        anchors.fill: waveformBackground
        contentHeight: cueView.height
        clip: true

        Item
        {
            id: cueView
            width: waveformWidget.width
            property int rowMargin: 2
            property int collapsedHeight: 10
            property int expandedHeight: 36

            property var cuePlates: []

            function updateHeight()
            {
                let maxY = 0
                let isExpanded = false
                cuePlates.forEach(function(currCuePlate)
                {
                    if(currCuePlate.y >= maxY)
                    {
                        maxY = currCuePlate.y
                        isExpanded = isExpanded ? isExpanded : currCuePlate.isExpanded
                    }
                })

                cueView.height = maxY + cueView.rowMargin + (isExpanded ? cueView.expandedHeight : cueView.collapsedHeight)
            }

            function loadCues()
            {
                for(var i = 0; i < cuePlates.length; i++)
                {
                    cuePlates[i].destroy()
                }

                cuePlates = []

                let cuesList = project.getCues()

                cuesList.forEach(function(currCue)
                {
                    cuePlates.push(cuePlateComponent.createObject(cueView,
                                                         {
                                                             name: currCue["name"],
                                                             yPosition: currCue["yPosition"],
                                                             position: currCue["position"],
                                                             duration: currCue["duration"]
                                                         }
                                                         ))
                })

                updateHeight()
            }

            function expandCuePlate(name)
            {
                let hasExpanded = false
                let expandedY = 0

                cuePlates.forEach(function(currCuePlate)
                {
                    if(currCuePlate.name === name)
                    {
                        currCuePlate.isExpanded = !currCuePlate.isExpanded
                        if(currCuePlate.isExpanded)
                        {
                            hasExpanded = true
                            expandedY = currCuePlate.y
                            return
                        }
                    }

                    else
                    {
                        currCuePlate.checked = false
                        currCuePlate.isExpanded = false
                    }
                })

                cuePlates.forEach(function(currCuePlate)
                {
                    currCuePlate.checked = false
                    if(hasExpanded)
                    {
                        if(currCuePlate.y > expandedY)
                            currCuePlate.isAfterExpanded = true
                    }

                    else
                    {
                        currCuePlate.isAfterExpanded = false
                    }
                })

                updateHeight()
            }
        }

        ScrollBar.vertical: ScrollBar
        {
            id: cueViewScrollBar
            policy: cueView.height > waveformBackground.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

            contentItem:
                Rectangle
                {
                    implicitWidth: 10
                    radius: 2
                    color: "#c4c4c4"
                    opacity: parent.pressed ? 0.25 : 0.5
                }
        }

        Component
        {
            id: cuePlateComponent
            Item
            {
                id: cuePlate
                x: msecToPixels(position - playerWidget.min)
                y: isAfterExpanded ? yPosition + cueView.expandedHeight - cueView.collapsedHeight : yPosition
                width: msecToPixels(duration)
                height: isExpanded ? cueView.expandedHeight : cueView.collapsedHeight

                property string name: ""
                property bool isExpanded: false
                property bool checked: false
                property bool isAfterExpanded: false
                property int yPosition
                property int position // в мсек
                property int duration  // в мсек
                property int tempRow
                property int tempPosition

                states:
                    [
                    State
                    {
                        name: "intersected"
                        PropertyChanges
                        {
                            target: frame
                            color: "#3FEB5757"
                        }

                        PropertyChanges
                        {
                            target: frame.border
                            color: "#EB5757"
                        }
                    }
                ]

                Rectangle
                {
                    id: frame
                    anchors.fill: parent

                    radius: 4
                    color: "#7F27AE60"
                    border.width: 2
                    border.color: parent.checked ? "#2F80ED" : "#27AE60"

                }

                Text
                {
                    id: caption
                    color: "#ffffff"
                    text: parent.name
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideMiddle
                    anchors.centerIn: parent
                    font.family: "Roboto"
                    font.pixelSize: 8
                    visible: parent.width > 0
                }

                MfxMouseArea
                {
                    id: cuePlateMouseArea
                    anchors.fill: parent

                    onClicked:
                    {
                        cuePlate.checked = !cuePlate.checked
                    }

                    onDoubleClicked:
                    {
                        cueView.expandCuePlate(cuePlate.name)
                        cuePlate.checked = true
                    }
                }
            }
        }
    }

    Rectangle
    {
        id: leftChannelMarker
        width: 10
        height: 10
        radius: 2
        color: "#444444"
        x: waveformBackground.x + 4
        y: waveformBackground.y + 4
        visible: stereoModeButton.checked

        Text
        {
            text: "L"
            color: "#ffffff"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            anchors.centerIn: parent
            font.family: "Roboto"
            font.pixelSize: 8
        }
    }

    Rectangle
    {
        id: rightChannelMarker
        width: 10
        height: 10
        radius: 2
        color: "#444444"
        x: waveformBackground.x + 4
        y: waveformBackground.y + waveformBackground.height / 2 + 4
        visible: stereoModeButton.checked

        Text
        {
            text: "R"
            color: "#ffffff"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            anchors.centerIn: parent
            font.family: "Roboto"
            font.pixelSize: 8
        }
    }

    Rectangle
    {
        id: cnannelsSeparetor
        width: waveformBackground.width
        height: 2
        y: waveformBackground.y + waveformBackground.height / 2
        color: "#444444"
        visible: stereoModeButton.checked
    }

    Item
    {
        id: startPositionMarker
        width: 2
        height: mainBackground.height + 12
        anchors.top: mainBackground.top

        property int position: 0

        function updateVisiblePosition()
        {
            x = msecToPixels(position - playerWidget.min)
        }

        Canvas
        {
            width: 12
            height: parent.height
            x: -1
            y: 12

            onPaint:
            {
                var ctx = getContext("2d")
                ctx.miterLimit = 0.1
                ctx.fillStyle = "#ffffff"
                ctx.lineTo(0, 12)
                ctx.lineTo(width / 2, 6)
                ctx.lineTo(0, 0)
                ctx.closePath()
                ctx.fill()
            }

            MfxMouseArea
            {
                id: startPositionMarkerMovingArea
                anchors.topMargin: -4
                anchors.top: parent.top
                anchors.leftMargin: -6
                anchors.left: parent.left
                anchors.right: parent.right
                height: 12
                hoverEnabled: true

                drag.target: startPositionMarker
                drag.axis: Drag.XAxis
                drag.minimumX: 0
                drag.maximumX: (stopLoopMarker.position < stopPositionMarker.position ? stopLoopMarker : stopPositionMarker).position < playerWidget.max ?
                                   (stopLoopMarker.position < stopPositionMarker.position ? stopLoopMarker : stopPositionMarker).x : playerWidget.width

                drag.threshold: 0
                drag.smoothed: false

                cursorShape: Qt.SizeHorCursor
                onPressed: timeScaleMouseArea.visible = false
                onReleased: timeScaleMouseArea.visible = true
            }
        }

        Rectangle
        {
            width: 1
            height: waveformBackground.height
            color: "#ffffff"
            x: -1
            y: 24
        }

        onXChanged:
        {
            position = playerWidget.min + pixelsToMsec(x)
        }

        onPositionChanged:
        {
            updateVisiblePosition()
            project.setProperty("startPosition", startPositionMarker.position)

            if(startLoopMarker.position < startPositionMarker.position)
            {
                startLoopMarker.position = startPositionMarker.position
            }
        }
    }

    Item
    {
        id: stopPositionMarker
        width: 2
        height: mainBackground.height + 12
        anchors.top: mainBackground.top

        property int position: 0

        function updateVisiblePosition()
        {
            x = msecToPixels(position - playerWidget.min)
        }

        Canvas
        {
            width: 12
            height: parent.height
            x: -6
            y: 12

            onPaint:
            {
                var ctx = getContext("2d")
                ctx.miterLimit = 0.1
                ctx.fillStyle = "#ffffff"
                ctx.moveTo(0, 6)
                ctx.lineTo(width / 2, 12)
                ctx.lineTo(width / 2, 0)
                ctx.lineTo(0, 6)
                ctx.closePath()
                ctx.fill()
            }

            MfxMouseArea
            {
                id: stopPositionMarkerMovingArea
                anchors.topMargin: -4
                anchors.top: parent.top
                anchors.leftMargin: -4
                anchors.left: parent.left
                anchors.right: parent.right
                height: 12
                hoverEnabled: true

                drag.target: stopPositionMarker
                drag.axis: Drag.XAxis
                drag.minimumX: (startLoopMarker.position > startPositionMarker.position ? startLoopMarker : startPositionMarker).position > playerWidget.min ?
                                   (startLoopMarker.position > startPositionMarker.position ? startLoopMarker : startPositionMarker).x : 0
                drag.maximumX: playerWidget.width

                drag.threshold: 0
                drag.smoothed: false

                cursorShape: Qt.SizeHorCursor
                onPressed: timeScaleMouseArea.visible = false
                onReleased: timeScaleMouseArea.visible = true
            }
        }

        Rectangle
        {
            width: 1
            height: waveformBackground.height
            color: "#ffffff"
            x: -1
            y: 24
        }

        onXChanged:
        {
            position = playerWidget.min + pixelsToMsec(x)
        }

        onPositionChanged:
        {
            updateVisiblePosition()
            project.setProperty("stopPosition", stopPositionMarker.position)

            if(stopLoopMarker.position > stopPositionMarker.position)
            {
                stopLoopMarker.position = stopPositionMarker.position
            }
        }
    }

    Item
    {
        id: startLoopMarker
        width: 2
        height: mainBackground.height + 12
        anchors.top: mainBackground.top

        property real position: 0

        function updateVisiblePosition()
        {
            x = msecToPixels(position - playerWidget.min)
        }

        Canvas
        {
            id: startLoopMarkerCanvas
            width: 12
            height: parent.height
            x: -1

            onPaint:
            {
                var ctx = getContext("2d")
                ctx.miterLimit = 0.1
                ctx.strokeStyle = "#F2994A"
                ctx.lineWidth = 2
                ctx.moveTo(1, 1)
                ctx.lineTo(6, 1)
                ctx.moveTo(1, 1)
                ctx.lineTo(1, 12)
                ctx.lineTo(6, 12)
                ctx.stroke()
            }

            Connections
            {
                target: repeatButton
                function onCheckedChanged()
                {
                    startLoopMarkerCanvas.requestPaint()
                }
            }

            MfxMouseArea
            {
                id: startLoopMarkerMovingArea
                anchors.topMargin: -4
                anchors.top: parent.top
                anchors.leftMargin: -4
                anchors.left: parent.left
                anchors.right: parent.right
                height: 12
                hoverEnabled: true

                drag.target: startLoopMarker
                drag.axis: Drag.XAxis
                drag.minimumX: 0
                drag.maximumX: stopLoopMarker.position < playerWidget.max ? stopLoopMarker.x : playerWidget.width

                drag.threshold: 0
                drag.smoothed: false

                cursorShape: Qt.SizeHorCursor
                onPressed: timeScaleMouseArea.visible = false
                onReleased: timeScaleMouseArea.visible = true
            }
        }

        Rectangle
        {
            width: 1
            height: waveformBackground.height + 12
            color: "#F2994A"
            visible: repeatButton.checked
            x: -1
            y: 12
        }

        onXChanged:
        {
            position = playerWidget.min + pixelsToMsec(x)

            if(playerWidget.position < startPositionMarker.position)
            {
                playerWidget.position = startPositionMarker.position
                positionCursor.updateVisiblePosition()
            }

            if(startLoopMarker.position < startPositionMarker.position)
            {
                startPositionMarker.position = startLoopMarker.position
            }

        }

        onPositionChanged:
        {
            updateVisiblePosition()
            project.setProperty("startLoop", startLoopMarker.position)
        }
    }

    Item
    {
        id: stopLoopMarker
        width: 2
        height: mainBackground.height + 12
        anchors.top: mainBackground.top

        property real position: 0

        function updateVisiblePosition()
        {
            x = msecToPixels(position - playerWidget.min)
        }

        Canvas
        {
            id: stopLoopMarkerCanvas
            width: 12
            height: parent.height
            x: -7
            y: 0

            onPaint:
            {
                var ctx = getContext("2d")
                ctx.miterLimit = 0.1
                ctx.strokeStyle = "#F2994A"
                ctx.lineWidth = 2
                ctx.moveTo(1, 1)
                ctx.lineTo(6, 1)
                ctx.lineTo(6, 12)
                ctx.lineTo(1, 12)
                ctx.stroke()
            }

            Connections
            {
                target: repeatButton
                function onCheckedChanged()
                {
                    stopLoopMarkerCanvas.requestPaint()
                }
            }

            MfxMouseArea
            {
                id: stopLoopMarkerMovingArea
                anchors.topMargin: -4
                anchors.top: parent.top
                anchors.leftMargin: -4
                anchors.left: parent.left
                anchors.right: parent.right
                height: 12
                hoverEnabled: true

                drag.target: stopLoopMarker
                drag.axis: Drag.XAxis
                drag.minimumX: startLoopMarker.position > playerWidget.min ? startLoopMarker.x : 0
                drag.maximumX: playerWidget.width

                drag.threshold: 0
                drag.smoothed: false

                cursorShape: Qt.SizeHorCursor
                onPressed: timeScaleMouseArea.visible = false
                onReleased: timeScaleMouseArea.visible = true
            }
        }

        Rectangle
        {
            width: 1
            height: waveformBackground.height + 12
            color: "#F2994A"
            visible: repeatButton.checked
            x: -1
            y: 12
        }

        onXChanged:
        {
            position = playerWidget.min + pixelsToMsec(x)

            if(stopLoopMarker.position > stopPositionMarker.position)
            {
                stopPositionMarker.position = stopLoopMarker.position
            }

            if(playerWidget.position > stopPositionMarker.position)
            {
                playerWidget.position = stopPositionMarker.position
            }
        }

        onPositionChanged:
        {
            updateVisiblePosition()
            project.setProperty("stopLoop", stopLoopMarker.position)
        }
    }

    Item
    {
        id: positionCursor
        width: 2
        height: mainBackground.height + 12
        anchors.top: mainBackground.top

        property int position: playerWidget.position

        function updateVisiblePosition()
        {
            x = msecToPixels(position - playerWidget.min)
        }

        Canvas
        {
            width: 12
            height: parent.height
            x: - width / 2 + 1
            y: 12

            onPaint:
            {
                var ctx = getContext("2d")
                ctx.miterLimit = 0.1
                ctx.strokeStyle = "#99006DFF"
                ctx.lineWidth = 2
                ctx.fillStyle = "#6BAAFF"
                ctx.lineTo(width, 0)
                ctx.lineTo(width / 2, width)
                ctx.lineTo(0, 0)
                ctx.closePath()
                ctx.stroke()
                ctx.fill()
            }

            MfxMouseArea
            {
                id: cursorMovingArea
                anchors.topMargin: -4
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 12
                hoverEnabled: true

                drag.target: positionCursor
                drag.axis: Drag.XAxis
                drag.minimumX: startPositionMarker.x
                drag.maximumX: stopPositionMarker.x

                drag.threshold: 0
                drag.smoothed: false

                cursorShape: Qt.SizeHorCursor
                onPressed: timeScaleMouseArea.visible = false
                onReleased: timeScaleMouseArea.visible = true

                onMouseXChanged:
                {
                    if(mouse.buttons === Qt.LeftButton)
                    {
                        if(playerWidget.position > project.property("prePlayInterval") && playerWidget.position < project.property("prePlayInterval") + waveformWidget.duration())
                        {
                            waveformWidget.setPlayerPosition(playerWidget.position - project.property("prePlayInterval"))
                        }
                    }
                }
            }
        }

        Rectangle
        {
            width: 2
            height: waveformBackground.height
            color: "#99006DFF"
            x: 0
            y: 24
        }

        onXChanged:
        {
            playerWidget.position = playerWidget.min + pixelsToMsec(x)
        }

        onPositionChanged:
        {
            updateVisiblePosition()
        }
    }

    Image
    {
        id: cursorImageForTimeScale
        source: "qrc:/zoom"
        visible: false
    }

    MfxButton
    {
        id: stopButton
        width: 16
        height: 16
        color:  "#222222"
        pressedColor:  "#111111"

        anchors.leftMargin: 4
        anchors.bottomMargin: 4
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        Image
        {
            source: "qrc:/stopButton"
            anchors.centerIn: parent
        }

        onClicked:
        {
            waveformWidget.pause()
            playerTimer.stop()
            playerWidget.position = startPositionMarker.position
            playButton.checked = false
        }
    }

    MfxButton
    {
        id: playButton
        width: 16
        height: 16
        color:  "#222222"
        pressedColor:  "#111111"
        checkable: true

        anchors.leftMargin: 2
        anchors.bottomMargin: 4
        anchors.left: stopButton.right
        anchors.bottom: parent.bottom

        Image
        {
            source: playButton.checked ? "qrc:/pauseButton" : "qrc:/playButton"
            anchors.centerIn: parent
        }

        onCheckedChanged:
        {
            if(checked)
            {
                playerTimer.start()
            }

            else
            {
                waveformWidget.pause()
                playerTimer.stop()
            }
        }
    }

    MfxButton
    {
        id: recordButton
        width: 16
        height: 16
        color:  "#222222"
        pressedColor:  "#111111"

        anchors.leftMargin: 2
        anchors.bottomMargin: 4
        anchors.left: playButton.right
        anchors.bottom: parent.bottom

        Image
        {
            source: "qrc:/recordButton"
            anchors.centerIn: parent
        }
    }

    Rectangle
    {
        id: timerArea
        width: 76
        height: 16
        color:  "#222222"
        radius: 2

        anchors.leftMargin: 2
        anchors.bottomMargin: 4
        anchors.left: recordButton.right
        anchors.bottom: parent.bottom

        Text
        {
            id: timer
            text: "00:00:00.00"
            color: "#eeeeee"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            anchors.centerIn: parent
            font.family: "Roboto"
            font.pixelSize: 12
        }

        Connections
        {
            target: positionCursor
            function onXChanged()
            {
                timer.text = waveformWidget.positionString(pixelsToMsec(positionCursor.x) + playerWidget.min, "hh:mm:ss.zzz").substring(0, 11)
            }
        }
    }

    MfxButton
    {
        id: settingsButton
        width: 16
        height: 16
        color:  "#222222"
        pressedColor:  "#111111"

        anchors.leftMargin: 8
        anchors.bottomMargin: 4
        anchors.left: timerArea.right
        anchors.bottom: parent.bottom

        Image
        {
            source: "qrc:/settingsButton"
            anchors.centerIn: parent
        }

        onClicked: timelineSettingsWidget.visible = true
    }

    MfxButton
    {
        id: resetButton
        width: 40
        height: 16
        color:  "#222222"
        pressedColor:  "#111111"

        anchors.leftMargin: 8
        anchors.bottomMargin: 4
        anchors.left: settingsButton.right
        anchors.bottom: parent.bottom

        text: qsTr("reset")
        textSize: 10

        onClicked:
        {
            project.setProperty("startPosition", 0)
            project.setProperty("stopPosition", waveformWidget.duration())
            project.setProperty("startLoop", 0)
            project.setProperty("stopLoop", waveformWidget.duration())

            project.setProperty("prePlayInterval", 0)
            project.setProperty("postPlayInterval", 0)

            playerWidget.min = 0
            playerWidget.max = playerWidget.projectDuration()

            waveformWidget.showAll();

            startLoopMarker.position = project.property("startLoop")
            stopLoopMarker.position = project.property("stopLoop")
            startPositionMarker.position = project.property("startPosition")
            stopPositionMarker.position = project.property("stopPosition")
            positionCursor.position = startPositionMarker.position

            timelineSettingsWidget.updateFields()
        }
    }

    MfxButton
    {
        id: repeatButton
        width: 28
        height: 16
        color:  "#222222"
        checkable: true

        anchors.leftMargin: 8
        anchors.bottomMargin: 4
        anchors.left: resetButton.right
        anchors.bottom: parent.bottom

        Image
        {
            source: repeatButton.checked ? "qrc:/repeatButtonChecked" : "qrc:/repeatButton"
            anchors.centerIn: parent
        }
    }

    Item
    {
        id: volumeRegulator
        width: 104
        height: 8

        anchors.rightMargin: 20
        anchors.right: monoModeButton.left
        anchors.bottomMargin: 2
        anchors.bottom: scrollArea.bottom

        Text
        {
            id: volumeCaption
            text: qsTr("Volume")

            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 8
            anchors.right: parent.left

            color: "#eeeeee"
            padding: 0
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            font.family: "Roboto"
            font.pixelSize: 12
        }

        Canvas
        {
            anchors.fill: parent

            onPaint:
            {
                var ctx = getContext("2d")
                ctx.miterLimit = 0.1
                ctx.fillStyle = "#222222"
                ctx.lineTo(width, height)
                ctx.lineTo(width, 0)
                ctx.lineTo(0, height)
                ctx.fill()
            }
        }

        Rectangle
        {
            id: volumeLevelBar
            width: 4
            height: 12
            radius: 2
            color: "#ffffff"
            anchors.verticalCenter: volumeRegulator.verticalCenter
            x: 100

            onXChanged:
            {
                waveformWidget.setVolume(x);
            }
        }

        MouseArea
        {
            id: barMovingArea
            anchors.topMargin: -10
            anchors.bottomMargin: -10
            anchors.fill: parent

            onClicked:
            {
                volumeLevelBar.x = mouseX
            }

            onPositionChanged:
            {
                if(mouse.buttons)
                {
                    if(mouseX < 0)
                        volumeLevelBar.x = 0

                    else if(mouseX > volumeRegulator.width)
                        volumeLevelBar.x = 100

                    else
                        volumeLevelBar.x = mouseX
                }
            }

            onWheel:
            {
                if(wheel.angleDelta.y > 0)
                {
                    if(volumeLevelBar.x + 5 <= 100)
                        volumeLevelBar.x += 5
                    else
                        volumeLevelBar.x = 100
                }

                else
                {
                    if(volumeLevelBar.x - 5 >= 0)
                        volumeLevelBar.x -= 5
                    else
                        volumeLevelBar.x = 0
                }
            }
        }
    }

    ButtonGroup
    {
        id: modeButtons
        checkedButton: monoModeButton

        onClicked: button == stereoModeButton ? waveformWidget.setStereoMode(true) : waveformWidget.setStereoMode(false)
    }

    MfxButton
    {
        id: stereoModeButton
        width: 54
        height: 16

        anchors.rightMargin: 8
        anchors.bottomMargin: 4
        anchors.right: scrollArea.left
        anchors.bottom: parent.bottom

        checkable: true
        color: "#27AE60"
        text: qsTr("Stereo")

        ButtonGroup.group: modeButtons
    }

    MfxButton
    {
        id: monoModeButton
        width: 54
        height: 16

        anchors.rightMargin: 2
        anchors.bottomMargin: 4
        anchors.right: stereoModeButton.left
        anchors.bottom: parent.bottom

        checkable: true
        color: "#27AE60"
        text: qsTr("Mono")

        ButtonGroup.group: modeButtons
    }

    Rectangle
    {
        id: scrollArea
        width: 164
        height: 16
        anchors.rightMargin: 2
        anchors.bottomMargin: 4
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        radius: 2
        color: "#222222"

        Text
        {
            id: visibleAreaRatio
            text: "0"
            anchors.leftMargin: 4
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            color: "#eeeeee"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            font.family: "Roboto"
            font.pixelSize: 10

            Connections
            {
                target: playerWidget
                function onMaxChanged()
                {
                    if(playerWidget.projectDuration())
                    {
                        visibleAreaRatio.text = Math.round((playerWidget.max - playerWidget.min) / playerWidget.projectDuration() * 100) + "%"
                    }
                }
            }

            Connections
            {
                target: playerWidget
                function onMinChanged()
                {
                    if(playerWidget.projectDuration())
                    {
                        visibleAreaRatio.text = Math.round((playerWidget.max - playerWidget.min) / playerWidget.projectDuration() * 100) + "%"
                    }
                }
            }
        }

        Rectangle
        {
            id: separator
            width: 2
            height: 16
            color: "#444444"
            anchors.right: positioningRect.left
        }

        WaveformWidget
        {
            id: scrollBackgroundWaveform
            anchors.fill: positioningRect
        }

        Rectangle
        {
            id: positioningRect

            width: 130
            height: 16

            anchors.right: parent.right
            anchors.bottom: parent.bottom

            color: "transparent"

            Rectangle
            {
                id: positionMarker
                width: 2
                height: parent.height - 4
                y: 2
                color: "red"

                Connections
                {
                    target: waveformWidget
                    function onPositionChanged(pos)
                    {
                        positionMarker.x = pos / waveformWidget.duration() * scrollBackgroundWaveform.width
                    }
                }
            }

            ZoomingMouseArea
            {
                id: bottomScrollArea
                image: "qrc:/resize"
                anchors.fill: parent
                hoverEnabled: true

                onPressed:
                {
                    bottomScrollArea.cursorImage.visible = false
                }

                onReleased:
                {
                    bottomScrollArea.cursorImage.visible = true
                }

                onMoved:
                {
                    playerWidget.move(-dx * (playerWidget.width / width), dy)
                }

                onWheel:
                {
                    timeScaleMouseArea.resizingCenterMarker.x = timeScaleMouseArea.width / 2
                    playerWidget.zoom(wheel.angleDelta.y > 0 ? 2 : -2)
                }
            }

            Rectangle
            {
                id: scrollBar
                height: parent.height
                width: scrollBackgroundWaveform.width
                color: "#20507FE6"
                border.width: 2
                border.color: "#507FE6"
                radius: 2

                function refresh()
                {
                    x = playerWidget.min / playerWidget.projectDuration() * positioningRect.width
                    width = (playerWidget.max - playerWidget.min) / playerWidget.projectDuration() * positioningRect.width
                    if(width < 5)
                        width = 5
                }

                Connections
                {
                    target: playerWidget
                    function onMinChanged()
                    {
                        scrollBar.refresh()
                    }
                }

                Connections
                {
                    target: playerWidget
                    function onMaxChanged()
                    {
                        scrollBar.refresh()
                    }
                }
            }
        }
    }

    Text
    {
        id: waitingText
        color: "#eeeeee"
        padding: 0
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        font.family: "Roboto"
        font.pixelSize: 14
        text: qsTr("Not available")

        anchors.centerIn: waveformBackground
    }

    Item
    {
        id: timelineSettingsWidget

        x: settingsButton.x
        y: settingsButton.y - height - 10
        width: 274
        height: 108
        visible: false

        function updateFields()
        {
            setPreIntervalValue()
            setPostIntervalValue()

            trackDurationText.text = waveformWidget.positionString(waveformWidget.duration(), "hh:mm:ss.zzz").substring(3, 11)
            projectDurationText.text = waveformWidget.positionString(playerWidget.projectDuration(), "hh:mm:ss.zzz").substring(3, 11)
        }

        function setPreIntervalValue()
        {
            let string = waveformWidget.positionString(project.property("prePlayInterval"), "hh:mm:ss.zzz").substring(0, 11)
            preMins.text = string.substr(3, 2)
            preSecs.text = string.substr(6, 2)
            preMsecs.text = string.substr(9, 2)
        }

        function setPostIntervalValue()
        {
            let string = waveformWidget.positionString(project.property("postPlayInterval"), "hh:mm:ss.zzz").substring(0, 11)
            postMins.text = string.substr(3, 2)
            postSecs.text = string.substr(6, 2)
            postMsecs.text = string.substr(9, 2)
        }

        Rectangle
        {
            id: timelineSettingsWidgetBackground
            radius: 2
            color: "#444444"
            anchors.fill: parent

            Text
            {
                color: "#ffffff"
                text: qsTr("Timeline settings")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideMiddle
                anchors.left: parent.left
                anchors.right: parent.right
                font.family: "Roboto"
                topPadding: 8
            }

            MouseArea
            {
                height: 28
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

                drag.target: timelineSettingsWidget
                drag.axis: Drag.XandYAxis

                drag.minimumX: 0
                drag.maximumX: playerWidget.width - timelineSettingsWidget.width
                drag.minimumY: 0
                drag.maximumY: playerWidget.height - timelineSettingsWidget.height
            }

            Button
            {
                width: 25
                height: 25
                anchors.top: parent.top
                anchors.topMargin: 3
                anchors.right: parent.right

                bottomPadding: 0
                topPadding: 0
                rightPadding: 0
                leftPadding: 0

                background: Rectangle {
                        color: "#444444"
                        opacity: 0
                    }

                Image
                {
                    source: "qrc:/utilityCloseButton"
                }

                onClicked: timelineSettingsWidget.visible = false
            }

            Text
            {
                color: "#ffffff"
                text: qsTr("Add before")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideMiddle
                font.family: "Roboto"
                font.pointSize: 7

                anchors.left: preIntervalBackground.left
                anchors.bottom: preIntervalBackground.top
                anchors.bottomMargin: 2
            }

            Rectangle
            {
                id: preIntervalBackground
                x: 10
                y: 44
                width: 58
                height: 18
                radius: 2
                color: "black"

                TextField
                {
                    id: preMins
                    width: 16
                    height: parent.height
                    text: "00"
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHRight
                    padding: 0
                    font.pointSize: 8

                    anchors.left: parent.left
                    anchors.top: parent.top

                    validator: RegExpValidator { regExp: /[0-9]+/ }
                    maximumLength: 2

                    background: Rectangle
                    {
                        color: "transparent"
                    }

                    onFocusChanged:
                    {
                        if(focus)
                        {
                            selectAll()
                        }
                    }
                }

                Text
                {
                    id: preMinsColon
                    height: parent.height
                    color: "#ffffff"
                    text: ":"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideMiddle
                    font.family: "Roboto"

                    anchors.left: preMins.right
                    anchors.leftMargin: 2
                    anchors.top: parent.top
                }

                TextField
                {
                    id: preSecs
                    width: 16
                    height: parent.height
                    text: "00"
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHRight
                    padding: 0
                    font.pointSize: 8

                    anchors.left: preMinsColon.right
                    anchors.leftMargin: -2
                    anchors.top: parent.top

                    validator: RegExpValidator { regExp: /[0-9]+/ }
                    maximumLength: 2

                    background: Rectangle
                    {
                        color: "transparent"
                    }

                    onFocusChanged:
                    {
                        if(focus)
                        {
                            selectAll()
                        }
                    }
                }

                Text
                {
                    id: preSecsColon
                    height: parent.height
                    color: "#ffffff"
                    text: "."
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideMiddle
                    font.family: "Roboto"

                    anchors.left: preSecs.right
                    anchors.leftMargin: 2
                    anchors.top: parent.top
                }

                TextField
                {
                    id: preMsecs
                    width: 16
                    height: parent.height
                    text: "00"
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHRight
                    padding: 0
                    font.pointSize: 8

                    anchors.left: preSecsColon.right
                    anchors.leftMargin: -2
                    anchors.top: parent.top

                    validator: RegExpValidator { regExp: /[0-9]+/ }
                    maximumLength: 2

                    background: Rectangle
                    {
                        color: "transparent"
                    }

                    onFocusChanged:
                    {
                        if(focus)
                        {
                            selectAll()
                        }
                    }
                }
            }

            Text
            {
                color: "#ffffff"
                text: qsTr("Track time")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideMiddle
                font.family: "Roboto"
                font.pointSize: 7

                anchors.left: trackDurationBackground.left
                anchors.bottom: trackDurationBackground.top
                anchors.bottomMargin: 2
            }

            Rectangle
            {
                id: trackDurationBackground
                width: 58
                height: 18
                radius: 2
                color: "#333333"

                anchors.left: preIntervalBackground.right
                anchors.leftMargin: 8
                anchors.top: preIntervalBackground.top

                Text
                {
                    id: trackDurationText
                    color: "#ffffff"
                    text: qsTr("00:00:00")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideMiddle
                    font.family: "Roboto"
                    font.pointSize: 9

                    padding: 0
                    anchors.centerIn: parent
                }
            }

            Text
            {
                color: "#ffffff"
                text: qsTr("Add after")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideMiddle
                font.family: "Roboto"
                font.pointSize: 7

                anchors.left: postIntervalBackground.left
                anchors.bottom: postIntervalBackground.top
                anchors.bottomMargin: 2
            }

            Rectangle
            {
                id: postIntervalBackground
                width: 58
                height: 18
                radius: 2
                color: "black"

                anchors.left: trackDurationBackground.right
                anchors.leftMargin: 8
                anchors.top: preIntervalBackground.top

                TextField
                {
                    id: postMins
                    width: 16
                    height: parent.height
                    text: "00"
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHRight
                    padding: 0
                    font.pointSize: 8

                    anchors.left: parent.left
                    anchors.top: parent.top

                    validator: RegExpValidator { regExp: /[0-9]+/ }
                    maximumLength: 2

                    background: Rectangle
                    {
                        color: "transparent"
                    }

                    onFocusChanged:
                    {
                        if(focus)
                        {
                            selectAll()
                        }
                    }
                }

                Text
                {
                    id: postMinsColon
                    height: parent.height
                    color: "#ffffff"
                    text: ":"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideMiddle
                    font.family: "Roboto"

                    anchors.left: postMins.right
                    anchors.leftMargin: 2
                    anchors.top: parent.top
                }

                TextField
                {
                    id: postSecs
                    width: 16
                    height: parent.height
                    text: "00"
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHRight
                    padding: 0
                    font.pointSize: 8

                    anchors.left: postMinsColon.right
                    anchors.leftMargin: -2
                    anchors.top: parent.top

                    validator: RegExpValidator { regExp: /[0-9]+/ }
                    maximumLength: 2

                    background: Rectangle
                    {
                        color: "transparent"
                    }

                    onFocusChanged:
                    {
                        if(focus)
                        {
                            selectAll()
                        }
                    }
                }

                Text
                {
                    id: postSecsColon
                    height: parent.height
                    color: "#ffffff"
                    text: "."
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideMiddle
                    font.family: "Roboto"

                    anchors.left: postSecs.right
                    anchors.leftMargin: 2
                    anchors.top: parent.top
                }

                TextField
                {
                    id: postMsecs
                    width: 16
                    height: parent.height
                    text: "00"
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHRight
                    padding: 0
                    font.pointSize: 8

                    anchors.left: postSecsColon.right
                    anchors.leftMargin: -2
                    anchors.top: parent.top

                    validator: RegExpValidator { regExp: /[0-9]+/ }
                    maximumLength: 2

                    background: Rectangle
                    {
                        color: "transparent"
                    }

                    onFocusChanged:
                    {
                        if(focus)
                        {
                            selectAll()
                        }
                    }
                }
            }

            Text
            {
                color: "#ffffff"
                text: qsTr("Total time")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideMiddle
                font.family: "Roboto"
                font.pointSize: 7

                anchors.left: projectDurationBackground.left
                anchors.bottom: projectDurationBackground.top
                anchors.bottomMargin: 2
            }

            Rectangle
            {
                id: projectDurationBackground
                width: 58
                height: 18
                radius: 2
                color: "#333333"

                anchors.left: postIntervalBackground.right
                anchors.leftMargin: 8
                anchors.top: preIntervalBackground.top

                Text
                {
                    id: projectDurationText
                    color: "#ffffff"
                    text: qsTr("00:00:00")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideMiddle
                    font.family: "Roboto"
                    font.pointSize: 9

                    padding: 0
                    anchors.centerIn: parent
                }
            }

            MfxButton
            {
                id: setButton
                color: "#2F80ED"
                text: qsTr("Apply")

                anchors.left: trackDurationBackground.left
                anchors.right: postIntervalBackground.right
                anchors.top: trackDurationBackground.bottom
                anchors.topMargin: 12

                onClicked:
                {
                    project.setProperty("prePlayInterval", Number(preMins.text) * 60000 + Number(preSecs.text) * 1000 + Number(preMsecs.text) * 10)
                    project.setProperty("postPlayInterval", Number(postMins.text) * 60000 + Number(postSecs.text) * 1000 + Number(postMsecs.text) * 10)
                    timelineSettingsWidget.updateFields()
                    timelineSettingsWidget.visible = false

                    playerWidget.min = 0
                    playerWidget.max = playerWidget.projectDuration()

                    scrollBackgroundWaveform.anchors.leftMargin = project.property("prePlayInterval") / playerWidget.projectDuration() * positioningRect.width
                    scrollBackgroundWaveform.anchors.rightMargin = project.property("postPlayInterval") / playerWidget.projectDuration() * positioningRect.width
                    scrollBackgroundWaveform.showAll()
                }
            }
        }

    }

    Connections
    {
        target: waveformWidget
        function onTrackDownloaded()
        {
            scrollBackgroundWaveform.setAudioTrackFile(settingsManager.workDirectory() + "/" + project.property("audioTrackFile"))
            waitingText.visible = false
            showPlayerElements()

            if(project.property("startPosition") === -1) // Загрузили трек для нового проекта
            {
                project.setProperty("startPosition", 0)
                project.setProperty("stopPosition", waveformWidget.duration())
                project.setProperty("startLoop", 0)
                project.setProperty("stopLoop", waveformWidget.duration())

                project.setProperty("prePlayInterval", 0)
                project.setProperty("postPlayInterval", 0)
            }

            playerWidget.min = 0
            playerWidget.max = playerWidget.projectDuration()

            waveformWidget.showAll();

            startLoopMarker.position = project.property("startLoop")
            stopLoopMarker.position = project.property("stopLoop")
            startPositionMarker.position = project.property("startPosition")
            stopPositionMarker.position = project.property("stopPosition")
            positionCursor.position = startPositionMarker.position

            timelineSettingsWidget.updateFields()

            cueView.loadCues()
//            cueView.refresh()
        }
    }

    Connections
    {
        target: scrollBackgroundWaveform
        function onTrackDownloaded()
        {
            scrollBackgroundWaveform.anchors.leftMargin = project.property("prePlayInterval") / playerWidget.projectDuration() * positioningRect.width
            scrollBackgroundWaveform.anchors.rightMargin = project.property("postPlayInterval") / playerWidget.projectDuration() * positioningRect.width
            scrollBackgroundWaveform.showAll()
        }
    }

    Connections
    {
        target: waveformWidget
        function onPositionChanged(pos)
        {
            let currPos = project.property("prePlayInterval") + pos

            if(repeatButton.checked && currPos >= stopLoopMarker.position)
            {
                waveformWidget.pause()
                playerWidget.position = startLoopMarker.position
                playerTimer.start()
            }

            else if(currPos < stopPositionMarker.position)
            {
                playerWidget.position = currPos

                if(waveformWidget.duration() - pos < 10)
                {
                    waveformWidget.pause()
                    playerTimer.start()
                }
            }

            else
            {
                waveformWidget.pause()
                playButton.checked = false
            }
        }
    }

    Component.onCompleted:
    {
        hidePlayerElements()
    }
}
