//
//  AppDelegate.swift
//  dees
//
//  Created by Leonardo Durazo on 04/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import UserNotifications
let defaults = UserDefaults.standard
import RealmSwift
let store = Store<AppState>(
    reducer: AppReducer().handleAction,
    state: nil)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
 

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        var config = Realm.Configuration()
//        config.deleteRealmIfMigrationNeeded = true
        
        if #available(iOS 8.0, *){
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
            }
            application.registerForRemoteNotifications()
        
        }
        application.registerForRemoteNotifications()
        UIApplication.shared.statusBarStyle = .lightContent
        
        
        UISearchBar.appearance().barTintColor = #colorLiteral(red: 0.07843137255, green: 0.1019607843, blue: 0.1647058824, alpha: 1)
        UISearchBar.appearance().tintColor = .white
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = #colorLiteral(red: 0.07843137255, green: 0.1019607843, blue: 0.1647058824, alpha: 1)
        
        return true
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let data : NSDictionary = userInfo["aps"] as? NSDictionary {
            if let alert = data["alert"] as? NSDictionary {
                if let lockey = alert["loc-key"] as? NSArray {
                    let state: UIApplicationState = UIApplication.shared.applicationState // or use  let state =  UIApplication.sharedApplication().applicationState
                    
                  if state == .inactive {
                         defaults.set(lockey[1], forKey: "Notification-Chat")
                        if let user =  store.state.userState.user, let gid = Int((defaults.value(forKey: "Notification-Chat") as? String)!)  {
                            
                            store.dispatch(GroupsAction.GroupIn(gid: gid, eid: user.bussiness[0].id))
                        }
                    }
                    
                }
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        defaults.set(deviceTokenString, forKey: "device")
        print("-------------------------")
        print("DEVICE TOKEN: ",deviceTokenString)
        guard let email = defaults.value(forKey: "email") else{
            return
        }
        guard let pass = defaults.value(forKey: "password") else{
            return 
        }
        store.dispatch(AuthActions.LogIn(password: pass as! String, email: email as! String))
        
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("i am not available in simulator \(error)")
        
    }


}

