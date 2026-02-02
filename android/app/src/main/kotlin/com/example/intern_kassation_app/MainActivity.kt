package com.geisler.intern_kassation_app


import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {

    private val channelName = "com.geisler.intern_kassation_app/barcode"
    private var receiver: BarcodeReceiver? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    if (receiver == null) {
                        receiver = BarcodeReceiver { barcode ->
                            eventSink?.success(barcode)
                        }
                    }

                    val filter = IntentFilter().apply {
                        addAction("COM.DATALOGIC.ALADDINAPP.INTENT.ACTION_SEND_BAR_CODE_DATA")
                        addAction("com.geisler.intern_kassation_app.BARCODE") // DataWedge intent action
                    }
                    ContextCompat.registerReceiver(
                        this@MainActivity,
                        receiver,
                        filter,
                        ContextCompat.RECEIVER_EXPORTED
                    )
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    receiver?.let { unregisterReceiver(it) }
                }
            })
    }

    override fun onDestroy() {
        receiver?.let {
            try {
                unregisterReceiver(it)
            } catch (_: IllegalArgumentException) { }
        }
        receiver = null
        super.onDestroy()
    }
}

class BarcodeReceiver(
    private val onBarcode: (String) -> Unit
) : BroadcastReceiver() {

    override fun onReceive(ctx: Context, intent: Intent) {
        when (intent.action) {
            // Datalogic
            "COM.DATALOGIC.ALADDINAPP.INTENT.ACTION_SEND_BAR_CODE_DATA" -> {
                val barcode = intent.getStringExtra("COM.DATALOGIC.ALADDINAPP.EXTRA.BARCODE_DATA")
                if (!barcode.isNullOrBlank()) onBarcode(barcode)
            }

            // Zebra DataWedge
            "com.geisler.intern_kassation_app.BARCODE" -> {
                val barcode = intent.getStringExtra("com.symbol.datawedge.data_string")
                if (!barcode.isNullOrBlank()) onBarcode(barcode)
            }
        }
    }
}