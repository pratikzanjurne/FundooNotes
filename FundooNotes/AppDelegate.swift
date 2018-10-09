import UIKit
import CoreData
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import UserNotifications
 
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?
    static var center = UNUserNotificationCenter.current()
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if UserDefaults.standard.object(forKey: "userEmail") != nil{
            self.loginUser()
        }else{
        }
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        let options: UNAuthorizationOptions = [.alert,.sound]
        AppDelegate.center.requestAuthorization(options: options) { (granted, error) in
            if !granted{
            }
        }
        AppDelegate.center.getNotificationSettings { (setting) in
            if setting.authorizationStatus != .authorized{
                
            }
        }
        AppDelegate.center.delegate = self
        return true
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let stroryBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = stroryBoard.instantiateViewController(withIdentifier: "DashboardContainerViewController") as! DashboardContainerViewController
        vc.isNotificationTriggered = true
        vc.notificationNoteId = response.notification.request.identifier
        window?.rootViewController = vc
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    func loginUser(){
        let stroryBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = stroryBoard.instantiateViewController(withIdentifier: "DashboardContainerViewController") as! DashboardContainerViewController
        window?.rootViewController = vc
    }
    func switchRootViewController(){
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let nav = storyboard.instantiateViewController(withIdentifier: "main") as? LoginViewController
        
        self.window?.rootViewController = nav
    }
    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
        UserDBManager.saveContext()
        switchRootViewController()
    }
}
