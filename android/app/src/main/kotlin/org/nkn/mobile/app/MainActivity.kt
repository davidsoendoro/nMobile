package org.nkn.mobile.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import org.nkn.mobile.channels.impl.Common

class MainActivity : FlutterActivity() {
    private val common: Common = Common()
    companion object {
        @Volatile
        lateinit var instance: MainActivity

    }

    init {
        instance = this
    }
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        common.install(flutterEngine.dartExecutor.binaryMessenger)
    }


}
