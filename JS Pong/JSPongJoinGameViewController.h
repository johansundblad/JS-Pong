//
//  JSPongJoinGameViewController.h
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-16.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSPongClient.h"

@class JSPongJoinGameViewController;

@protocol JSPongJoinGameViewControllerDelegate <NSObject>

- (void)joinViewControllerDidCancel:(JSPongJoinGameViewController *)controller;
- (void)joinViewController:(JSPongJoinGameViewController *)controller didDisconnectWithReason:(QuitReason)reason;
- (void)joinViewController:(JSPongJoinGameViewController *)controller startGameWithSession:(GKSession *)session playerName:(NSString *)name server:(NSString *)peerID;

@end

@interface JSPongJoinGameViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, JSPongClientDelegate>

@property (nonatomic, weak) id <JSPongJoinGameViewControllerDelegate> delegate;

@end
