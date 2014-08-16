//
//  JSPongClient.h
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-16.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JSPongClient;

@protocol JSPongClientDelegate <NSObject>

- (void)pongClient:(JSPongClient *)client serverBecameAvailable:(NSString *)peerID;
- (void)pongClient:(JSPongClient *)client serverBecameUnavailable:(NSString *)peerID;

@end

@interface JSPongClient : NSObject <GKSessionDelegate>

@property (nonatomic, weak) id <JSPongClientDelegate> delegate;

@property (nonatomic, strong, readonly) NSArray *availableServers;
@property (nonatomic, strong, readonly) GKSession *session;

- (NSUInteger)availableServerCount;
- (NSString *)peerIDForAvailableServerAtIndex:(NSUInteger)index;
- (NSString *)displayNameForPeerID:(NSString *)peerID;

- (void)startSearchingForServersWithSessionID:(NSString *)sessionID;
- (void)connectToServerWithPeerID:(NSString *)peerID;

@end
