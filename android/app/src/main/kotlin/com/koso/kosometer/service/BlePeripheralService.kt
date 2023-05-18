package com.koso.kosometer.service

import android.app.*
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.IBinder
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import com.koso.kosometer.ble.AncsPeripheral
import com.koso.kosometer.ble.Utils
import com.koso.kosometer.R
import com.koso.kosometer.MainActivity
import com.koso.kosometer.ble.BatteryPeripheral


class BlePeripheralService : NotificationListenerService() {
    private val ACTION_STOP = "stop"
    private var ancsPeripheral: AncsPeripheral? = null
    private var batteryPeripheral: BatteryPeripheral? = null

    companion object {
        fun launch(context: Context) {
            context.startService(Intent(context, BlePeripheralService::class.java))
        }

        fun end(context: Context) {
            context.stopService(Intent(context, BlePeripheralService::class.java))
        }
    }

    override fun onBind(intent: Intent?): IBinder? {
        return super.onBind(intent)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopSelf()
        } else {
            if (ancsPeripheral == null) {
                initPeripheral()
                registerBatteryLevel()
            }
        }
        super.onStartCommand(intent, flags, startId)
        return START_STICKY

    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        val notification = sbn?.notification
        val title: String? = notification?.extras?.getString("android.title")
        val text: String? = notification?.extras?.getString("android.text")
        if (notification != null) {
            when (notification.category) {
                Notification.CATEGORY_CALL -> {
                    ancsPeripheral?.postAncsNotification(
                        AncsPeripheral.ANCS_EVENT_ADDED,
                        AncsPeripheral.ANCS_CATEGORY_INCOMING_CALL,
                        title ?: "",
                        title ?: "",
                        text ?: ""
                    )
                }
                Notification.CATEGORY_MISSED_CALL -> {
                    ancsPeripheral?.postAncsNotification(
                        AncsPeripheral.ANCS_EVENT_REMOVED,
                        AncsPeripheral.ANCS_CATEGORY_INCOMING_CALL,
                        title ?: "",
                        title ?: "",
                        text ?: ""
                    )
                }
                else -> {
                    ancsPeripheral?.postAncsNotification(
                        AncsPeripheral.ANCS_EVENT_ADDED,
                        AncsPeripheral.ANCS_CATEGORY_SOCIAL_EVENT,
                        title ?: "",
                        text ?: "",
                        text?:""
                    )
                }
            }
            Log.d("ancs", "onNotificationPosted: ${notification.category}, $title, $text")

        } else {
            Log.d("xunqun", "onNotificationPosted: but not show")
        }
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.d("xunqun", "onListenerConnected: ")
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        Log.d("xunqun", "onListenerConnected: ")
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        ancsPeripheral?.endPeripheral()
        ancsPeripheral = null

        batteryPeripheral?.endPeripheral()
        batteryPeripheral = null
    }

    override fun onDestroy() {
        super.onDestroy()
        ancsPeripheral?.endPeripheral()
        ancsPeripheral = null

        batteryPeripheral?.endPeripheral()
        batteryPeripheral = null
        unregisterBatteryLevel()
    }

    private fun initPeripheral() {

        if (Utils.checkBlePermissions(this)) {
            try {
                ancsPeripheral = AncsPeripheral(this)
                ancsPeripheral!!.startPeripheral()

                batteryPeripheral = BatteryPeripheral(this)
                batteryPeripheral!!.startPeripheral()

                foregroundNotify()
            } catch (e: Exception) {
                e.printStackTrace()
                stopSelf()
            }
        } else {
            stopSelf()
        }

    }

    val batteryObserver = object: BroadcastReceiver(){
        override fun onReceive(context: Context?, intent: Intent?) {
            val status: Int = intent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
            val isCharging: Boolean = status == BatteryManager.BATTERY_STATUS_CHARGING
                    || status == BatteryManager.BATTERY_STATUS_FULL

            // How are we charging?
            val level: Int = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1

            batteryPeripheral?.postBatteryLevel(level)

        }

    }

    private fun registerBatteryLevel(){
        IntentFilter(Intent.ACTION_BATTERY_CHANGED).let { ifilter ->
            registerReceiver(batteryObserver, ifilter)
        }
    }

    private fun unregisterBatteryLevel(){
        unregisterReceiver(batteryObserver)
    }

    private fun foregroundNotify() {
        val manager: NotificationManager = getSystemService(NotificationManager::class.java)
        val c = manager.getNotificationChannel("ancs_peripheral")
        if (c == null) {
            val channel1 = NotificationChannel(
                "ancs_peripheral",
                "ancs_peripheral",
                NotificationManager.IMPORTANCE_LOW
            )
            channel1.setDescription("ANCS peripheral")
            manager.createNotificationChannel(channel1)
        }

        val pendingIntent: PendingIntent =
            Intent(this, MainActivity::class.java).let { notificationIntent ->
                PendingIntent.getActivity(
                    this, 0, notificationIntent,
                    PendingIntent.FLAG_IMMUTABLE
                )
            }
        val stopIntent: PendingIntent = Intent(this, BlePeripheralService::class.java).let {
            it.action = ACTION_STOP
            PendingIntent.getService(this, 1, it, PendingIntent.FLAG_IMMUTABLE)
        }

        val notification: Notification = Notification.Builder(this, "ancs_peripheral")
            .setContentTitle("ANCS peripheral service")
            .setContentText("To providing phone data through BLE")
            .setSmallIcon(R.drawable.ic_baseline_media_bluetooth_on_24)
            .setContentIntent(pendingIntent)
            .setTicker("this is ticker text")
            .setActions(Notification.Action(R.drawable.ic_baseline_close_24, "close", stopIntent))
            .build()

        // Notification ID cannot be 0.
        startForeground(3210, notification)
        Log.d("xunqun", "start foregroundNotify ")

    }
}