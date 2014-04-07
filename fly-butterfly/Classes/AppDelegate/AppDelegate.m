//
//  AppDelegate.m
//  butterfly
//
//  Created by Luis Flores on 3/4/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import <Appirater/Appirater.h>
#import <Crashlytics/Crashlytics.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import "AppDelegate.h"
#import "Config.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifndef DEBUG
    [Crashlytics startWithAPIKey:[Config sharedInstance].crashlyticsId];

    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance] trackerWithTrackingId:[Config sharedInstance].googleAnalyticsId];

    [Appirater setAppId:@"834334049"];
    [Appirater setDaysUntilPrompt:5];
    [Appirater setUsesUntilPrompt:5];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];
#endif

    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [Appirater appEnteredForeground:YES];
}

@end
