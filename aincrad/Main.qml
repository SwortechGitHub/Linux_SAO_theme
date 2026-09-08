import QtQuick 2.15
import SddmComponents 2.0
//for shadows
import QtGraphicalEffects 1.0

Rectangle{
    //Properties
    property int rowHeight: 70
    property int rowWidth: 320

    property int headHeight: rowHeight - 15
    property int footHeight: rowHeight - 10

    property int iconSize: 40
    property int inputWidth: 200
    property int inputOffset: 8

    property int borderWidth: 2

    property int fontSizeTitle: 24
    property int fontSize: 20

    property string textColor: "#8c8c8c"
    //Load SAO font
    FontLoader {
        id: saouiBold
        source: "fonts/sao-ui/SAOUI-Bold.otf"
    }

    FontLoader {
        id: saoui
        source: "fonts/sao-ui/SAOUI-Regular.otf"
    }

    width:600
    height:600

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int sessionIndex: session.index

    TextConstants { id: textConstants }

    Connections {
        target: sddm
        onLoginSucceeded: {
        }
        onInformationMessage: {
        }
        onLoginFailed: {
            pw_entry.text = ""
        }
    }

    Background {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        onStatusChanged: {
            if (status == Image.Error && source != config.defaultBackground) {
                source = config.defaultBackground
            }
        }
    }
// All screen
    Rectangle{
        anchors.fill: parent
        color: "transparent"

        Rectangle{
            id: container
            width:rowWidth - 15; height:rowHeight * 2 + headHeight + footHeight + 7
            color: "transparent"

            anchors.centerIn:parent

            DropShadow {
                anchors.fill: container
                horizontalOffset: 0
                verticalOffset: 0
                radius: 12.0
                samples: 10
                color: "#08000000" // Semi-transparent black shadow
                source: container
            }

            Column{
                anchors.centerIn: parent
//====================Title
                Item {
                    width: rowWidth
                    height: headHeight

                    Rectangle {
                        anchors.fill: parent
                        color: "#ffffff"

                    }

                    Text {
                        anchors.centerIn: parent
                        text: "Welcome back to the SAO Project!"
                        font.pixelSize: fontSizeTitle
                        font.bold: true
                        font.family: saouiBold.name
                        color: textColor
                    }
                }
//====================Username
                Item{
                    id: user_wrapper
                    width: rowWidth
                    height: rowHeight

                    Rectangle {
                        anchors.fill: parent
                        color: "#f8f8f8"
                    }

                    Rectangle {
                        width: inputWidth + iconSize + borderWidth * 2
                        height: iconSize + borderWidth * 2

                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: inputOffset

                        color: "#fff"

                        // Border turns blue when the inner PasswordBox has active focus
                        border.color: user_entry.activeFocus ? "#5fb6de" : "#f1f1f1"
                        border.width: borderWidth

                        Row {
                            anchors.centerIn: parent

                            Image {
                                id: user_icon
                                source: "images/user_icon.png"
                                width: iconSize
                                height: iconSize

                                anchors.verticalCenter: parent.verticalCenter
                            }

                            TextBox {
                                id: user_entry
                                textColor: "#8c8c8c"
                                width: inputWidth
                                height: iconSize

                                focusColor: "transparent"
                                borderColor: "transparent"
                                hoverColor: "transparent"

                                anchors.verticalCenter: parent.verticalCenter

                                text: userModel.lastUser
                                font.pixelSize: fontSize
                                font.family: saoui.name

                                KeyNavigation.tab: pw_entry
                            }
                        }
                    }
                }
//====================Password
                Item {
                    id: password_wrapper
                    width: rowWidth
                    height: rowHeight

                    // Outer Background Box
                    Rectangle {
                        anchors.fill: parent
                        color: "#f8f8f8"
                    }

                    // Centered Inner Container with Focus Border
                    Rectangle {
                        width: inputWidth + iconSize + borderWidth * 2
                        height: iconSize + borderWidth * 2

                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -1 * inputOffset

                        color: "#fff"

                        // Border turns blue when the inner PasswordBox has active focus
                        border.color: pw_entry.activeFocus ? "#5fb6de" : "#f1f1f1"
                        border.width: borderWidth

                        Row {
                            anchors.centerIn: parent

                            Image {
                                id: password_icon
                                source: "images/lock.png"
                                width: iconSize
                                height: iconSize

                                anchors.verticalCenter: parent.verticalCenter

                            }

                            TextInput {
                                id: pw_entry
                                color: textColor
                                width: inputWidth
                                height: iconSize
                                leftPadding: 10

                                // Standard QML Password Properties
                                echoMode: TextInput.Password
                                passwordCharacter: "*"

                                // Text Alignment & Styling
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: fontSize
                                font.family: saoui.name
                                clip: true

                                anchors.verticalCenter: parent.verticalCenter

                                KeyNavigation.backtab: user_entry
                                KeyNavigation.tab: login_button

                                Keys.onPressed: function(event) {
                                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        sddm.login(user_entry.text, pw_entry.text, sessionIndex)
                                        event.accepted = true
                                    }
                                }
                            }
                        }
                    }
                }
//====================Button
                FocusScope {
                    id: login_button_container
                    width: rowWidth
                    height: footHeight
                    activeFocusOnTab: true

                    // Tab navigation targets
                    KeyNavigation.backtab: pw_entry
                    KeyNavigation.tab: session

                    // Submit on Enter / Return / Space key press
                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                            sddm.login(user_entry.text, pw_entry.text, sessionIndex)
                            event.accepted = true
                        }
                    }

                    Rectangle {
                        id: login_button
                        anchors.fill: parent

                        // Background turns darker on mouse press OR active focus press
                        color: mouseArea.pressed ? "#dddddd" : "#ffffff"

                        // Border highlights when tabbed onto (activeFocus)
                        border.color: login_button_container.activeFocus ? "#5fb6de" : "#ffffff"
                        border.width: 2

                        Text {
                            anchors.centerIn: parent
                            text: "Login"
                            font.pixelSize: fontSize
                            font.family: saouiBold.name
                            color: textColor
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent

                            onClicked: {
                                login_button_container.forceActiveFocus()
                                sddm.login(user_entry.text, pw_entry.text, sessionIndex)
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        if (user_entry.text === "")
            user_entry.focus = true
            else
                pw_entry.focus = true
    }
}
