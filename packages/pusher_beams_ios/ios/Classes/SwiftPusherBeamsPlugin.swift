import Flutter
import UIKit
import PushNotifications

public class SwiftPusherBeamsPlugin: FlutterPluginAppLifeCycleDelegate, FlutterPlugin, PusherBeamsApi, InterestsChangedDelegate {
    
    static var callbackHandler : CallbackHandlerApi? = nil
    
    var interestsDidChangeCallback : String? = nil
    var messageDidReceiveInTheForegroundCallback : String? = nil
    var onNotificationTappedCallback : String? = nil
    
    var beamsClient : PushNotifications?
    var started : Bool = false
    var deviceToken : Data? = nil
    var data: [String: NSObject]?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger : FlutterBinaryMessenger = registrar.messenger()
        let instance : SwiftPusherBeamsPlugin = SwiftPusherBeamsPlugin()
      
        callbackHandler = CallbackHandlerApi(binaryMessenger: messenger)
        PusherBeamsApiSetup(messenger, instance)
        
        UNUserNotificationCenter.current().delegate = instance
        registrar.addApplicationDelegate(instance)
    }
    
    override public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if(started) {
            beamsClient?.registerDeviceToken(deviceToken)
            print("SwiftPusherBeamsPlugin: registerDeviceToken with token: \(String(describing: deviceToken))")

        } else {
            self.deviceToken = deviceToken
        }
    }

    @nonobjc public override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("application.didReceiveRemoteNotification: \(userInfo)")
        beamsClient?.handleNotification(userInfo: userInfo)
    }

public override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any] = [:]) -> Bool {
    print("SwiftPusherBeamsPlugin: didFinishLaunchingWithOptions with options: \(String(describing: launchOptions))")
    
    if launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] != nil {
        let remoteNotif = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as! [String: Any]
        print("SwiftPusherBeamsPlugin: remoteNotif: \(remoteNotif)")
        
        // Store the complete notification data for getInitialMessage
        var completeData: [String: NSObject] = [:]
        
        // Add basic notification content if available
        if let aps = remoteNotif["aps"] as? [String: Any] {
            if let alert = aps["alert"] as? [String: Any] {
                completeData["title"] = alert["title"] as? NSObject
                completeData["body"] = alert["body"] as? NSObject
            } else if let alertString = aps["alert"] as? String {
                completeData["body"] = alertString as NSObject
            }
        }
        
        // Include all custom data
        if let customData = remoteNotif["data"] as? [String: Any] {
            for (key, value) in customData {
                if let nsObjectValue = value as? NSObject {
                    completeData[key] = nsObjectValue
                }
            }
        }
        
        // Include any other top-level keys
        for (key, value) in remoteNotif {
            if key != "aps" && key != "data", let nsObjectValue = value as? NSObject {
                completeData[key] = nsObjectValue
            }
        }
        
        data = completeData
        print("SwiftPusherBeamsPlugin: got initial data: \(String(describing: data))")
    } else {
        data = nil
    }
                    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
}
    
    public func startInstanceId(_ instanceId: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        beamsClient = PushNotifications(instanceId: instanceId)
        beamsClient?.delegate = self
        beamsClient?.start()

        if(deviceToken != nil) {
            beamsClient?.registerDeviceToken(deviceToken!)
            print("SwiftPusherBeamsPlugin: registerDeviceToken with token: \(String(describing: deviceToken))")
            deviceToken = nil
        }
        started = true

        beamsClient?.registerForRemoteNotifications()
    }

    public func addDeviceInterestInterest(_ interest: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        try? beamsClient!.addDeviceInterest(interest: interest)
    }

    public func removeDeviceInterestInterest(_ interest: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        try? beamsClient!.removeDeviceInterest(interest: interest)
    }
    
    public func getInitialMessage(completion: @escaping ([String : NSObject]?, FlutterError?) -> Void) {
        completion(data, nil)
    }

    public func getDeviceInterestsWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> [String]? {
        return beamsClient!.getDeviceInterests()
    }

    public func setDeviceInterestsInterests(_ interests: [String], error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        try? beamsClient!.setDeviceInterests(interests: interests)
    }

    public func clearDeviceInterestsWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        try? beamsClient!.clearDeviceInterests()
    }
    
    public func interestsSetOnDeviceDidChange(interests: [String]) {
        if (interestsDidChangeCallback != nil && (SwiftPusherBeamsPlugin.callbackHandler != nil)) {
            SwiftPusherBeamsPlugin.callbackHandler?.handleCallbackCallbackId(interestsDidChangeCallback!, callbackName: "onInterestChanges", args: [interests], completion: {_ in
                print("SwiftPusherBeamsPlugin: interests changed: \(interests)")
            })
        }
    }

    public func onInterestChangesCallbackId(_ callbackId: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        interestsDidChangeCallback = callbackId
    }

    public func setUserIdUserId(_ userId: String, provider: BeamsAuthProvider, callbackId: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        let tokenProvider = BeamsTokenProvider(authURL: provider.authUrl!) { () -> AuthData in
            let headers = provider.headers ?? [:]
            let queryParams: [String: String] = provider.queryParams ?? [:]
            return AuthData(headers: headers, queryParams: queryParams)
        }
        
        beamsClient!.setUserId(userId, tokenProvider: tokenProvider, completion: { error in
            guard error == nil else {
                SwiftPusherBeamsPlugin.callbackHandler?.handleCallbackCallbackId(callbackId, callbackName: "setUserId", args: [error.debugDescription], completion: {_ in
                  print("SwiftPusherBeamsPlugin: callback \(callbackId) handled with error")
                })
                return
            }

            SwiftPusherBeamsPlugin.callbackHandler?.handleCallbackCallbackId(callbackId, callbackName: "setUserId", args: [], completion: {_ in
                print("SwiftPusherBeamsPlugin: callback \(callbackId) handled")
            })
        })
    }

    public func clearAllStateWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        beamsClient!.clearAllState {
            print("SwiftPusherBeamsPlugin: state cleared")
        }
    }

    public func stopWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        beamsClient!.stop {
            print("SwiftPusherBeamsPlugin: stopped")
        }
        started = false
    }
    
    public func onMessageReceived(inTheForegroundCallbackId callbackId: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        messageDidReceiveInTheForegroundCallback = callbackId
    }
    
    public func onNotificationTappedCallbackId(_ callbackId: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        print("SwiftPusherBeamsPlugin: Setting up notification tap listener with callback ID: \(callbackId)")
        onNotificationTappedCallback = callbackId
    }
    
    public override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if (messageDidReceiveInTheForegroundCallback != nil && SwiftPusherBeamsPlugin.callbackHandler != nil) {
            let pusherMessage: [String : Any] = [
                "title": notification.request.content.title,
                "body": notification.request.content.body,
                "data": notification.request.content.userInfo["data"]
            ]
            
            SwiftPusherBeamsPlugin.callbackHandler?.handleCallbackCallbackId(messageDidReceiveInTheForegroundCallback!, callbackName: "onMessageReceivedInTheForeground", args: [pusherMessage], completion: {_ in
                print("SwiftPusherBeamsPlugin: message received: \(pusherMessage)")
            })
        }
    }

    public override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("SwiftPusherBeamsPlugin: Notification tapped with response: \(response)")
        
        if let callbackId = onNotificationTappedCallback, let callbackHandler = SwiftPusherBeamsPlugin.callbackHandler {
            let userInfo = response.notification.request.content.userInfo
            print("SwiftPusherBeamsPlugin: Processing notification tap with userInfo: \(userInfo)")
            
            // Create the complete notification data structure
            var notificationData: [String: Any] = [:]
            
            // Include basic notification content
            notificationData["title"] = response.notification.request.content.title
            notificationData["body"] = response.notification.request.content.body
            
            // Include ALL userInfo data (this includes your custom data + pusher data)
            if let data = userInfo["data"] as? [String: Any] {
                // Merge all data from userInfo["data"]
                notificationData.merge(data) { current, _ in current }
            }
            
            for (key, value) in userInfo {
                if let stringKey = key as? String, stringKey != "data" {
                    notificationData[stringKey] = value
                }
            }
            
            print("SwiftPusherBeamsPlugin: Sending notification tap callback with data: \(notificationData)")
            
            callbackHandler.handleCallbackCallbackId(callbackId, callbackName: "onNotificationTapped", args: [notificationData], completion: { _ in
                print("SwiftPusherBeamsPlugin: Notification tap callback completed")
                completionHandler()
            })
        } else {
            print("SwiftPusherBeamsPlugin: No notification tap callback registered, ignoring tap")
            completionHandler()
        }
    }
}