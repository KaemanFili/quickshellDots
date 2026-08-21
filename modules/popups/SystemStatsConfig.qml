import QtQuick
import QtQuick.Layouts
import "../global"

Item {
    id: root

    implicitWidth: 400
    implicitHeight: content.implicitHeight

    function percent(value) {
        return Math.round(value * 100) + "%"
    }

    function formatBytes(value) {
        const units = ["B", "KiB", "MiB", "GiB", "TiB"]
        let amount = Number(value)
        let unit = 0

        while (amount >= 1024 && unit < units.length - 1) {
            amount /= 1024
            unit++
        }

        const decimals = unit === 0 || amount >= 100 ? 0 : 1
        return amount.toFixed(decimals) + " " + units[unit]
    }

    function formatDuration(seconds) {
        const days = Math.floor(seconds / 86400)
        const hours = Math.floor((seconds % 86400) / 3600)
        const minutes = Math.floor((seconds % 3600) / 60)
        return (days > 0 ? days + "d " : "") + hours + "h " + minutes + "m"
    }

    ColumnLayout {
        id: content
        width: parent.width
        spacing: 12

        Text {
            text: "System Stats"
            color: primaryColor
            font.family: fontFamily
            font.pixelSize: 20
            font.bold: true
            style: Text.Outline
            styleColor: textBorderColor
        }

        StatRow {
            label: "CPU"
            value: root.percent(SystemStats.cpuUsage)
            progress: SystemStats.cpuUsage
        }

        StatRow {
            label: "Memory"
            value: root.formatBytes(SystemStats.memoryUsedBytes) + " / "
                + root.formatBytes(SystemStats.memoryTotalBytes)
            progress: SystemStats.memoryUsage
        }

        StatRow {
            label: "Disk"
            value: root.formatBytes(SystemStats.diskUsedBytes) + " / "
                + root.formatBytes(SystemStats.diskTotalBytes)
            progress: SystemStats.diskUsage
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: tertiaryColor
            opacity: 0.5
        }

        RowLayout {
            id: detailsRow
            Layout.fillWidth: true
            spacing: 20

            ColumnLayout {
                Layout.fillWidth: true
                Layout.horizontalStretchFactor: 1
                spacing: 8

                InfoText { label: "CPU load"; value: SystemStats.loadAverage.toFixed(2) }
                InfoText { label: "Network download"; value: root.formatBytes(SystemStats.downloadBytesPerSecond) + "/s" }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.horizontalStretchFactor: 1
                spacing: 8

                InfoText { label: "System uptime"; value: root.formatDuration(SystemStats.uptimeSeconds) }
                InfoText { label: "Network upload"; value: root.formatBytes(SystemStats.uploadBytesPerSecond) + "/s" }
            }
        }
    }

    component StatRow: ColumnLayout {
        required property string label
        required property string value
        required property real progress

        Layout.fillWidth: true
        spacing: 5

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: label
                color: fontColor
                font.family: fontFamily
                font.bold: true
            }

            Item { Layout.fillWidth: true }

            Text {
                text: value
                color: fontColor
                font.family: fontFamily
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 8
            radius: height / 2
            color: tertiaryColor
            opacity: 0.45

            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, progress))
                height: parent.height
                radius: parent.radius
                color: primaryColor
            }
        }
    }

    component InfoText: ColumnLayout {
        required property string label
        required property string value

        Layout.fillWidth: true
        spacing: 2

        Text {
            text: label
            color: tertiaryColor
            font.family: fontFamily
            font.pixelSize: 12
        }

        Text {
            text: value
            color: fontColor
            font.family: fontFamily
            font.pixelSize: 15
            font.bold: true
        }
    }
}
