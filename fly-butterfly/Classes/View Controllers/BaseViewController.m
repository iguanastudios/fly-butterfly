//
//  BaseViewController.m
//  butterfly
//
//  Created by Luis Flores on 3/30/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import "BaseViewController.h"
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

@interface BaseViewController ()

@end

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
             @"7faca3e295de4c53c4a47406ecbdaaaa7354c1d0",
             @"0ba27881eb837af6dabbe109a9e112ceb7cbfb97"];
}

- (BOOL)googleBannerViewHasCloseAdButton {
    return NO;
}

@end
