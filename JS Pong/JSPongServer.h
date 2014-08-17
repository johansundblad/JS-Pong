//
//  JSPongServer.h
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-16.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JSPongServer;

@protocol JSPongServerDelegate <NSObject>

- (void)pongServer:(JSPongServer *)server clientDidConnect:(NSString *)peerID;
- (void)pongServer:(JSPongServer *)server clientDidDisconnect:(NSString *)peerID;

@end

@interface JSPongServer : NSObject <GKSessionDelegate>

@property (nonatomic, weak) id <JSPongServerDelegate> delegate;

@property (nonatomic, assign) int maxClients;
@property (nonatomic, strong, readonly) NSArray *connectedClients;
@property (nonatomic, strong, readonly) GKSession *session;

- (NSUInteger)connectedClientCount;
- (NSString *)peerIDForConnectedClientAtIndex:(NSUInteger)index;
- (NSString *)displayNameForPeerID:(NSString *)peerID;

- (void)startAcceptingConnectionsForSessionID:(NSString *)sessionID;
- (void)stopAcceptingConnections;

@end
