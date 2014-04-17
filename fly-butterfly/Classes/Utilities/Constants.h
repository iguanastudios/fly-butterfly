//
//  Constants.h
//  butterfly
//
//  Created by Luis Flores on 2/23/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

typedef NS_OPTIONS(uint32_t, BPhysicsCategory) {
    // Game
    BEdgeCategory = 1 << 0,
    BButterflyCategory = 1 << 1,
    BCrowCategory = 1 << 2,
    BGroundCategory = 1 << 3,
    BPointCategory = 1 << 4,
};

@interface Constants : NSObject

// Global
extern CGFloat const BackgroundPointsPerSec;
extern NSInteger const MinSpaceBetweenCrows;
extern NSString *const LabelFont;
extern CGFloat const Speed;
extern CGFloat const CrowDefaultInterval;

// Butterfly
extern CGFloat const JumpImpulse;
extern CGFloat const ButterflyPosition;

// Crow
extern CGFloat const CrowHeight;
extern CGFloat const CrowWidth;

// Google Ads
extern CGFloat const GoogleBannerHeight;

@end
