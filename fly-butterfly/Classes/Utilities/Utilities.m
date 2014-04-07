//
//  Utilities.m
//  butterfly
//
//  Created by Luis Flores on 3/3/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (void)flashScene:(SKScene *)scene {
    SKSpriteNode *flash = [SKSpriteNode node];
    flash.anchorPoint = CGPointZero;
    flash.size = scene.size;
    flash.color = [UIColor whiteColor];
    flash.alpha = 0.8;
    SKAction *fadeOut = [SKAction fadeOutWithDuration:0.6];
    [flash runAction:fadeOut completion:^{
        [flash removeFromParent];
    }];
    [scene addChild:flash];
}

+ (CGFloat)randomPositionAtTopWithScene:(SKScene *)scene numberOfCrows:(NSInteger)crows {
    int maxY = scene.size.height - CrowHeight / 2;
    int minY = (scene.size.height + GoogleBannerHeight) / 2 + GoogleBannerHeight;
    int diff = (maxY - minY) / 2;

    if (crows % 2) {
        maxY -= diff;
    } else {
        minY += diff;
    }

    return minY + arc4random() % (maxY - minY);
}

@end
