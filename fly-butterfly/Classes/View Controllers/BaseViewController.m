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

#pragma mark - View lifecycle

- (BOOL)prefersStatusBarHidden {
    return YES;
}

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

- (BOOL)googleBannerViewHasCloseAdButton {
    return NO;
}

@end
