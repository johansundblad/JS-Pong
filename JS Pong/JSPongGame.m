//
//  JSPongGame.m
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-16.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import "JSPongGame.h"
#import "JSPongPacket.h"
#import "JSPongPacketSignInResponse.h"
#import "JSPongPacketServerReady.h"
#import "JSPongPacketOtherClientQuit.h"

typedef enum
{
	GameStateWaitingForSignIn,
	GameStateWaitingForReady,
	GameStateFaceOff,
	GameStatePlaying,
	GameStateGameOver,
	GameStateQuitting,
}
GameState;

@implementation JSPongGame
{
	GameState _state;
    
	GKSession *_session;
	NSString *_serverPeerID;
	NSString *_localPlayerName;
    NSMutableDictionary *_players;
}

- (id)init
{
	if ((self = [super init]))
	{
		_players = [NSMutableDictionary dictionaryWithCapacity:2];
	}
	return self;
}

- (void)dealloc
{
#ifdef DEBUG
	NSLog(@"dealloc %@", self);
#endif
}

#pragma mark - Game Logic

- (void)startClientGameWithSession:(GKSession *)session playerName:(NSString *)name server:(NSString *)peerID
{
	self.isServer = NO;
    
	_session = session;
	_session.available = NO;
	_session.delegate = self;
	[_session setDataReceiveHandler:self withContext:nil];
    
	_serverPeerID = peerID;
	_localPlayerName = name;
    
	_state = GameStateWaitingForSignIn;
    
	[self.delegate gameWaitingForServerReady:self];
}

- (void)startServerGameWithSession:(GKSession *)session playerName:(NSString *)name clients:(NSArray *)clients
{
	self.isServer = YES;
    
	_session = session;
	_session.available = NO;
	_session.delegate = self;
	[_session setDataReceiveHandler:self withContext:nil];
    
	_state = GameStateWaitingForSignIn;
    
	[self.delegate gameWaitingForClientsReady:self];
    
    // Create the Player object for the server.
    JSPongPlayer *player = [[JSPongPlayer alloc] init];
	player.name = name;
	player.peerID = _session.peerID;
	[_players setObject:player forKey:player.peerID];
    
	// Add a Player object for each client.
	for (NSString *peerID in clients)
	{
		JSPongPlayer *player = [[JSPongPlayer alloc] init];
		player.peerID = peerID;
		[_players setObject:player forKey:player.peerID];
	}
    
    JSPongPacket *packet = [JSPongPacket packetWithType:PacketTypeSignInRequest];
	[self sendPacketToAllClients:packet];
}

- (JSPongPlayer *)playerWithPeerID:(NSString *)peerID
{
	return [_players objectForKey:peerID];
}

- (BOOL)receivedResponsesFromAllPlayers
{
	for (NSString *peerID in _players)
	{
		JSPongPlayer *player = [self playerWithPeerID:peerID];
		if (!player.receivedResponse)
			return NO;
	}
	return YES;
}

- (void)beginGame
{
	_state = GameStateFaceOff;
	[self.delegate gameDidBegin:self];
}

- (void)changeRelativePositionsOfPlayers
{
    /*
	NSAssert(!self.isServer, @"Must be client");
    
	JSPongPlayer *myPlayer = [self playerWithPeerID:_session.peerID];
	int diff = myPlayer.position;
	myPlayer.position = PlayerPositionBottom;
    
	[_players enumerateKeysAndObjectsUsingBlock:^(id key, JSPongPlayer *obj, BOOL *stop)
     {
         if (obj != myPlayer)
         {
             obj.position = (obj.position - diff) % 4;
         }
     }];
     */
}

/*
- (void)playerMovedPadToPosition:(CGRect *)position
{
    NSLog(@"playerMovedPadToPosition x = %i y = %i", position.frame.x, position.y);
}
 */

- (BOOL)isSinglePlayerGame
{
	return (_session == nil);
}

- (void)quitGameWithReason:(QuitReason)reason
{
	_state = GameStateQuitting;
    
	if (reason == QuitReasonUserQuit && ![self isSinglePlayerGame])
	{
		if (self.isServer)
		{
			JSPongPacket *packet = [JSPongPacket packetWithType:PacketTypeServerQuit];
			[self sendPacketToAllClients:packet];
		}
		else
		{
			JSPongPacket *packet = [JSPongPacket packetWithType:PacketTypeClientQuit];
			[self sendPacketToServer:packet];
		}
	}
    
	[_session disconnectFromAllPeers];
	_session.delegate = nil;
	_session = nil;
    
	[self.delegate game:self didQuitWithReason:reason];
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
#ifdef DEBUG
	NSLog(@"Game: peer %@ changed state %d", peerID, state);
#endif
    
    if (state == GKPeerStateDisconnected)
	{
		if (self.isServer)
		{
			[self clientDidDisconnect:peerID];
		}
        else if ([peerID isEqualToString:_serverPeerID])
		{
			[self quitGameWithReason:QuitReasonConnectionDropped];
		}
	}
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
#ifdef DEBUG
	NSLog(@"Game: connection request from peer %@", peerID);
#endif
    
	[session denyConnectionFromPeer:peerID];
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
#ifdef DEBUG
	NSLog(@"Game: connection with peer %@ failed %@", peerID, error);
#endif
    
	// Not used.
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
#ifdef DEBUG
	NSLog(@"Game: session failed %@", error);
#endif
    
    if ([[error domain] isEqualToString:GKSessionErrorDomain])
	{
		if (_state != GameStateQuitting)
		{
			[self quitGameWithReason:QuitReasonConnectionDropped];
		}
	}
}

#pragma mark - GKSession Data Receive Handler

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peerID inSession:(GKSession *)session context:(void *)context
{
#ifdef DEBUG
	NSLog(@"Game: receive data from peer: %@, data: %@, length: %lu", peerID, data, (unsigned long)[data length]);
#endif
    
	JSPongPacket *packet = [JSPongPacket packetWithData:data];
	if (packet == nil)
	{
		NSLog(@"Invalid packet: %@", data);
		return;
	}
    
	JSPongPlayer *player = [self playerWithPeerID:peerID];
    if (player != nil)
	{
		player.receivedResponse = YES;
	}
    
	if (self.isServer)
		[self serverReceivedPacket:packet fromPlayer:player];
	else
		[self clientReceivedPacket:packet];
}

- (void)serverReceivedPacket:(JSPongPacket *)packet fromPlayer:(JSPongPlayer *)player
{
	switch (packet.packetType)
	{
		case PacketTypeSignInResponse:
			if (_state == GameStateWaitingForSignIn)
			{
				player.name = ((JSPongPacketSignInResponse *)packet).playerName;
                
				if ([self receivedResponsesFromAllPlayers])
				{
					_state = GameStateWaitingForReady;
                    
					JSPongPacket *packet = [JSPongPacketServerReady packetWithPlayers:_players];
					[self sendPacketToAllClients:packet];
				}
            }
			break;
            
        case PacketTypeClientReady:
			if (_state == GameStateWaitingForReady && [self receivedResponsesFromAllPlayers])
			{
				[self beginGame];
			}
			break;
            
        case PacketTypeClientQuit:
			[self clientDidDisconnect:player.peerID];
			break;
            
		default:
			NSLog(@"Server received unexpected packet: %@", packet);
			break;
	}
}

- (void)clientReceivedPacket:(JSPongPacket *)packet
{
	switch (packet.packetType)
	{
		case PacketTypeSignInRequest:
			if (_state == GameStateWaitingForSignIn)
			{
				_state = GameStateWaitingForReady;
                
				JSPongPacket *packet = [JSPongPacketSignInResponse packetWithPlayerName:_localPlayerName];
				[self sendPacketToServer:packet];
			}
			break;
            
        case PacketTypeServerReady:
            if (_state == GameStateWaitingForReady)
			{
				_players = ((JSPongPacketServerReady *)packet).players;
				[self changeRelativePositionsOfPlayers];
                
				JSPongPacket *packet = [JSPongPacket packetWithType:PacketTypeClientReady];
				[self sendPacketToServer:packet];
                
				[self beginGame];
			}
			break;
            
        case PacketTypeOtherClientQuit:
			if (_state != GameStateQuitting)
			{
				JSPongPacketOtherClientQuit *quitPacket = ((JSPongPacketOtherClientQuit *)packet);
				[self clientDidDisconnect:quitPacket.peerID];
			}
			break;
            
        case PacketTypeServerQuit:
			[self quitGameWithReason:QuitReasonServerQuit];
			break;
            
		default:
			NSLog(@"Client received unexpected packet: %@", packet);
			break;
	}
}

#pragma mark - Networking

- (void)sendPacketToAllClients:(JSPongPacket *)packet
{
    [_players enumerateKeysAndObjectsUsingBlock:^(id key, JSPongPlayer *obj, BOOL *stop)
     {
         obj.receivedResponse = [_session.peerID isEqualToString:obj.peerID];
     }];
    
	GKSendDataMode dataMode = GKSendDataReliable;
	NSData *data = [packet data];
	NSError *error;
	if (![_session sendDataToAllPeers:data withDataMode:dataMode error:&error])
	{
		NSLog(@"Error sending data to clients: %@", error);
	}
}

- (void)sendPacketToServer:(JSPongPacket *)packet
{
	GKSendDataMode dataMode = GKSendDataReliable;
	NSData *data = [packet data];
	NSError *error;
	if (![_session sendData:data toPeers:[NSArray arrayWithObject:_serverPeerID] withDataMode:dataMode error:&error])
	{
		NSLog(@"Error sending data to server: %@", error);
	}
}

- (void)clientDidDisconnect:(NSString *)peerID
{
	if (_state != GameStateQuitting)
	{
		JSPongPlayer *player = [self playerWithPeerID:peerID];
		if (player != nil)
		{
			[_players removeObjectForKey:peerID];
            if (_state != GameStateWaitingForSignIn)
			{
				// Tell the other clients that this one is now disconnected.
				if (self.isServer)
				{
					JSPongPacketOtherClientQuit *packet = [JSPongPacketOtherClientQuit packetWithPeerID:peerID];
					[self sendPacketToAllClients:packet];
				}
                
				[self.delegate game:self playerDidDisconnect:player];
			}
		}
	}
}

@end
