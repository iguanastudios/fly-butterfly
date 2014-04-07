//
//  BaseViewController.h
//  butterfly
//
//  Created by Luis Flores on 3/30/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

@import SpriteKit;

#import <GVGoogleBannerView/GVGoogleBannerView.h>
#import "GAITrackedViewController.h"

@interface BaseViewController : GAITrackedViewController <GVGoogleBannerViewDelegate>

- (void)track:(NSString *)screen;

@end
