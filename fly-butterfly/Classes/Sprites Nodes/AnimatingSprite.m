//
//  AnimatingSprite.m
//  butterfly
//
//  Created by Luis Flores on 2/23/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import "AnimatingSprite.h"

@implementation AnimatingSprite

#pragma mark - Initialization

- (instancetype)initWithPosition:(CGPoint)position {
    if (self = [super init]) {
        self.texture = [[self class] generateTexture];
        self.size = self.texture.size;
        self.position = position;
    }

    return self;
}

#pragma mark - Public Method

+ (SKTexture *)generateTexture {
    // Overridden by subclasses
    return nil;
}

+ (SKAction*)createAnimationForeverWithPrefix:(NSString *)prefix
                                       frames:(NSInteger)frames
                                        atlas:(NSString *)atlas {
    return [SKAction repeatActionForever: [self texturesWithPrefix:prefix
                                                            frames:frames
                                                             atlas:atlas]];
}

+ (SKAction*)createAnimationWithPrefix:(NSString *)prefix
                                frames:(NSInteger)frames
                                 atlas:(NSString *)atlas {
    return [self texturesWithPrefix:prefix frames:frames atlas:atlas];
}

#pragma mark - Private Method

+ (SKAction *)texturesWithPrefix:(NSString *)prefix
                          frames:(NSInteger)frames
                           atlas:(NSString *)atlasName {
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:atlasName];
    NSMutableArray *textures = [[NSMutableArray alloc] initWithCapacity:frames];

    for (int frame = 1; frame <= frames; frame++) {
        SKTexture *texture = [atlas textureNamed:[NSString stringWithFormat:@"%@%d", prefix, frame]];
        [textures addObject: texture];
    }

    for (int frame = (int)frames; frame > 1; frame--) {
        SKTexture *texture = [atlas textureNamed:[NSString stringWithFormat:@"%@%d", prefix, frame]];
        texture.filteringMode = SKTextureFilteringNearest;
        [textures addObject: texture];
    }

    return [SKAction animateWithTextures:textures timePerFrame:0.10 resize:YES restore:YES];
}

@end
