//
//  Utilities.h
//  butterfly
//
//  Created by Luis Flores on 3/3/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface Utilities : NSObject

+ (void)flashScene:(SKScene *)scene;
+ (CGFloat)randomPositionAtTopWithScene:(SKScene *)scene numberOfCrows:(NSInteger)crows;

@end
