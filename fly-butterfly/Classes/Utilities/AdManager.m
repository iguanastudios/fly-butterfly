//
//  AdManager.m
//  fly-butterfly
//
//  Created by Luis Flores on 4/19/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import "AdManager.h"

@implementation AdManager

#pragma mark - Singleton

+ (AdManager *)sharedInstance {
    static dispatch_once_t pred;
    static AdManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Public methods

- (void)prepareInterstitial {
    self.interstitial = [[GADInterstitial alloc] init];
    self.interstitial.adUnitID = @"ca-app-pub-3392553844996186/2623164155";

    GADRequest *request = [GADRequest request];
    request.testDevices = @[GAD_SIMULATOR_ID,
                            @"9d7eada80bc22149b0c33df66f0957d0",
                            @"4f671bf723d90741f66b2fa9a13a497c"];

    [self.interstitial loadRequest:request];
}

- (void)presentInterstitial:(UIViewController *)controller {
    if (self.interstitial.isReady) {
        [self.interstitial presentFromRootViewController:controller];
    }
}

@end
