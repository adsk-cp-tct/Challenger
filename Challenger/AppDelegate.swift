import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var tabView: ChallengerTabViewController?
    var tableView: EventTableViewController?

    // Getting the device token
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        var characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        
        var deviceTokenString: String = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        
        User.currentUser.deviceToken = deviceTokenString
        if (User.currentUser.userId != nil) {
            Utilities.postDeviceToken(User.currentUser.userId!, deviceToken: deviceTokenString)
        }
    }
    
    // App Fail To Register For Remote Notifications
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println( error.localizedDescription )
    }
    
    // App Register For Remote Notifications
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
            let a = Utilities.getStringValue(remoteNotification, forKey: "eventId", withDefault: "0")
        }
        
        // Register for Push Notitications, if running iOS 8
        if UIApplication.sharedApplication().respondsToSelector("registerUserNotificationSettings:") {
            
            let types:UIUserNotificationType = (.Alert | .Badge | .Sound)
            let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
            
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
            
        } else {
            // Register for Push Notifications before iOS 8
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(.Alert | .Badge | .Sound)
        }
        
        return true
    }
    
    // Handle Remote Notification
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if let eventType = userInfo["eventType"] as? String {
            switch eventType {
                case "new-event", "user-selected":
                    if let eventId = userInfo["eventId"] as? String {
                        var rootViewController = self.window!.rootViewController
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        tabView?.selectedIndex = 0
                        
                        var eventDetailCtrl = EventDetailViewController(nibName: "EventDetailViewController", bundle: nil)
                        eventDetailCtrl.loadEvent(eventId)
                        eventDetailCtrl.hidesBottomBarWhenPushed = true
                        tableView?.navigationController?.pushViewController(eventDetailCtrl, animated: true)
                    }
                default:
                    println("\(eventType) is not supported.")
            }
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        // Clean up badge number when app entering foreground
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

