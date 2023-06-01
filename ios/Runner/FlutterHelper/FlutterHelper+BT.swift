import CoreBluetooth
import Foundation

extension FlutterHelper: CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // TODO: Special handle on phone bt module state change
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name,
           name.hasPrefix(FlutterHelper.KosoNamePrefix),
           !availableDevices.contains(where: { $0.identifier == peripheral.identifier }) {
            availableDevices.append(peripheral)
        }

        sendScanResult(availableDevices.map { (name: $0.name!, address: $0.identifier.uuidString) })
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard btState == .Connecting else { return }

        connectedDevice = peripheral
        setAndSendState(.Connected)

        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        setAndSendState(.Disconnected)
        sendError("Selected device connected failed")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedDevice = nil
        readCharacteristic = nil
        writeCharacteristic = nil
        setAndSendState(.Disconnected)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard peripheral.identifier == connectedDevice?.identifier,
              btState == .Connected,
              let services = peripheral.services,
              let service = services.first(where: { $0.uuid.uuidString == FlutterHelper.KosoServiceId }) else { return }
        peripheral.discoverCharacteristics(nil, for: service)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard peripheral.identifier == connectedDevice?.identifier,
              btState == .Connected,
              let characteristics = service.characteristics,
              let readChar = characteristics.first(where: { $0.uuid.uuidString == FlutterHelper.KosoReadCharacteristicId }),
              let writeChar = characteristics.first(where: { $0.uuid.uuidString == FlutterHelper.KosoWriteCharacteristicId }) else { return }

        readCharacteristic = readChar
        writeCharacteristic = writeChar

        // Listen Data
        peripheral.setNotifyValue(true, for: readCharacteristic!)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value,
           characteristic.uuid.uuidString == FlutterHelper.KosoReadCharacteristicId {
            if data.starts(with: GpsData80.DataBegin) && data.count == GpsData80.DataLength {
                sendIncomingInfo1(GpsData80(byCharacteristic: data))
            } else if data.starts(with: GpsData81.begin) && data.count == GpsData81.length {
                sendIncomingInfo2(GpsData81(byCharacteristic: data))
            } else {
                print(data.map { .init(format: "%02x", $0) }.joined(separator: " "))
            }
        }
    }
}
