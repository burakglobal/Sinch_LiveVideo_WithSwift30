
import UIKit
import FBSDKCoreKit
import UserNotifications
import PushKit
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate,SINClientDelegate,SINCallDelegate,SINAudioControllerDelegate,SINManagedPushDelegate {
   
    var settings = GlobalViewController()
      var window: UIWindow?
    
    
    
    
    // Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
                
        // Print it to console
        print("APNs device token: \(deviceTokenString)")
        settings.saveDefaults(deger: deviceTokenString, isim: "token")
        push?.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
 
    }
    
    // Called when APNs failed to register the device for push notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Print the error to console (you should alert the user that registration failed)
        print("APNs registration failed: \(error)")
    }
    
    // Push notification received
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        push?.application(application, didReceiveRemoteNotification: userInfo)
 
    }
   
    func initSinchClient() {
        
        let getid = settings.getDefaults(isim: "facebookID")
        print(getid)
        _client = Sinch.client(withApplicationKey: "f5020732-b481-44d8-8ac5-4c0aad50a554", applicationSecret: "hjQQdhkU+EqTDA1120GHyg==", environmentHost: "clientapi.sinch.com", userId: getid)
        _client?.enableManagedPushNotifications()

        _client?.delegate = self
        _client?.audioController().delegate = self
        _client?.setSupportCalling(true)
        _client?.start()
        _client?.startListeningOnActiveConnection()
        _client?.setPushNotificationDisplayName(settings.getDefaults(isim: "facebookName"))
        
        
    }
    func managedPush(_ unused: SINManagedPush, didReceiveIncomingPushWithPayload payload: [AnyHashable: Any], forType pushType: String) {
              _client?.relayRemotePushNotification(payload)
        
    }
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        if notification.sin_isIncomingCall() {
            // This will trigger -[SINClientDelegate didReceiveIncomingCall:] if the notification
            // represents a call (i.e. contrast to that it may represent an instant-message)
            let result: SINNotificationResult = _client!.relay(notification)
            if result.isCall() && result.call().isTimedOut {
                // The notification is related to an incoming call,
                // but was too old and the call has expired.
                // The call should be treated as a missed call and appropriate
                // action should be taken to communicate that to the user.
            }
        }
    }
    func client(_ client: SINClient, localNotificationForIncomingCall call: SINCall) -> SINLocalNotification {
        var notification = SINLocalNotification()
        notification.alertAction = "Answer"
        notification.alertBody = "Incoming call\(call.remoteUserId)"
        return notification
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // iOS 10 support
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        }
            // iOS 9 support
        else if #available(iOS 9, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 8 support
        else if #available(iOS 8, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 7 support
        else {
            application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }

        push = Sinch.managedPush(with: SINAPSEnvironment.production)
        push?.delegate = self
        push?.setDesiredPushTypeAutomatically()
        push?.registerUserNotificationSettings()

        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return handled
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        settings.updateonline(status: "0")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closecall"), object: nil)
        print(settings.getDefaults(isim: "facebookID"))
        if settings.getDefaults(isim: "facebookID") != "" {
         durationTimerx.invalidate()
        }

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.shared.applicationIconBadgeNumber = 0
        settings.loginToServer()
        settings.updateonline(status: "1")

    }

    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        settings.updateonline(status: "0")
        _client?.unregisterPushNotificationDeviceToken()
        _client?.stop()
        _client = nil
        _call = nil
        print("kapatildi")
    }

    
    
    func clientDidStop(_ client: SINClient!) {
        print("client stop")
        
    }
    func clientDidFail(_ client: SINClient!, error: Error!) {
        print("sinch fail" + error.localizedDescription)
        
    }
    func clientDidStart(_ client: SINClient!) {
        print("sinch start)")
        
    }
    func  callDidEstablish(_ call: SINCall!) {
        print("callestanblished")
    }
    func callDidEnd(_ call: SINCall!) {
        print("call end")
    }
    func callDidProgress(_ call: SINCall!) {
    
    }
    func call(_ call: SINCall!, shouldSendPushNotifications pushPairs: [Any]!) {


        print(pushPairs)
    }
  
    
    
    
                    
}
