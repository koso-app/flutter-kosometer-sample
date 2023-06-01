import Foundation

extension FlutterHelper {
    func setAndSendState(_ state: BtState) {
        btState = state
        flutterChannel?.invokeMethod("state", arguments: btState.rawValue)
        print("STATE: \(btState)")
    }

    func sendScanResult(_ result: [(name: String, address: String)]) {
        flutterChannel?.invokeMethod("scanresult", arguments: result.map { ["name": $0.name, "address": $0.address] })
    }

    func sendIncomingInfo1(_ data: GpsData80) {
        flutterChannel?.invokeMethod("incominginfo1", arguments: data.toJsonString())
    }

    func sendIncomingInfo2(_ data: GpsData81) {
        flutterChannel?.invokeMethod("incominginfo2", arguments: data.toJsonString())
    }

    func sendError(_ error: String) {
        flutterChannel?.invokeMethod("error", arguments: error)
    }
}
