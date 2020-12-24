package org.nkn.mobile.app

import io.flutter.app.FlutterApplication

class App : FlutterApplication() {
    companion object {
        @Volatile
        lateinit var instance: App
    }

    init {
        instance = this
    }
}