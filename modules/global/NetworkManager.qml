pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id:networkManager

    property string connectionType: "unknown"

    property var scanning: true

    property var savedConnections: []

    property var availableNetworks: []

    readonly property var activeConnections: savedConnections.filter(c => c.active)

    readonly property var inactiveConnections: savedConnections.filter(c => !c.active)
    
    function getConnectionType(){
        return connectionType
    }
    function getSavedConnections(){
        return savedConnections
    }
    function refreshConnectionType() {
        nmcli.exec(["nmcli", "-t", "-f", "DEVICE,TYPE,STATE", "device"])
    }
    function refreshSavedConnections() {
        nmcliSaved.exec(["nmcli", "-t", "-f", "NAME,UUID,TYPE,DEVICE", "connection", "show"])
    }
    function rescanWifi(){
        nmcliWifiScan.exec([
            "nmcli",
            "-t",
            "-f",
            "IN-USE,SSID,SECURITY,SIGNAL,BARS,DEVICE",
            "device",
            "wifi",
            "list",
            "--rescan",
            "yes"
        ])
    }
    function changeConnection(connection){
        if (connection.active)
            nmcliConn.exec(["nmcli", "connection", "down", connection.uuid])
        else
            nmcliConn.exec(["nmcli", "connection", "up", connection.uuid])
    }
    function connectToNewNetwork(ssid,password){
        const ap = availableNetworks.find(n => n.ssid === ssid)
        const sec = (ap?.security ?? "").trim()
        const ifname = ap?.device

        const args = ["nmcli", "dev", "wifi", "connect", ssid, "password", password, ifname, wlan0]
        nmcliWifiConnect.exec(args)
    }
    function refresh(){
        refreshConnectionType()
        refreshSavedConnections()
        rescanWifi()
    }
    Process {
        id: nmcli

        stdout: StdioCollector {
            onStreamFinished: {
                const out = text.trim()
                const lines = out.length ? out.split("\n") : []

                for (const line of lines) {
                    const parts = line.split(":")
                    if (parts.length < 3) continue

                    const type = parts[1]
                    const state = parts[2]

                    if (state === "connected") {
                        connectionType = type   // no need for networkManager.
                        return
                    }
                }

                connectionType = "disconnected"
            }
        }
    }

    Process {
        id: nmcliSaved
        stdout: StdioCollector {
            onStreamFinished: {
                const out = text.trim()
                const lines = out.length ? out.split("\n") : []

                const list = []
                for (const line of lines) {
                    // NAME:UUID:TYPE:DEVICE
                    const parts = line.split(":")
                    if (parts.length < 4) continue

                    const name = parts[0]
                    const uuid = parts[1]
                    const type = parts[2]
                    const device = parts[3] // "--" when not active

                    list.push({
                        name,
                        uuid,
                        type,
                        device,
                        active: device && device !== "--"
                    })
                }

                savedConnections = list
                //console.log("savedConnections size: "+ list.length)
            }
        }
    }
    Process {
        id: nmcliWifiScan

        stdout: StdioCollector {
            onStreamFinished: {
                const out = text.trim()
                const lines = out.length ? out.split("\n") : []

                // 1) Parse AP rows
                const aps = []
                for (const line of lines) {
                    if (!line) continue

                    // IN-USE:SSID:SECURITY:SIGNAL:BARS:DEVICE
                    const parts = line.split(":")
                    if (parts.length < 6) continue

                    const inUse = parts[0] === "*"
                    const ssid = parts[1]
                    const security = parts[2]
                    const signal = Number(parts[3])
                    const bars = parts[4]
                    const device = parts[5]

                    if (!ssid) continue

                    aps.push({ inUse, ssid, security, signal, bars, device })
                }

                // 2) Collapse by SSID (one row per SSID)
                const map = {}
                for (const ap of aps) {
                    const key = ap.ssid

                    if (!map[key]) {
                        map[key] = {
                            inUse: ap.inUse,
                            ssid: ap.ssid,
                            security: ap.security,
                            signal: ap.signal,
                            bars: ap.bars,
                            device: ap.device
                        }
                    } else {
                        // If any AP is currently used, mark the SSID used
                        map[key].inUse = map[key].inUse || ap.inUse

                        // Keep strongest signal; take its bars/device/security
                        if (ap.signal > map[key].signal) {
                            map[key].signal = ap.signal
                            map[key].bars = ap.bars
                            map[key].device = ap.device
                            map[key].security = ap.security
                        }
                    }
                }

                // 3) Assign + sort (connected first, then strongest)
                networkManager.availableNetworks = Object.values(map).sort((a, b) =>
                    (b.inUse - a.inUse) || (b.signal - a.signal) || a.ssid.localeCompare(b.ssid)
                )

                networkManager.scanning = false
            }
        }
    }
    Process {
        id: nmcliConn
        stdout: StdioCollector { onStreamFinished: { refreshConnectionType(); refreshSavedConnections(); } }
        stderr: StdioCollector { onStreamFinished: { } }
    }
    Process {
        id: nmcliWifiConnect

        property var output: ""
        stdout: StdioCollector {
            onStreamFinished: {
                console.log("wifi connect stdout:", text.trim())
            }    
        }

        stderr: StdioCollector {
            onStreamFinished: {
                const err = text.trim()
                if (err.length) {
                    console.log("wifi connect stderr:", err)
                    output: "failed"
                } else {
                    output: "success"
                }
            }
        }
    }
    
    Component.onCompleted: {
        refreshConnectionType()
        refreshSavedConnections()
        rescanWifi()
    }

    /*Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: refreshConnectionType()
    }*/
}