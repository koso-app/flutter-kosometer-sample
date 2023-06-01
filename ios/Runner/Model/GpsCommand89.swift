import Foundation

struct GpsCommand89 {
    static let begin: [UInt8] = [0xFF, 0x89]
    static let end: [UInt8] = [0xFF, 0x34]

    /// navimode  =0導航模式,=1導航模擬,=2瀏覽模式,=3導航模擬暫停瀏覽模式,=4導航暫時瀏覽模式，目前只實作０
    var navimode: Int32

    /// [24] 縣市行政區
    var ctname: String

    /// [64] 目前道路名稱
    var roadname: String

    /// [24] 數字字碼或中文字碼
    var doornum: String

    /// 目前道路速限 單位 : 公里
    var limitsp: Int32

    /// [64] 下條轉彎道路名稱
    var nextroadname: String

    /// 下條轉彎道路距離 單位 : 公尺
    var nextdist: Int32

    /// 下條轉彎方向
    var nextturn: Int32

    /// 測試照相警示 : 前方是否有測試照相, 0表無測速照相,1表有測速照相,大於1表測速照相距離
    var camera: Int32

    /// 路徑距離總長 單位:公尺
    var navidist: Int32

    /// 導航所需時間 單位:分
    var navitime: Int32

    /// GPS 可用衛星(ACTIVE)數
    var gpsnum: Int32

    /// int 朝向
    var gpsdir: Int32

    var data: [UInt8] {
        var value = [UInt8]()

        value.append(contentsOf: byteArrayLittle(from: navimode))
        value.append(contentsOf: getStringData(value: ctname, length: 24))
        value.append(contentsOf: getStringData(value: roadname, length: 64))
        value.append(contentsOf: getStringData(value: doornum, length: 24))
        value.append(contentsOf: byteArrayLittle(from: limitsp))
        value.append(contentsOf: getStringData(value: nextroadname, length: 64))
        value.append(contentsOf: byteArrayLittle(from: nextdist))
        value.append(contentsOf: byteArrayLittle(from: nextturn))
        value.append(contentsOf: byteArrayLittle(from: camera))
        value.append(contentsOf: byteArrayLittle(from: navidist))
        value.append(contentsOf: byteArrayLittle(from: navitime))
        value.append(contentsOf: byteArrayLittle(from: gpsnum))
        value.append(contentsOf: byteArrayLittle(from: gpsdir))

        return value
    }

    var checksum: [UInt8] {
        var value: UInt8 = 0x00
        for byte in data {
            value ^= byte
        }
        return [value]
    }

    init?(jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            return nil
        }

        navimode = json["navimode"] as? Int32 ?? 0
        ctname = json["ctname"] as? String ?? ""
        roadname = json["roadname"] as? String ?? ""
        doornum = json["doornum"] as? String ?? ""
        limitsp = json["limitsp"] as? Int32 ?? -1
        nextroadname = json["nextroadname"] as? String ?? ""
        nextdist = json["nextdist"] as? Int32 ?? 0
        nextturn = json["nextturn"] as? Int32 ?? 0
        camera = json["camera"] as? Int32 ?? 0
        navidist = json["navidist"] as? Int32 ?? 0
        navitime = json["navitime"] as? Int32 ?? 0
        gpsnum = json["gpsnum"] as? Int32 ?? 0
        gpsdir = json["gpsdir"] as? Int32 ?? 0
    }

    func getData() -> Data {
        return Data(GpsCommand89.begin + [UInt8(data.count)] + data + checksum + GpsCommand89.end)
    }

    private func getStringData(value: String, length: Int) -> [UInt8] {
        var data: [UInt8] = Array(value.utf8)

        if data.count > length {
            data = Array(data[0 ..< length])
        } else {
            data.append(contentsOf: Array(repeating: UInt8(), count: length - data.count))
        }

        return data
    }
}
