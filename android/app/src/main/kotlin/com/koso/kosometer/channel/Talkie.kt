package com.koso.kosometer.channel

import android.annotation.SuppressLint
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Context.LOCATION_SERVICE
import android.content.Intent
import android.content.IntentFilter
import android.location.LocationManager
import android.os.Handler
import android.os.Looper
import android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS
import android.widget.Toast
import androidx.core.app.ActivityCompat.startActivityForResult
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.Observer
import com.google.gson.Gson
import com.koso.kosometer.ConnectError
import com.koso.kosometer.service.BlePeripheralService
import com.koso.rx5.core.Rx5ConnectionService
import com.koso.rx5.core.Rx5Device
import com.koso.rx5.core.Rx5Handler
import com.koso.rx5.core.command.incoming.BaseIncomingCommand
import com.koso.rx5.core.command.incoming.RuntimeInfo1Command
import com.koso.rx5.core.command.incoming.RuntimeInfo2Command
import com.koso.rx5.core.command.outgoing.NaviInfoCommand
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugin.common.MethodChannel

@SuppressLint("MissingPermission")
class Talkie private constructor(val context: Activity, engine: FlutterEngine) {
    private val CHANNEL_PATH = "com.koso.klink/bt"
    private var channel: MethodChannel
    private var state: Rx5Device.State = Rx5Device.State.Disconnected
    private var gson = Gson()
    private var device: BluetoothDevice? = null
    var bluetoothAdapter: BluetoothAdapter? = null
    private var isLe: Boolean = false

    //used for Le Scan
    private val mLeScanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult?) {
            super.onScanResult(callbackType, result)
            if(result != null) {
                val device = result.device
                if(possibleDevice(device)) {
                    candidates.add(hashMapOf("name" to device.name, "address" to device.address))
                }
            }
            sendScanResult(candidates)
        }
        override fun onBatchScanResults(results: MutableList<ScanResult>?) {
            super.onBatchScanResults(results)
            results?.forEach {
                val device = it.device
                if(possibleDevice(device)) {
                    candidates.add(hashMapOf("name" to device.name, "address" to device.address))
                }
            }
            sendScanResult(candidates)
        }

        override fun onScanFailed(errorCode: Int) {
            super.onScanFailed(errorCode)
        }
    }


    private val handler = MethodChannel.MethodCallHandler { call, result ->
        when (call.method) {
            "scan" -> {
                if(checkBluetoothAvailable()) {
                    startScan(bluetoothAdapter!!)
                    result.success(null)
                }else{
                    sendError(ConnectError.bt_fail)
                }
            }
            "lescan" -> {
                if(checkBluetoothAvailable()) {
                    startLeScan(bluetoothAdapter!!)
                    result.success(null)
                }else{
                    sendError(ConnectError.bt_fail)
                }
            }
            "stopscan" -> {
                if(bluetoothAdapter?.isDiscovering == true){
                    if(bluetoothAdapter?.isDiscovering == true) {
                        bluetoothAdapter?.cancelDiscovery()
                        bluetoothAdapter?.bluetoothLeScanner?.stopScan(mLeScanCallback)
                        sendState(Rx5Device.State.Disconnected)
                    }
                }
                result.success(null)
            }
            "connect" -> {
                isLe = false
                if(checkBluetoothAvailable()) {
                    val address = call.argument<String>("address")
                    if(address != null) {
                        if(bluetoothAdapter?.isDiscovering == true) {
                            bluetoothAdapter?.cancelDiscovery()
                            sendState(Rx5Device.State.Disconnected)
                        }
                        handleConnect(address)
                        result.success(null)
                    }
                }else{
                    sendError(ConnectError.bt_fail)
                }
            }
            "leconnect" -> {
                isLe = true
                if(checkBluetoothAvailable()) {
                    val address = call.argument<String>("address")
                    if(address != null) {
                        if(bluetoothAdapter?.isDiscovering == true){
                            bluetoothAdapter?.bluetoothLeScanner?.stopScan(mLeScanCallback)
                            sendState(Rx5Device.State.Disconnected)
                        }
                        handleLeConnect(address)
                        result.success(null)
                    }
                }else{
                    sendError(ConnectError.bt_fail)
                }
            }
            "disconnect" -> {
                receiveEnd()
                result.success(null)
            }
            "naviinfo" -> {
                val json = call.argument<String>("naviinfo")
                if (json != null) {
                    receiveNaviinfo(json)
                }
                result.success(null)
            }
            "whatstate" -> {
                result.success(state.name)
            }
            "update_navinotify" -> {
                val msg = call.argument<String>("msg")
                Rx5ConnectionService.updateNaviMessage(context, msg)
            }
            "dismiss_navinotify" -> {
                Rx5ConnectionService.dismissNaviMessage(context)
            }
            "start_ancs" -> {
                startAncs()
            }
            else -> {
                result.notImplemented()
            }
        }

    }

    fun startAncs() {
        val bluetoothManager: BluetoothManager =
            context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        if(!bluetoothManager.adapter.isEnabled){
            Toast.makeText(context,"bluetooth is not enable", Toast.LENGTH_SHORT).show()
            return
        }
        BlePeripheralService.launch(context)
    }

    private val candidates = mutableListOf<HashMap<String, String>>()

    // Create a BroadcastReceiver for ACTION_FOUND.
    private val receiver = object : BroadcastReceiver() {
        @SuppressLint("MissingPermission")
        override fun onReceive(context: Context, intent: Intent) {
            val action: String? = intent.action
            when (action) {
                BluetoothDevice.ACTION_FOUND -> {
                    val device: BluetoothDevice =
                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)!!
                    if (possibleDevice(device)) {
                        candidates.add(hashMapOf( "name" to device.name, "address" to device.address ))
                        sendScanResult(candidates)
                    }
                }
            }
        }
    }
    private val connectionStateObserver = Observer<Rx5Device.State> {
        sendState(it)
    }

    private val incomingCommandObserver = Observer<BaseIncomingCommand> {
        when(it){
            is RuntimeInfo1Command -> sendIncomingInfo1(it)
            is RuntimeInfo2Command -> sendIncomingInfo2(it)
        }
    }

    init {
        FlutterLoader().apply {
            startInitialization(context)
            ensureInitializationComplete(context, arrayOf())
        }
        channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL_PATH)
        channel.setMethodCallHandler(handler)

        val btMgr = context.getSystemService(BluetoothManager::class.java)
        bluetoothAdapter = btMgr.adapter
        val filter = IntentFilter(BluetoothDevice.ACTION_FOUND)
        context.registerReceiver(receiver, filter)
        Rx5Handler.STATE_LIVE.observe(context as LifecycleOwner, connectionStateObserver)
        Rx5Handler.incomingCommandLive().observe(context as LifecycleOwner, incomingCommandObserver)
        this.state = Rx5Handler.STATE_LIVE.value ?: Rx5Device.State.Disconnected
    }

    fun onDestory(){
        Rx5Handler.destory()
        BlePeripheralService.end(context)
        context.unregisterReceiver(receiver)
        _instance = null
    }

    private fun sendState(state: Rx5Device.State) {
        this.state = state
        channel.invokeMethod("state", state.name)
    }

    private fun sendScanResult(list: List<Map<String, String>>){
        channel.invokeMethod("scanresult", list)
    }

    private fun sendIncomingInfo1(cmd: BaseIncomingCommand) {
        val json = gson.toJson(cmd)
        channel.invokeMethod("incominginfo1", json)
    }

    private fun sendIncomingInfo2(cmd: BaseIncomingCommand) {
        val json = gson.toJson(cmd)
        channel.invokeMethod("incominginfo2", json)
    }

    private fun sendError(err: ConnectError) {
        channel.invokeMethod("error", err.name)
    }

    // handle start request
    private fun handleConnect(address: String) {
        Rx5Handler.startConnectService(context, address, 10)
    }

    private fun handleLeConnect(address: String) {
        Rx5Handler.startLeConnectService(context, address, 10)
    }

    private fun checkBluetoothAvailable(): Boolean {
        if (bluetoothAdapter == null) {
            sendError(ConnectError.bt_fail)
            return false
        }else if(!bluetoothAdapter!!.isEnabled){
            val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
            context.startActivityForResult(enableBtIntent, 100)
            return false
        }

        return true
    }

    @SuppressLint("MissingPermission")
    private fun possibleDevice(device: BluetoothDevice): Boolean {
        return device.name != null && device.name.contains("KOSO", ignoreCase = true)
    }

    @SuppressLint("MissingPermission")
    private fun startScan(bluetoothAdapter: BluetoothAdapter) {
        val locationManager: LocationManager? =
            context.getSystemService(LOCATION_SERVICE) as LocationManager?
        val isGpsEnabled: Boolean? =
            locationManager?.isProviderEnabled(LocationManager.GPS_PROVIDER)
        if (isGpsEnabled == false) {
            startActivityForResult(
                context,
                Intent(ACTION_LOCATION_SOURCE_SETTINGS), 200, null
            )
        } else {
            candidates.clear()
            sendScanResult(candidates)
            findPairedDevices()
            bluetoothAdapter.startDiscovery()
            sendState(Rx5Device.State.Discovering)
            Handler(Looper.getMainLooper()).postDelayed({
                if(bluetoothAdapter.isDiscovering) {
                    bluetoothAdapter.cancelDiscovery()
                    sendState(Rx5Device.State.Disconnected)
                }
            }, 6000)
        }
    }



    private fun startLeScan(bluetoothAdapter: BluetoothAdapter){
        val locationManager: LocationManager? =
            context.getSystemService(LOCATION_SERVICE) as LocationManager?
        val isGpsEnabled: Boolean? =
            locationManager?.isProviderEnabled(LocationManager.GPS_PROVIDER)
        if (isGpsEnabled == false) {
            startActivityForResult(
                context,
                Intent(ACTION_LOCATION_SOURCE_SETTINGS), 200, null
            )
        } else {
            candidates.clear()
            sendScanResult(candidates)
            findPairedDevices()

            bluetoothAdapter.bluetoothLeScanner.startScan(mLeScanCallback)
            sendState(Rx5Device.State.Discovering)
            Handler(Looper.getMainLooper()).postDelayed({
                if(bluetoothAdapter.isDiscovering) {
                    bluetoothAdapter.bluetoothLeScanner.stopScan(mLeScanCallback)
                    sendState(Rx5Device.State.Disconnected)
                }
            }, 6000)
        }
    }

    private fun findPairedDevices() {
        val pairedDevices: Set<BluetoothDevice>? = bluetoothAdapter!!.bondedDevices
        pairedDevices?.forEach { device ->
            if(possibleDevice(device)){
                val deviceName = device.name
                val deviceHardwareAddress = device.address // MAC address
                candidates.add(hashMapOf( "name" to deviceName, "address" to deviceHardwareAddress ))
            }
        }
        sendScanResult(candidates)
    }

    // handle end request
    private fun receiveEnd() {
//        Rx5Handler.stopConnectService(context)
        Rx5Handler.stopLeConnectService(context)
    }

    // handle naviinfo request
    private fun receiveNaviinfo(naviCmd: String) {
        val cmd = gson.fromJson(naviCmd, NaviInfoCommand::class.java)
        if(isLe){
            Rx5Handler.rx5?.writeLe(cmd)
        }else{
            Rx5Handler.rx5?.write(cmd)
        }

    }

    companion object {
        var _instance: Talkie? = null
        fun ofEngine(context: Activity, engine: FlutterEngine): Talkie {
            if(_instance == null) {
                _instance = Talkie(context, engine)
            }
            return _instance!!
        }
    }
}