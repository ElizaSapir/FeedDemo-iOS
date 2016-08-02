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
    var appLaunchURL: NSURL?
    var remoteLaunchInfo: NSDictionary?
    var sourceApplication: NSString?

    let kAppSecretKey = "c02165c93cc72695ac757e957e"
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        APApplicasterController.initSharedInstanceWithPListSettingsWithSecretKey(kAppSecretKey,
                                                                                 launchOption:launchOptions)
        APApplicasterController.sharedInstance().delegate = self
        APApplicasterController.sharedInstance().rootViewController = self.window?.rootViewController
        APApplicasterController.sharedInstance().load()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        if let unwrappedLaunchOptions = launchOptions {
            self.appLaunchURL = unwrappedLaunchOptions[UIApplicationLaunchOptionsURLKey] as? NSURL
            self.remoteLaunchInfo = unwrappedLaunchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary
            self.sourceApplication = unwrappedLaunchOptions[UIApplicationLaunchOptionsSourceApplicationKey] as? NSString
        }
        
        return true
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        APApplicasterController.sharedInstance().notificationManager.registerToken(deviceToken)
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        let launchedApplication = (application.applicationState == UIApplicationState.Inactive)
        APApplicasterController.sharedInstance().notificationManager.appDidReceiveRemoteNotification(userInfo, launchedApplication: launchedApplication)

    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        let launchedApplication = (application.applicationState == UIApplicationState.Inactive)
        APApplicasterController.sharedInstance().notificationManager.appDidReceiveLocalNotification(notification, launchedApplication: launchedApplication)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        // If the launch URL handling is being delayed, return true.
        if (self.appLaunchURL == nil) {
            // The return can be used to check if Applicaster handled the URL scheme and add additional implementation
            return APApplicasterController.sharedInstance().application(application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
        } else {
            // Or other URL scheme implementation
            return true;
        }
    }
    
    // MARK: APApplicasterControllerDelegate
    
    func applicaster(applicaster: APApplicasterController!, loadedWithAccountID accountID: String!) {
        if (self.appLaunchURL != nil) {
            APApplicasterController.sharedInstance().application(UIApplication.sharedApplication(),
                openURL: self.appLaunchURL,
                sourceApplication: self.sourceApplication as? String,
                annotation: nil)
            self.appLaunchURL = nil
        } else if (self.remoteLaunchInfo != nil) {
            applicaster.notificationManager.appDidReceiveRemoteNotification(self.remoteLaunchInfo as! [NSObject: AnyObject],
                launchedApplication: true)
            self.remoteLaunchInfo = nil
        }
        
        let accountsAccountId = APApplicasterController.sharedInstance().applicasterSettings["APAccountsAccountID"] as! String
        APTimelinesManager.sharedManager().accountID = accountsAccountId
    }
    
    func applicaster(applicaster: APApplicasterController!, withAccountID accountID: String!, didFailLoadWithError error: NSError!) {
        // Present a loading error in the loading view controller
        print(error.localizedDescription)
    }
    
}

