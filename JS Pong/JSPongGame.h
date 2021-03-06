//
//  JSPongGame.h
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-16.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSPongPlayer.h"

@class JSPongGame;

@protocol JSPongGameDelegate <NSObject>

- (void)gameWaitingForServerReady:(JSPongGame *)game;
- (void)gameWaitingForClientsReady:(JSPongGame *)game;
- (void)game:(JSPongGame *)game didMovePlayer:(JSPongPlayer *)player toPosition:(CGPoint)playerPosition;
- (void)game:(JSPongGame *)game didMovePuckToPosition:(CGPoint)puckPosition;
- (void)game:(JSPongGame *)game didQuitWithReason:(QuitReason)reason;
- (void)gameDidSetup:(JSPongGame *)game;
- (void)gameDidBegin:(JSPongGame *)game;
- (void)game:(JSPongGame *)game playerDidDisconnect:(JSPongPlayer *)disconnectedPlayer;

@end

@interface JSPongGame : NSObject <GKSessionDelegate>

@property (nonatomic, weak) id <JSPongGameDelegate> delegate;
@property (nonatomic, assign) BOOL isServer;

- (void)startClientGameWithSession:(GKSession *)session playerName:(NSString *)name server:(NSString *)peerID;
- (void)startServerGameWithSession:(GKSession *)session playerName:(NSString *)name clients:(NSArray *)clients;
- (void)quitGameWithReason:(QuitReason)reason;
- (void)setupPlayGroundWithRect:(CGRect) playGroundFrame;
- (void)playerMovedPadToPosition:(CGPoint) position;
- (void)faceOff;

@end