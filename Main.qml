import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
    id: root

    property string fontFamily: config.fontFamily || "Terminus"
    property int barFontSize: config.barFontSize ? parseInt(config.barFontSize) : 14
    property int barHeight: config.barHeight ? parseInt(config.barHeight) : 18

    property color colBg: config.backgroundColor || "#222222"
    property color colBarBg: config.barBackgroundColor || "#222222"
    property color colBarFg: config.barTextColor || "#bbbbbb"
    property color colBorder: config.normalBorderColor || "#444444"
    property color colSel: config.selectedBorderColor || "#005577"
    property color colSelFg: config.selectedTextColor || "#eeeeee"
    property color colInputBg: config.inputBackgroundColor || "#111111"
    property color colInputFg: config.inputTextColor || "#bbbbbb"
    property color colPlaceholder: config.placeholderColor || "#888887"

    color: colBg

    Image {
        id: wallpaper
        anchors.fill: parent
        source: config.wallpaperPath || ""
        visible: source !== ""
        fillMode: {
            var m = config.wallpaperFillMode || "crop"
            if (m === "fit") return Image.PreserveAspectFit
            if (m === "stretch") return Image.Stretch
            if (m === "tile") return Image.Tile
            return Image.PreserveAspectCrop
        }
        z: -2
    }

    Rectangle {
        id: wallpaperOverlay
        anchors.fill: parent
        color: "#000000"
        opacity: wallpaper.visible ? (config.wallpaperOverlayOpacity ? parseFloat(config.wallpaperOverlayOpacity) : 0.35) : 0
        z: -1
    }

    TextConstants { id: textConstants }

    Rectangle {
        id: bar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: barHeight
        color: colBarBg

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 2
            color: colBg
        }

        Text {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            font.family: fontFamily
            font.pixelSize: barFontSize
            color: colBarFg
            text: Qt.formatDateTime(new Date(), "dd-MM-yyyy HH:mm")

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clock.text = Qt.formatDateTime(new Date(), "dd-MM-yyyy HH:mm")
            }
        }

        Rectangle {
            id: sessionTag
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: sessionText.paintedWidth + 12
            color: colSel

            Text {
                id: sessionText
                anchors.centerIn: parent
                font.family: fontFamily
                font.pixelSize: barFontSize
                color: colSelFg
                text: (sessionModel.data(sessionModel.index(session.index, 0), Qt.DisplayRole) || config.sessionTagText || "dwm") || "dwm"
            }

            MouseArea {
                id: sessionArea
                anchors.fill: parent
                onClicked: sessionMenu.open()
            }

            ListView {
                id: sessionMenu
                visible: false
                anchors.top: parent.bottom
                anchors.right: parent.right
                width: 140
                height: Math.min(sessionModel.count * 20, 120)
                model: sessionModel
                property bool open: false
                function open() { sessionMenu.visible = !sessionMenu.visible }

                delegate: Rectangle {
                    width: sessionMenu.width
                    height: 20
                    color: index === session.index ? colSel : colBarBg
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: fontFamily
                        font.pixelSize: barFontSize
                        color: index === session.index ? colSelFg : colBarFg
                        text: model.name
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            session.index = index
                            sessionMenu.visible = false
                        }
                    }
                }
            }
        }
    }

    Item {
        id: session
        property int index: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    }

    Rectangle {
        id: loginBox
        anchors.centerIn: parent
        width: (config.fieldWidth ? parseInt(config.fieldWidth) : 220) + 48
        height: 150
        color: colBg
        border.width: 1
        border.color: passwordField.activeFocus ? colSel : colBorder

        Column {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            Text {
                id: usernameLabel
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                font.family: fontFamily
                font.pixelSize: 14
                color: colInputFg
                text: (userModel.lastUser || (userModel.count > 0 ? userModel.data(userModel.index(0, 0), Qt.DisplayRole) : "")) || ""
            }

            Rectangle {
                width: parent.width
                height: 1
                color: colBorder
            }

            Column {
                width: parent.width
                spacing: 4
                Rectangle {
                    width: parent.width
                    height: 26
                    color: colInputBg
                    border.width: 1
                    border.color: passwordField.activeFocus ? colSel : colBorder

                    TextInput {
                        id: passwordField
                        anchors.fill: parent
                        anchors.margins: 6
                        font.family: fontFamily
                        font.pixelSize: config.passwordFontSize ? parseInt(config.passwordFontSize) : 14
                        color: colInputFg
                        echoMode: TextInput.Password
                        passwordCharacter: config.passwordCharacter || "*"
                        horizontalAlignment: TextInput.AlignHCenter
                        focus: true
                        selectByMouse: true

                        Keys.onReturnPressed: doLogin()
                        Keys.onEnterPressed: doLogin()

                        cursorDelegate: Rectangle {
                            width: 8
                            height: passwordField.font.pixelSize
                            color: "#8c8c8c"
                            visible: passwordField.activeFocus && passwordField.text.length > 0
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: flashBorder
        anchors.fill: parent
        color: "transparent"
        border.width: 4
        border.color: "#e24b4a"
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    function doLogin() {
        sddm.login(usernameLabel.text, passwordField.text, session.index)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            flashBorder.opacity = 1
            passwordField.text = ""
            resetFlash.start()
        }
    }

    Timer {
        id: resetFlash
        interval: 400
        onTriggered: flashBorder.opacity = 0
    }

    Component.onCompleted: passwordField.forceActiveFocus()
}
