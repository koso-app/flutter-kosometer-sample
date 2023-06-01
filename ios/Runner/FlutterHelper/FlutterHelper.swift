import CoreBluetooth
import Foundation

enum BtState: String {
    case Disconnected
    case Discovering
    case Connected
    case Connecting
}

class FlutterHelper: NSObject {
    // Flutter Channel
    static let FlutterChannelName = "com.koso.klink/bt"
    var flutterController: FlutterViewController?
    var flutterChannel: FlutterMethodChannel?

    // KOSO ID
    static let KosoNamePrefix = "KOSO"
    static let KosoServiceId = "D88B7688-729D-BDA1-7A46-25F4104626C7"
    static let KosoReadCharacteristicId = "39D7AFB7-4ED7-4334-D79B-6675D916D7E3"
    static let KosoWriteCharacteristicId = "40E288F6-B367-F64A-A5F7-B4DFEE9F09E7"

    // BlueTooth
    var btState: BtState = .Disconnected
    var centralManager: CBCentralManager!
    var availableDevices: [CBPeripheral] = []
    var connectedDevice: CBPeripheral?
    var readCharacteristic: CBCharacteristic?
    var writeCharacteristic: CBCharacteristic?

    init(app: FlutterAppDelegate) {
        super.init()

        centralManager = CBCentralManager(delegate: self, queue: nil)

        flutterController = app.window?.rootViewController as? FlutterViewController
        flutterChannel = FlutterMethodChannel(name: FlutterHelper.FlutterChannelName,
                                              binaryMessenger: flutterController!.binaryMessenger)
        flutterChannel?.setMethodCallHandler({ [weak self] (call: FlutterMethodCall,
                                                            result: @escaping FlutterResult) in
                guard let self else { return }

                if call.method == "scan" {
                    self.handleScan()
                    result(nil)
                } else if call.method == "stopscan" {
                    self.handleStopScan()
                    result(nil)
                } else if call.method == "connect" {
                    if let arg = call.arguments as? [String: Any],
                       let address = arg["address"] as? String {
                        self.handleConnect(address: address)
                    }
                    result(nil)
                } else if call.method == "disconnect" {
                    self.handleDisconnect()
                    result(nil)
                } else if call.method == "naviinfo" {
                    if let arg = call.arguments as? [String: Any],
                       let naviinfo = arg["naviinfo"] as? String,
                       let info = GpsCommand89(jsonString: naviinfo) {
                        self.handleNaviInfo(info)
                    }
                    result(nil)
                } else if call.method == "update_navinotify" {
                    if let arg = call.arguments as? [String: Any],
                       let msg = arg["msg"] as? String {
                        self.handleUpdateNaviNotify(message: msg)
                    }
                    result(nil)
                } else if call.method == "dismiss_navinotify" {
                    self.handleDismissNaviNotify()
                    result(nil)
                } else if call.method == "whatstate" {
                    self.handleWhatState(result: result)
                } else {
                    result(FlutterMethodNotImplemented)
                }
        })
    }
}
