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
var notificationarray = [NotificationModel]()

var pendingToOpen : NotificationModel!
func gotoNotification(_ not: NotificationModel) -> Void {
    let array = not.mydata.components(separatedBy: ",").map({ (val) -> Int in
        return Int(val) ?? -1
    })
    
    if array.count == 3 {
        var enterprise: Business!
        var user: User!
        var week: Week!
        store.state.businessState.getEnterprise(id: array[0], handler: { (bussines) in
            enterprise = bussines
            user = enterprise.users.first(where: {$0.id == array[1]})
            week = store.state.weekState.getWeeks().first(where: {$0.id == array[2]})
            let pending = pendingModel(enterprise: enterprise, users: [modelUser(user: user, weeks: [week])], weeks: [modelWeek(week: week, users: [user])], toggle: false)
            if let top =  UIApplication.topViewController() {
                top.pushToView(view: .allPendings, sender: [pending])
            }
        })
       
    }else{
        if let message = realm.realm.object(ofType: MessageEntitie.self, forPrimaryKey: array[0]) {
            if let group = realm.realm.object(ofType: Group.self, forPrimaryKey: message.groupId) {
                let conf = configuration(uid: message.userId, wid: message.weekId, type: TYPE_ON_REPORT(rawValue: group.type), eid: group.companyId, report: nil, user: nil)
                if let top =  UIApplication.topViewController() {
                    top.pushToView(view: .chatView,  sender: conf)
                }
            }
        }
    }
}


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
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            
            application.registerUserNotificationSettings(settings)
        }
        
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            // 2
            let notification = NotificationModel(dic: notification)
            notificationarray.append(notification)
            pendingToOpen = notification
            
        }
       UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: { (notifications) in
            notifications.enumerated().forEach({ (index, notification) in
                
                let not = NotificationModel(notifiaction: notification)
                notificationarray.append(not)
            })
        })
        realm.saveObjects(objs: notificationarray)
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UISearchBar.appearance().barTintColor = #colorLiteral(red: 0.07843137255, green: 0.1019607843, blue: 0.1647058824, alpha: 1)
        UISearchBar.appearance().tintColor = .white
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = #colorLiteral(red: 0.07843137255, green: 0.1019607843, blue: 0.1647058824, alpha: 1)
        
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if pendingToOpen == nil {
            let not = NotificationModel(notifiaction: response.notification)
            realm.save(objs: not)
            gotoNotification(not)
        }
        
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let not = NotificationModel(dic: userInfo)
        realm.save(objs: not)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([UNNotificationPresentationOptions.alert,UNNotificationPresentationOptions.sound,UNNotificationPresentationOptions.badge])
        let not = NotificationModel(notifiaction: notification)
        realm.save(objs: not)
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
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

