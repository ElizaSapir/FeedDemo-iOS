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
        
        APApplicasterController.initSharedInstanceWithPListSettingsWithSecretKey(kAppSecretKey)
        APApplicasterController.sharedInstance().delegate = self
        APApplicasterController.sharedInstance().rootViewController = self.window?.rootViewController
        APApplicasterController.sharedInstance().load()

        [[FBSDKApplicationDelegate sharedInstance] application:application
            didFinishLaunchingWithOptions:launchOptions];
        
        self.appLaunchURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
        self.remoteLaunchInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        self.sourceApplication = [launchOptions objectForKey:UIApplicationLaunchOptionsSourceApplicationKey];
        
        return true
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
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

