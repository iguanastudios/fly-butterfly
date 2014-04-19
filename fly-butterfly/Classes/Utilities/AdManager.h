//
//  AdManager.h
//  fly-butterfly
//
//  Created by Luis Flores on 4/19/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Google-Mobile-Ads-SDK/GADInterstitial.h>

@interface AdManager : NSObject

@property (strong, nonatomic) GADInterstitial *interstitial;

+ (AdManager *)sharedInstance;
- (void)prepareInterstitial;
- (void)presentInterstitial:(UIViewController *)controller;
- (void)countGame;

@end
