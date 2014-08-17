//
//  JSPongHostGameViewController.h
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-16.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSPongServer.h"

@class JSPongHostGameViewController;

@protocol JSPongHostGameViewControllerDelegate <NSObject>

- (void)hostViewControllerDidCancel:(JSPongHostGameViewController *)controller;
- (void)hostViewController:(JSPongHostGameViewController *)controller didEndSessionWithReason:(QuitReason)reason;
- (void)hostViewController:(JSPongHostGameViewController *)controller startGameWithSession:(GKSession *)session playerName:(NSString *)name clients:(NSArray *)clients;

@end

@interface JSPongHostGameViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, JSPongServerDelegate>

@property (nonatomic, weak) id <JSPongHostGameViewControllerDelegate> delegate;

@end
