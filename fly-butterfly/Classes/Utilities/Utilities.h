//
//  Utilities.h
//  butterfly
//
//  Created by Luis Flores on 3/3/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

@import SpriteKit;

@interface Utilities : NSObject

+ (void)flashScene:(SKScene *)scene;
+ (CGFloat)randomPositionAtTopWithScene:(SKScene *)scene numberOfCrows:(NSInteger)crows;

@end
