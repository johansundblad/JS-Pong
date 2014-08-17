//
//  JSPongClient.m
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-16.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import "JSPongClient.h"

typedef enum
{
	ClientStateIdle,
	ClientStateSearchingForServers,
	ClientStateConnecting,
	ClientStateConnected,
}
ClientState;

@implementation JSPongClient
{
	NSMutableArray *_availableServers;
    ClientState _clientState;
    NSString *_serverPeerID;
}

- (id)init
{
	if ((self = [super init]))
	{
		_clientState = ClientStateIdle;
	}
	return self;
}

- (void)startSearchingForServersWithSessionID:(NSString *)sessionID
{
    if (_clientState == ClientStateIdle)
	{
		_clientState = ClientStateSearchingForServers;
		_availableServers = [NSMutableArray arrayWithCapacity:10];
        
        _session = [[GKSession alloc] initWithSessionID:sessionID displayName:nil sessionMode:GKSessionModeClient];
        _session.delegate = self;
        _session.available = YES;
	}
}

- (void)connectToServerWithPeerID:(NSString *)peerID
{
	NSAssert(_clientState == ClientStateSearchingForServers, @"Wrong state");
    
	_clientState = ClientStateConnecting;
	_serverPeerID = peerID;
	[_session connectToPeer:peerID withTimeout:_session.disconnectTimeout];
}

- (void)disconnectFromServer
{
	NSAssert(_clientState != ClientStateIdle, @"Wrong state");
    
	_clientState = ClientStateIdle;
    
	[_session disconnectFromAllPeers];
	_session.available = NO;
	_session.delegate = nil;
	_session = nil;
    
	_availableServers = nil;
    
	[self.delegate pongClient:self didDisconnectFromServer:_serverPeerID];
	_serverPeerID = nil;
}

- (NSArray *)availableServers
{
	return _availableServers;
}

- (NSUInteger)availableServerCount
{
	return [_availableServers count];
}

- (NSString *)peerIDForAvailableServerAtIndex:(NSUInteger)index
{
	return [_availableServers objectAtIndex:index];
}

- (NSString *)displayNameForPeerID:(NSString *)peerID
{
	return [_session displayNameForPeer:peerID];
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
#ifdef DEBUG
	NSLog(@"JSPongClient: peer %@ changed state %d", peerID, state);
#endif
    
	switch (state)
	{
            // The client has discovered a new server.
		case GKPeerStateAvailable:
			if (_clientState == ClientStateSearchingForServers)
			{
				if (![_availableServers containsObject:peerID])
				{
					[_availableServers addObject:peerID];
					[self.delegate pongClient:self serverBecameAvailable:peerID];
				}
			}
			break;
            
            // The client sees that a server goes away.
		case GKPeerStateUnavailable:
			if (_clientState == ClientStateSearchingForServers)
			{
				if ([_availableServers containsObject:peerID])
				{
					[_availableServers removeObject:peerID];
					[self.delegate pongClient:self serverBecameUnavailable:peerID];
				}
			}
			break;
            
            // You're now connected to the server.
		case GKPeerStateConnected:
			if (_clientState == ClientStateConnecting)
			{
				_clientState = ClientStateConnected;
				[self.delegate pongClient:self didConnectToServer:peerID];
			}
			break;
            
            // You're now no longer connected to the server.
		case GKPeerStateDisconnected:
			if (_clientState == ClientStateConnected)
			{
				[self disconnectFromServer];
			}
			break;
            
		case GKPeerStateConnecting:
			break;
	}	
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
#ifdef DEBUG
	NSLog(@"JSPongClient: connection request from peer %@", peerID);
#endif
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
#ifdef DEBUG
	NSLog(@"MatchmakingClient: connection with peer %@ failed %@", peerID, error);
#endif
    
	[self disconnectFromServer];
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
#ifdef DEBUG
	NSLog(@"JSPongClient: session failed %@", error);
#endif
}

@end
