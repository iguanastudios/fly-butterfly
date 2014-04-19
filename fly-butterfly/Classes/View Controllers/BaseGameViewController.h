//
//  BaseGameViewController.h
//  butterfly
//

//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseScene.h"

@interface BaseGameViewController : BaseViewController <SceneDelegate>

@property (weak, nonatomic) IBOutlet SKView *gameView;
@property (weak, nonatomic) IBOutlet UIView *gameOverView;
@property (weak, nonatomic) IBOutlet UILabel *tapLabel;
@property (strong, nonatomic) BaseScene *scene;
@property (strong, nonatomic) NSTimer *timer;

- (void)presentScene;
- (void)gameOver;

@end
