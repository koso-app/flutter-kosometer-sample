import Foundation

struct GpsData80: Equatable, Codable {
    static let DataBegin: [UInt8] = [0xFF, 0x80]
    static let DataLength: Int = 16

    /// 單位:km/h
    var speed: UInt16

    /// 單位:r/min
    var rpm: UInt16

    /// 電瓶電壓 (單位 0.1V)
    var batt_vc: UInt16

    /// 目前油耗 L/H
    var consume: UInt16

    /// 檔位
    var gear: UInt8

    /// Fuel Level (格數:bit0~6 , 警告bit7)
    var fuel: UInt8

    /// Raw Data Length
    var length: Int = 10

    /// Raw Data
    var rawData: [UInt8]

    // ff 80 0a - 00 00 00 00 77 00 00 00 00 00 - 77 - ff 2b
    // 16 bytes

    init(byCharacteristic data: Data) {
        speed = [data[4], data[3]].toUInt16()
        rpm = [data[6], data[5]].toUInt16()
        batt_vc = [data[8], data[7]].toUInt16()
        consume = [data[10], data[9]].toUInt16()
        gear = data[11]
        fuel = data[12]

        rawData = Array(data[3 ... 12])
    }

    func toJsonString() -> String {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(self) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        }

        return "{}"
    }
}
