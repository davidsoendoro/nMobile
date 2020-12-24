class Common : ChannelBase, IChannelHandler, FlutterStreamHandler {

    var methodChannel: FlutterMethodChannel?
    var eventSink: FlutterEventSink?
    let CHANNEL_NAME = "org.nkn.nmobile/native/common"
    
    func install(binaryMessenger: FlutterBinaryMessenger) {
        self.methodChannel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: binaryMessenger)
        self.methodChannel?.setMethodCallHandler(handle)
    }
    
    func uninstall() {
        self.methodChannel?.setMethodCallHandler(nil)
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method{
        case "backDesktop":
            backDesktop(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func backDesktop(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
       
        result(true)
    }
    
}
