//
//  AppDelegate.m
//  FeedDemo-ObjectiveC
//
//  Created by Philip Kramarov on 2/16/16.
//  Copyright © 2016 Applicaster LTD. All rights reserved.
//

#import "AppDelegate.h"

@import ApplicasterSDK;
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface AppDelegate () <APApplicasterControllerDelegate>

// These properties will help forwarding launch information and recieved URL scheme
// after Applicaster Controller does it's initial loading
@property (nonatomic, strong) NSURL *appLaunchURL;
@property (nonatomic, strong) NSDictionary *remoteLaunchInfo;
@property (nonatomic, strong) NSString *sourceApplication;

@end

@implementation AppDelegate

static NSString *kAppSecretKey = @"c02165c93cc72695ac757e957e";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [APApplicasterController initSharedInstanceWithPListSettingsWithSecretKey:kAppSecretKey
                                                                 launchOption:launchOptions];
    [[APApplicasterController sharedInstance] setDelegate:self];
    [[APApplicasterController sharedInstance] setRootViewController:self.window.rootViewController];
    [[APApplicasterController sharedInstance] load];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    self.appLaunchURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    self.remoteLaunchInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    self.sourceApplication = [launchOptions objectForKey:UIApplicationLaunchOptionsSourceApplicationKey];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[APApplicasterController sharedInstance].notificationManager registerToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    BOOL launchedApplication = application.applicationState == UIApplicationStateInactive;
    [[APApplicasterController sharedInstance].notificationManager appDidReceiveRemoteNotification:userInfo launchedApplication:launchedApplication];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    BOOL launchedApplication = application.applicationState == UIApplicationStateInactive;
    [[APApplicasterController sharedInstance].notificationManager appDidReceiveLocalNotification:notification launchedApplication:launchedApplication];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // If the launch URL handling is being delayed, return YES.
    if (!self.appLaunchURL) {
        // The return can be used to check if Applicaster handled the URL scheme and add additional implementation
        return [[APApplicasterController sharedInstance] application:application
                                                             openURL:url
                                                   sourceApplication:sourceApplication
                                                          annotation:annotation];
    } else {
        // Or other URL scheme implementation
        return YES;
    }
}

#pragma mark -  APApplicasterControllerDelegate

- (void)applicaster:(APApplicasterController *)applicaster loadedWithAccountID:(NSString *)accountID {
    if (self.appLaunchURL) {
        [[APApplicasterController sharedInstance] application:[UIApplication sharedApplication]
                                                      openURL:self.appLaunchURL
                                            sourceApplication:self.sourceApplication
                                                   annotation:nil];
        self.appLaunchURL = nil;
    } else if (self.remoteLaunchInfo != nil) {
        [applicaster.notificationManager appDidReceiveRemoteNotification:self.remoteLaunchInfo
                                                     launchedApplication:YES];
        self.remoteLaunchInfo = nil;
    }
    
    NSString *accountsAccountId = [[APApplicasterController sharedInstance] applicasterSettings][@"APAccountsAccountID"];
    [[APTimelinesManager sharedManager] setAccountID:accountsAccountId];
}

- (void)applicaster:(APApplicasterController *)applicaster withAccountID:(NSString *)accountID didFailLoadWithError:(NSError *)error {
    // Present a loading error in the loading view controller
    NSLog(@"%@", [error localizedDescription]);
}

@end
