pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real cpuUsage: 0
    property real memoryUsage: 0
    property real memoryUsedBytes: 0
    property real memoryTotalBytes: 0
    property real loadAverage: 0
    property real uptimeSeconds: 0
    property real downloadBytesPerSecond: 0
    property real uploadBytesPerSecond: 0
    property real diskUsage: 0
    property real diskUsedBytes: 0
    property real diskTotalBytes: 0

    property real previousCpuTotal: 0
    property real previousCpuIdle: 0
    property real previousRxBytes: 0
    property real previousTxBytes: 0
    property real previousNetworkTime: 0

    function clamp(value, minimum, maximum) {
        return Math.max(minimum, Math.min(maximum, value))
    }

    function updateCpu(contents) {
        const line = String(contents).split("\n")[0].trim()
        const fields = line.split(/\s+/).slice(1).map(Number)
        if (fields.length < 5 || fields.some(Number.isNaN))
            return

        const idle = fields[3] + fields[4]
        const total = fields.reduce((sum, value) => sum + value, 0)
        const totalDelta = total - previousCpuTotal
        const idleDelta = idle - previousCpuIdle

        if (previousCpuTotal > 0 && totalDelta > 0)
            cpuUsage = clamp((totalDelta - idleDelta) / totalDelta, 0, 1)

        previousCpuTotal = total
        previousCpuIdle = idle
    }

    function updateMemory(contents) {
        const values = {}
        for (const line of String(contents).split("\n")) {
            const match = line.match(/^(\w+):\s+(\d+)/)
            if (match)
                values[match[1]] = Number(match[2]) * 1024
        }

        const total = values.MemTotal || 0
        const available = values.MemAvailable || 0
        if (total <= 0)
            return

        memoryTotalBytes = total
        memoryUsedBytes = total - available
        memoryUsage = clamp(memoryUsedBytes / total, 0, 1)
    }

    function updateLoad(contents) {
        const value = Number(String(contents).trim().split(/\s+/)[0])
        if (!Number.isNaN(value))
            loadAverage = value
    }

    function updateUptime(contents) {
        const value = Number(String(contents).trim().split(/\s+/)[0])
        if (!Number.isNaN(value))
            uptimeSeconds = value
    }

    function updateNetwork(contents) {
        let rx = 0
        let tx = 0

        for (const line of String(contents).split("\n").slice(2)) {
            const separator = line.indexOf(":")
            if (separator < 0)
                continue

            const device = line.slice(0, separator).trim()
            const fields = line.slice(separator + 1).trim().split(/\s+/).map(Number)
            if (device !== "lo" && fields.length >= 9) {
                rx += fields[0]
                tx += fields[8]
            }
        }

        const now = Date.now()
        const elapsed = (now - previousNetworkTime) / 1000
        if (previousNetworkTime > 0 && elapsed > 0) {
            downloadBytesPerSecond = Math.max(0, (rx - previousRxBytes) / elapsed)
            uploadBytesPerSecond = Math.max(0, (tx - previousTxBytes) / elapsed)
        }

        previousRxBytes = rx
        previousTxBytes = tx
        previousNetworkTime = now
    }

    function refresh() {
        cpuFile.reload()
        memoryFile.reload()
        loadFile.reload()
        uptimeFile.reload()
        networkFile.reload()
    }

    FileView {
        id: cpuFile
        path: "/proc/stat"
        onTextChanged: root.updateCpu(text())
    }

    FileView {
        id: memoryFile
        path: "/proc/meminfo"
        onTextChanged: root.updateMemory(text())
    }

    FileView {
        id: loadFile
        path: "/proc/loadavg"
        onTextChanged: root.updateLoad(text())
    }

    FileView {
        id: uptimeFile
        path: "/proc/uptime"
        onTextChanged: root.updateUptime(text())
    }

    FileView {
        id: networkFile
        path: "/proc/net/dev"
        onTextChanged: root.updateNetwork(text())
    }

    Process {
        id: diskProcess
        command: ["df", "-B1", "--output=size,used", "/"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                if (lines.length < 2)
                    return

                const fields = lines[lines.length - 1].trim().split(/\s+/).map(Number)
                if (fields.length < 2 || fields.some(Number.isNaN) || fields[0] <= 0)
                    return

                root.diskTotalBytes = fields[0]
                root.diskUsedBytes = fields[1]
                root.diskUsage = root.clamp(fields[1] / fields[0], 0, 1)
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Timer {
        interval: 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: diskProcess.running = true
    }
}
