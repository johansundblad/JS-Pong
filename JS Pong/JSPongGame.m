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
#import "JSPongPacketMovePlayer.h"
#import "JSPongPacketClientMovedPlayer.h"

typedef enum
{
	GameStateWaitingForSignIn,
	GameStateWaitingForReady,
    GameStateSetup,
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
    CGPoint _puckPosition;
    CGPoint _puckOrigin;
    CGRect _playGroundRect;
    NSTimer *timer;
}

- (id)init
{
	if ((self = [super init]))
	{
		_players = [NSMutableDictionary dictionaryWithCapacity:2];
        _puckPosition = CGPointMake(0, 0);
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

- (JSPongPlayer *) myPlayer
{
    return [self playerWithPeerID:_session.peerID];
}

- (JSPongPlayer *) opponentPlayer
{
    JSPongPlayer *myPlayer = [self playerWithPeerID:_session.peerID];
    
    for(id key in _players) {
        if (_players[key] != myPlayer)
        {
            return _players[key];
        }
    }
    return nil;
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

- (void)setupGame
{
	_state = GameStateSetup;

	[self.delegate gameDidSetup:self];
}

- (void)beginGame
{
	_state = GameStateFaceOff;
    
	[self.delegate gameDidBegin:self];
}

- (void)faceOff
{
    _state = GameStatePlaying;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(gameLoop) userInfo:nil repeats:YES];
}

- (void)gameLoop
{

    NSAssert(self.isServer, @"Must be server");

    /*
    [_puck puckMove];
    //[self opponentMove];
    if ((_puck.frame.origin.y < _playGround.frame.origin.y) || (_puck.frame.origin.y > _playGround.frame.origin.y + _playGround.frame.size.height))
    {
        [_puck wallBounce];
    }
    
    if (CGRectIntersectsRect(_puck.frame, _myPad.frame)) {
        [_puck padBounce];
    }
    
    if (CGRectIntersectsRect(_puck.frame, _opponentPad.frame)){
        [_puck padBounce];
    }
    
    
    if (_puck.frame.origin.x < _playGround.frame.origin.x)
    {
        [self goal:true];
    }
    if (_puck.frame.origin.x > _playGround.frame.origin.x + _playGround.frame.size.width)
    {
        [self goal:false];
    }
    //   opponentGoals.center.y = 100;
    //    opponentGoals.center.y = opponentGoals.center.y + 1;
     */
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





- (void)playerMovedPadToPosition:(CGPoint) position
{
    NSLog(@"playerMovedPadToPosition peer = %@, x = %f, y = %f", _session.peerID, position.x, position.y);
    if (self.isServer)
    {
        JSPongPlayer *player = [self playerWithPeerID:_session.peerID];
        player.position = position;
        JSPongPacket *packet = [JSPongPacketMovePlayer packetWithPeerID:_session.peerID position:position];
        [self sendPacketToAllClients:packet];
        [self handleMovePlayer:(JSPongPacketMovePlayer *)packet];
    }
    else
    {
        NSString *peerID = _session.peerID;
        JSPongPacket* packet = [JSPongPacketClientMovedPlayer packetWithPeerID:peerID position:position];
        [self sendPacketToServer:packet];
    }
}

- (void)setupPlayGroundWithRect:(CGRect) playGroundRect
{
    if (self.isServer) {
        NSLog(@"setupPlayGroundWithRect %f, %f, %f, %f", playGroundRect.origin.x, playGroundRect.origin.y,
              playGroundRect.size.width, playGroundRect.size.height);
    
        _playGroundRect = playGroundRect;
        _puckOrigin = CGPointMake((_playGroundRect.origin.x + _playGroundRect.size.width / 2), (_playGroundRect.origin.y + _playGroundRect.size.height / 2));
        int padMargin = (_playGroundRect.size.width / 20);
        [self myPlayer].position = CGPointMake((_playGroundRect.size.width - padMargin), (_playGroundRect.origin.y + _playGroundRect.size.height / 2));
        [self myPlayer].isMyPlayer = true;
        [self opponentPlayer].position = CGPointMake(padMargin, (_playGroundRect.origin.y + _playGroundRect.size.height / 2));
        
        [self.delegate game:self didMovePlayer:[self myPlayer] toPosition:[self myPlayer].position];
        [self.delegate game:self didMovePlayer:[self opponentPlayer] toPosition:[self opponentPlayer].position];
        
        JSPongPacket *myPlayerPacket = [JSPongPacketMovePlayer packetWithPeerID:[self myPlayer].peerID position:[self myPlayer].position];
        [self sendPacketToAllClients:myPlayerPacket];
        
        JSPongPacket *opponentPlayerPacket = [JSPongPacketMovePlayer packetWithPeerID:[self opponentPlayer].peerID position:[self opponentPlayer].position];
        [self sendPacketToAllClients:opponentPlayerPacket];

    
        [self beginGame];
    }
}


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
				[self setupGame];
			}
			break;
            
        case PacketTypeClientMovedPlayer:
            // Check if correct state.
            //if (_state == GameStatePlaying)
			{
                
                NSString *peerID = ((JSPongPacketClientMovedPlayer *)packet).peerID;
                JSPongPlayer *player = [self playerWithPeerID:peerID];
                player.position = ((JSPongPacketClientMovedPlayer *)packet).position;
                NSLog(@"PacketTypeClientMovedPlayer player.position x = %f, y = %f", player.position.x, player.position.y);


                JSPongPacket *packet = [JSPongPacketMovePlayer packetWithPeerID:peerID position:player.position];
                [self handleMovePlayer:(JSPongPacketMovePlayer *)packet];
                //if (self.isServer)
                //{
                    [self sendPacketToAllClients:packet];
                //}
 
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
                
				[self setupGame];
			}
			break;
            
        case PacketTypeMovePlayer:
            // Check if correct state.
            //if (_state == GameStatePlaying)
			{
				[self handleMovePlayer:(JSPongPacketMovePlayer *)packet];
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

- (void)handleMovePlayer:(JSPongPacketMovePlayer *)packet
{
	NSString *peerID = packet.peerID;
	CGPoint position = packet.position;
    
    NSLog(@"handleMovePlayer peer = %@ x = %f, y = %f", peerID, position.x, position.y);

    
	JSPongPlayer *player = [self playerWithPeerID:peerID];
	if (player != nil)
	{
        player.position = position;
        player.isMyPlayer = [peerID isEqual:_session.peerID];
        [self.delegate game:self didMovePlayer:player toPosition:position];
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
#ifdef DEBUG
	NSLog(@"Game: send data from peer: %@, data: %@, length: %lu", _session.peerID, data, (unsigned long)[data length]);
#endif
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
