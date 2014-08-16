//
//  JSPongServer.m
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-16.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import "JSPongServer.h"

typedef enum
{
	ServerStateIdle,
	ServerStateAcceptingConnections,
	ServerStateIgnoringNewConnections,
}
ServerState;

@implementation JSPongServer
{
    NSMutableArray *_connectedClients;
    ServerState _serverState;
}

- (id)init
{
	if ((self = [super init]))
	{
		_serverState = ServerStateIdle;
	}
	return self;
}

- (void)startAcceptingConnectionsForSessionID:(NSString *)sessionID
{
	if (_serverState == ServerStateIdle)
	{
		_serverState = ServerStateAcceptingConnections;
        
		_connectedClients = [NSMutableArray arrayWithCapacity:self.maxClients];
        
        _session = [[GKSession alloc] initWithSessionID:sessionID displayName:nil sessionMode:GKSessionModeServer];
        _session.delegate = self;
        _session.available = YES;
	}
}

- (NSArray *)connectedClients
{
	return _connectedClients;
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
#ifdef DEBUG
	NSLog(@"JSPongServer: peer %@ changed state %d", peerID, state);
#endif
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
#ifdef DEBUG
	NSLog(@"JSPongServer: connection request from peer %@", peerID);
#endif
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
#ifdef DEBUG
	NSLog(@"JSPongServer: connection with peer %@ failed %@", peerID, error);
#endif
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
#ifdef DEBUG
	NSLog(@"JSPongServer: session failed %@", error);
#endif
}


@end
