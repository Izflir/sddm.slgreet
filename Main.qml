import QtQuick 2.15
import QtQuick.Window 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: cfg.bgColor

    QtObject {
        id: cfg
        property string bgColor: config.BackgroundColor || "#0C0E0C"
        property string panelColor: config.PanelColor || "#222222"
        property string fieldColor: config.FieldColor || "#191919"
        property string borderColor: config.BorderColor || "#444444"
        property string fgColor: config.FgColor || "#cccccc"
        property string fgBright: config.FgColorBright || "#ffffff"
        property string accent: config.AccentColor || "#808080"
        property string fontFamily: config.FontFamily || "Terminus"
        property int fontSize: parseInt(config.FontSize || "11")
        property int tagCount: parseInt(config.TagCount || "9")
        property string bg: config.background || ""
    }

    FontLoader { id: monoFont; source: "" }

    Image {
        id: wallpaper
        anchors.fill: parent
        visible: cfg.bg !== ""
        source: cfg.bg
        fillMode: Image.PreserveAspectCrop
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: wallpaper.visible ? 0.35 : 0
    }

    property int barHeight: 20

    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: barHeight
        color: cfg.panelColor

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: cfg.borderColor
        }

        Text {
            id: statusText
            anchors.centerIn: parent
            font.family: cfg.fontFamily
            font.pixelSize: cfg.fontSize + 2
            color: cfg.fgColor
            text: Qt.formatDateTime(clock.currentDateTime, "yyyy-dd-MM HH:mm")
        }
    }

    Timer {
        id: clockTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: clock.currentDateTime = new Date()
    }
    QtObject {
        id: clock
        property date currentDateTime: new Date()
    }

    Rectangle {
        id: loginBox
        anchors.centerIn: parent
        width: 300
        height: contentCol.height + 48
        color: cfg.panelColor
        border.width: 1
        border.color: cfg.borderColor

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 2
            color: cfg.accent
        }

        ComboBox {
            id: sessionCombo
            visible: false
            model: sddm.sessionModel || [{ name: "default" }]
            index: sddm.sessionModel ? sddm.sessionModel.lastIndex : 0
        }

        Column {
            id: contentCol
            anchors.centerIn: parent
            spacing: 16
            width: parent.width - 48

            Text {
                text: userModel.lastUser || (userModel.count > 0 ? userModel.data(userModel.index(0, 0), Qt.DisplayRole) : "") || "USER"
                font.family: cfg.fontFamily
                font.pixelSize: cfg.fontSize + 4
                font.bold: true
                color: cfg.fgBright
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TextInput {
                id: userInput
                visible: false
                text: userModel.lastUser || (userModel.count > 0 ? userModel.data(userModel.index(0, 0), Qt.DisplayRole) : "") || ""
            }

            Rectangle {
                id: passField
                anchors.horizontalCenter: parent.horizontalCenter
                width: 168
                height: cfg.fontSize + 18
                color: cfg.fieldColor
                border.width: 1
                border.color: passInput.activeFocus ? cfg.accent : cfg.borderColor
                clip: true
                Behavior on border.color { ColorAnimation { duration: 150 } }

                TextInput {
                    id: passInput
                    anchors.fill: parent
                    anchors.margins: 6
                    horizontalAlignment: TextInput.AlignHCenter
                    verticalAlignment: TextInput.AlignVCenter
                    font.family: cfg.fontFamily
                    font.pixelSize: cfg.fontSize
                    color: cfg.fgBright
                    echoMode: TextInput.Password
                    passwordCharacter: "*"
                    selectByMouse: true
                    focus: true
                    cursorVisible: true
                    cursorDelegate: Rectangle {
                        width: cfg.fontSize * 0.6
                        height: cfg.fontSize + 2
                        color: cfg.accent
                    }
                    Keys.onReturnPressed: sddm.login(userInput.text, passInput.text, sessionCombo.currentIndex)
                    Keys.onEnterPressed: sddm.login(userInput.text, passInput.text, sessionCombo.currentIndex)
                }
            }

            Text {
                id: errorText
                text: ""
                color: "#cc5555"
                font.family: cfg.fontFamily
                font.pixelSize: cfg.fontSize - 2
                height: cfg.fontSize - 2
                opacity: text !== "" ? 1 : 0
                anchors.horizontalCenter: parent.horizontalCenter
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }

        Connections {
            target: sddm
            function onLoginFailed() { errorText.text = "Incorrect Password, Try Again" }
            function onLoginSucceeded() { errorText.text = "" }
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: barHeight
        color: cfg.panelColor

        Rectangle {
            anchors.top: parent.top
            width: parent.width
            height: 1
            color: cfg.borderColor
        }

        Row {
            anchors.centerIn: parent
            spacing: 24

            Row {
                spacing: 6
                Rectangle {
                    color: cfg.accent
                    width: key10.paintedWidth + 8
                    height: key10.paintedHeight + 4
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        id: key10
                        anchors.centerIn: parent
                        text: "F10"
                        font.family: cfg.fontFamily
                        font.pixelSize: cfg.fontSize + 2
                        font.bold: true
                        color: cfg.bgColor
                    }
                }
                Text {
                    text: "SUSPEND"
                    font.family: cfg.fontFamily
                    font.pixelSize: cfg.fontSize + 2
                    color: cfg.fgColor
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: 6
                Rectangle {
                    color: cfg.accent
                    width: key11.paintedWidth + 8
                    height: key11.paintedHeight + 4
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        id: key11
                        anchors.centerIn: parent
                        text: "F11"
                        font.family: cfg.fontFamily
                        font.pixelSize: cfg.fontSize + 2
                        font.bold: true
                        color: cfg.bgColor
                    }
                }
                Text {
                    text: "REBOOT"
                    font.family: cfg.fontFamily
                    font.pixelSize: cfg.fontSize + 2
                    color: cfg.fgColor
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: 6
                Rectangle {
                    color: cfg.accent
                    width: key12.paintedWidth + 8
                    height: key12.paintedHeight + 4
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        id: key12
                        anchors.centerIn: parent
                        text: "F12"
                        font.family: cfg.fontFamily
                        font.pixelSize: cfg.fontSize + 2
                        font.bold: true
                        color: cfg.bgColor
                    }
                }
                Text {
                    text: "SHUTDOWN"
                    font.family: cfg.fontFamily
                    font.pixelSize: cfg.fontSize + 2
                    color: cfg.fgColor
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_F12 && sddm.canPowerOff) {
            sddm.powerOff()
            event.accepted = true
        } else if (event.key === Qt.Key_F11 && sddm.canReboot) {
            sddm.reboot()
            event.accepted = true
        } else if (event.key === Qt.Key_F10 && sddm.canSuspend) {
            sddm.suspend()
            event.accepted = true
        }
    }

    Component.onCompleted: passInput.forceActiveFocus()
}
