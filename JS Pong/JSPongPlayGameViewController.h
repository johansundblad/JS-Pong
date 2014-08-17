//
//  JSPongPlayGameViewController.h
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-17.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSPongGame.h"

@class JSPongPlayGameViewController;

@protocol JSPongPlayGameViewControllerDelegate <NSObject>

- (void)gameViewController:(JSPongPlayGameViewController *)controller didQuitWithReason:(QuitReason)reason;

@end

@interface JSPongPlayGameViewController : UIViewController <UIAlertViewDelegate, JSPongGameDelegate>

@property (nonatomic, weak) id <JSPongPlayGameViewControllerDelegate> delegate;
@property (nonatomic, strong) JSPongGame *game;

@end
