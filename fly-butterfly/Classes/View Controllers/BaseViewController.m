//
//  BaseViewController.m
//  butterfly
//
//  Created by Luis Flores on 3/30/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import "BaseViewController.h"

@implementation BaseViewController

#pragma mark - Google Analytics

- (void)track:(NSString *)screen {
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screen];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

#pragma mark - GVGoogleBannerViewDelegate

- (NSString *)googleBannerViewAdUnitID {
    // Implemented in subclasses
    return nil;
}

- (NSArray *)googleBannerTestDevices {
    return @[@"9d7eada80bc22149b0c33df66f0957d0",
             @"4f671bf723d90741f66b2fa9a13a497c"];
}

- (BOOL)googleBannerViewHasCloseAdButton {
    return NO;
}

@end
