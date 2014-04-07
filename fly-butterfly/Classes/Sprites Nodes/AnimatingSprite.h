//
//  AnimatingSprite.h
//  butterfly
//
//  Created by Luis Flores on 2/23/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface AnimatingSprite : SKSpriteNode

@property (strong,nonatomic) SKAction *facingSideAnimation;

- (instancetype)initWithPosition:(CGPoint)position;
+ (SKTexture *)generateTexture;
+ (SKAction*)createAnimationForeverWithPrefix:(NSString *)prefix
                                       frames:(NSInteger)frames
                                        atlas:(NSString *)atlas;
+ (SKAction*)createAnimationWithPrefix:(NSString *)prefix
                                frames:(NSInteger)frames
                                 atlas:(NSString *)atlas;

@end
