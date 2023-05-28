import CoreBluetooth
import Foundation

extension FlutterHelper {
    func handleScan() {
        if btState == .Disconnected || btState == .Discovering {
            if centralManager.state == .poweredOn {
                setAndSendState(.Discovering)

                availableDevices.removeAll()

                // Handle connected device
                let connectedPeripherals = centralManager.retrieveConnectedPeripherals(withServices: [CBUUID(string: FlutterHelper.KosoServiceId)])
                for peripheral in connectedPeripherals {
                    if let name = peripheral.name,
                       name.hasPrefix(FlutterHelper.KosoNamePrefix) {
                        availableDevices.append(peripheral)
                    }
                }

                // Scan new device
                centralManager.scanForPeripherals(withServices: nil)
            } else {
                sendError("BT device is not Ready and Authorized")
            }
        } else {
            sendError("BT device is already Connected")
        }
    }

    func handleStopScan() {
        if btState == .Discovering {
            centralManager.stopScan()
            setAndSendState(.Disconnected)
        }
    }

    func handleConnect(address: String) {
        if btState == .Disconnected || btState == .Discovering {
            if let device = availableDevices.first(where: { $0.identifier.uuidString == address }) {
                setAndSendState(.Connecting)
                centralManager.connect(device)
            } else {
                sendError("Selected device is not available")
            }
        } else {
            sendError("BT device is already Connected")
        }
    }

    func handleDisconnect() {
        if btState == .Connected,
           let device = connectedDevice {
            centralManager.cancelPeripheralConnection(device)
        }
    }

    func handleNaviInfo(_ data: GpsCommand89) {
        guard btState == .Connected,
              let device = connectedDevice,
              let writeChar = writeCharacteristic else { return }

        device.writeValue(data.getData(),
                          for: writeChar,
                          type: .withResponse)
    }

    func handleUpdateNaviNotify(message: String) {
        print("update_navinotify: \(message)")
    }

    func handleDismissNaviNotify() {
    }

    func handleWhatState(result: FlutterResult) {
        result(btState.rawValue)
    }
}
