//
//  AdManager.m
//  fly-butterfly
//
//  Created by Luis Flores on 4/19/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import "AdManager.h"

@interface AdManager ()
@property (nonatomic) NSUInteger counter;
@end

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
    self.interstitial.adUnitID = @"";

    GADRequest *request = [GADRequest request];
    request.testDevices = @[GAD_SIMULATOR_ID];

    [self.interstitial loadRequest:request];
}

- (void)presentInterstitial:(UIViewController *)controller {
    if (self.interstitial.isReady) {
        [self.interstitial presentFromRootViewController:controller];
        self.counter = 0;
    }
}

- (void)countGame {
    self.counter++;

    if (self.counter >= 3) {
        [self prepareInterstitial];
    }
}

@end
