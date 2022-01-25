
//  AppDelegate.swift
//  newsReader
//
//  Created by Ivan Karpovich on 7.01.22.


import UIKit
import Firebase
import FBSDKCoreKit
import UserNotifications


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
   
    let window: UIWindow? = nil// = UIWindow(frame: UIScreen.main.bounds)
    var view: UIViewController?
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
   
    let notificationCenter = UNUserNotificationCenter.current()
    

    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]){(granted, error)
            in
            
            guard granted else {return}
            self.notificationCenter.getNotificationSettings {
                (settings) in print(settings)
        
                guard settings.authorizationStatus == .authorized else {return}
            }
        }
        

        notificationCenter.delegate = self
        sendNotifications(identifier: "numberOne", title: "News Reader1",body: "GO check morning new NEWS !!!!!",hour: 8,minute: 0)
        sendNotifications(identifier: "numberTwo", title: "News Reader2",body: "GO check evening new NEWS !!!!!",hour: 19,minute: 0)

        FirebaseApp.configure()
        var title = ""
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "id-\(title)",
          AnalyticsParameterItemName: title,
          AnalyticsParameterContentType: "cont",
        ])
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
//        Auth.auth().addStateDidChangeListener{(auth, user) in
//            print("In FUNC")
//            print(user)
//            if user == nil{
//                print("not error")
//                self.window?.rootViewController = AuthViewController()
//
//                
//                // self.showModalAuth()
//            }}

        return true
    }
    
    func sendNotifications(identifier:String,title:String, body:String, hour: Int , minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title//"News Reader"
        content.body = body//"GO check new NEWS !!!!!1"
        content.sound = UNNotificationSound.default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour //1
        dateComponents.minute = minute// 24
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 40, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificationCenter.add(request) {(error) in
            print(error?.localizedDescription)
        }
         
        print("end")
    }
    
    func showModalAuth() {
        print("show 1")
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let newvc = storyboard.instantiateViewController(withIdentifier: "auth") as! AuthViewController
////        self.window?.rootViewController?.present(newvc,animated: true , completion: nil)
//        let window1 = self.window
//        let rootViewController1 = window1.rootViewController
//        rootViewController1?.present(newvc,animated: true , completion: nil)
//
        


        
        print("show 1")

    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

extension AppDelegate: UNUserNotificationCenterDelegate{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print()
    }
    
}

// Swift
//
// AppDelegate.swift
