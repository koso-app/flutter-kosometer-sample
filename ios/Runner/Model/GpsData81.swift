import Foundation

struct GpsData81: Equatable, Codable {
    static let begin: [UInt8] = [0xFF, 0x81]
    static let length: Int = 62

    /// 可設定總里程表 單位:m
    var odo: UInt32

    /// 不可調總里程(同原車總里程) 單位:m
    var odo_total: UInt32

    /// 總騎乘時間紀錄 , 單位:sec
    var rd_time: UInt32

    /// 平均速度 單位:km/h
    var average_speed: UInt16

    /// 平均油耗 km/L
    var average_consume: UInt16

    /// 單位:m
    var trip_1: UInt32

    /// 單位:sec
    var trip_1_time: UInt32

    /// 平均速度 單位:km/h
    var trip_1_average_speed: UInt16

    /// 平均油耗 km/L
    var trip_1_average_consume: UInt16

    /// 單位:m
    var trip_2: UInt32

    /// 單位:sec
    var trip_2_time: UInt32

    /// 平均速度 單位:km/h
    var trip_2_average_speed: UInt16

    /// 平均油耗 km/L
    var trip_2_average_consume: UInt16

    /// 自動騎乘時間A紀錄 單位:m
    var trip_a: UInt32

    /// 儀表總時間紀錄 單位:sec
    var al_time: UInt32

    /// 保養剩餘里程提醒
    var service_DST: UInt32

    /// 單位:km
    var fuel_range: UInt32

    /// Raw Data Length
    var length: Int = 56

    /// Raw Data
    var rawData: [UInt8]

    init(byCharacteristic data: Data) {
        odo = [data[6], data[5], data[4], data[3]].toUInt32()
        odo_total = [data[10], data[9], data[8], data[7]].toUInt32()
        rd_time = [data[14], data[13], data[12], data[11]].toUInt32()
        average_speed = [data[16], data[15]].toUInt16()
        average_consume = [data[18], data[17]].toUInt16()

        trip_1 = [data[22], data[21], data[20], data[19]].toUInt32()
        trip_1_time = [data[26], data[25], data[24], data[23]].toUInt32()
        trip_1_average_speed = [data[28], data[27]].toUInt16()
        trip_1_average_consume = [data[30], data[29]].toUInt16()

        trip_2 = [data[34], data[33], data[32], data[31]].toUInt32()
        trip_2_time = [data[38], data[37], data[36], data[35]].toUInt32()
        trip_2_average_speed = [data[40], data[39]].toUInt16()
        trip_2_average_consume = [data[42], data[41]].toUInt16()

        trip_a = [data[46], data[45], data[44], data[43]].toUInt32()
        al_time = [data[50], data[49], data[48], data[47]].toUInt32()
        service_DST = [data[54], data[53], data[52], data[51]].toUInt32()
        fuel_range = [data[58], data[57], data[56], data[55]].toUInt32()

        rawData = Array(data[3 ... 58])
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
