//
//  AppDelegate.swift
//  FeedDemo-Swift
//
//  Created by Philip Kramarov on 2/16/16.
//  Copyright © 2016 Applicaster LTD. All rights reserved.
//

import UIKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, APApplicasterControllerDelegate {

    var window: UIWindow?
    
    // These properties will help forwarding launch information and recieved URL scheme
    // after Applicaster Controller does it's initial loading
    var appLaunchURL: URL?
    var remoteLaunchInfo: NSDictionary?
    var sourceApplication: NSString?

    let kAppSecretKey = "c02165c93cc72695ac757e957e"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        APApplicasterController.initSharedInstanceWithPListSettings(withSecretKey: kAppSecretKey,
                                                                                 launchOption:launchOptions)
        APApplicasterController.sharedInstance().delegate = self
        APApplicasterController.sharedInstance().rootViewController = self.window?.rootViewController
        APApplicasterController.sharedInstance().load()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        if let unwrappedLaunchOptions = launchOptions {
            self.appLaunchURL = unwrappedLaunchOptions[UIApplicationLaunchOptionsKey.url] as? URL
            self.remoteLaunchInfo = unwrappedLaunchOptions[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary
            self.sourceApplication = unwrappedLaunchOptions[UIApplicationLaunchOptionsKey.sourceApplication] as? NSString
        }
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        APApplicasterController.sharedInstance().notificationManager.registerToken(deviceToken)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        let launchedApplication = (application.applicationState == UIApplicationState.inactive)
        APApplicasterController.sharedInstance().notificationManager.appDidReceiveRemoteNotification(userInfo, launchedApplication: launchedApplication)

    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        let launchedApplication = (application.applicationState == UIApplicationState.inactive)
        APApplicasterController.sharedInstance().notificationManager.appDidReceive(notification, launchedApplication: launchedApplication)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // If the launch URL handling is being delayed, return true.
        if (self.appLaunchURL == nil) {
            // The return can be used to check if Applicaster handled the URL scheme and add additional implementation
            let optionsDictionary: [UIApplicationOpenURLOptionsKey:Any] = [
                UIApplicationOpenURLOptionsKey.sourceApplication: sourceApplication!,
                UIApplicationOpenURLOptionsKey.annotation: annotation,
                ]
            
            return APApplicasterController.sharedInstance().application(application,
                                                                        open: url,
                                                                        options: optionsDictionary)
        } else {
            // Or other URL scheme implementation
            return true;
        }
    }
    
    // MARK: APApplicasterControllerDelegate
    
    func applicaster(_ applicaster: APApplicasterController!, loadedWithAccountID accountID: String!) {
        if (self.appLaunchURL != nil) {
            let optionsDictionary: [UIApplicationOpenURLOptionsKey:Any] = [
                UIApplicationOpenURLOptionsKey.sourceApplication: self.sourceApplication!,
                ]

            APApplicasterController.sharedInstance().application(UIApplication.shared,
                                                                 open: self.appLaunchURL,
                                                                 options: optionsDictionary)
            self.appLaunchURL = nil
        } else if (self.remoteLaunchInfo != nil) {
            applicaster.notificationManager.appDidReceiveRemoteNotification(self.remoteLaunchInfo as! [AnyHashable: Any],
                launchedApplication: true)
            self.remoteLaunchInfo = nil
        }
        
        let accountsAccountId = APApplicasterController.sharedInstance().applicasterSettings["APAccountsAccountID"] as! String
        APTimelinesManager.shared().accountID = accountsAccountId
    }
    
    func applicaster(_ applicaster: APApplicasterController!, withAccountID accountID: String!, didFailLoadWithError error: Error!) {
        // Present a loading error in the loading view controller
        print(error.localizedDescription)
    }
    
}

