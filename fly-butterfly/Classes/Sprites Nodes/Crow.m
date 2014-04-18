//
//  Crow.m
//  butterfly
//
//  Created by Luis Flores on 3/2/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import "Crow.h"
#import "Constants.h"

@implementation Crow

#pragma mark - Initialization

- (instancetype)initWithPosition:(CGPoint)position {
    if (self = [super initWithPosition:position]) {
        self.name = @"crow";
        CGRect bodySize = CGRectInset(self.frame, 10, 10);
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bodySize.size];
        self.physicsBody.dynamic = NO;
        self.physicsBody.categoryBitMask = BCrowCategory;

        self.facingSideAnimation = [Crow createAnimationForeverWithPrefix:@"crow" frames:8];
        [self runAction:self.facingSideAnimation];
    }

    return self;
}

#pragma mark - Public methods

- (void)fly {
    NSTimeInterval duration = (self.position.x + CrowWidth / 2) * FlySecondsPerPoint;
    SKAction *crowFly = [SKAction moveToX:-CrowWidth / 2 duration:duration];
    [self runAction:crowFly withKey:@"fly"];
}

#pragma mark - Override AnimatingSprite

+ (SKTexture *)generateTexture {
    static SKTexture *texture = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"sprites"];
        texture = [atlas textureNamed:@"crow1"];
    });
    
    return texture;
}

+ (SKAction*)createAnimationForeverWithPrefix:(NSString *)prefix frames:(NSInteger)frames {
    static SKAction *animation;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        animation = [super createAnimationForeverWithPrefix:prefix frames:frames atlas:@"sprites"];
    });

    return animation;
}

@end
