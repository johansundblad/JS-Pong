//
//  JSPongPacketServerReady.m
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-17.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import "JSPongPacketServerReady.h"
#import "NSData+JSPongAdditions.h"
#import "JSPongPlayer.h"

@implementation JSPongPacketServerReady

+ (id)packetWithPlayers:(NSMutableDictionary *)players
{
	return [[[self class] alloc] initWithPlayers:players];
}

+ (id)packetWithData:(NSData *)data
{
	NSMutableDictionary *players = [NSMutableDictionary dictionaryWithCapacity:4];
    
	size_t offset = PACKET_HEADER_SIZE;
	size_t count;
    
	int numberOfPlayers = [data rw_int8AtOffset:offset];
	offset += 1;
    
	for (int t = 0; t < numberOfPlayers; ++t)
	{
		NSString *peerID = [data rw_stringAtOffset:offset bytesRead:&count];
		offset += count;
        
		NSString *name = [data rw_stringAtOffset:offset bytesRead:&count];
		offset += count;
        
		//PlayerPosition position = [data rw_int8AtOffset:offset];
		offset += 1;
        
		JSPongPlayer *player = [[JSPongPlayer alloc] init];
		player.peerID = peerID;
		player.name = name;
		//player.position = position;
		[players setObject:player forKey:player.peerID];
	}
    
	return [[self class] packetWithPlayers:players];
}

- (id)initWithPlayers:(NSMutableDictionary *)players
{
	if ((self = [super initWithType:PacketTypeServerReady]))
	{
		self.players = players;
	}
	return self;
}

- (void)addPayloadToData:(NSMutableData *)data
{
	[data rw_appendInt8:[self.players count]];
    
	[self.players enumerateKeysAndObjectsUsingBlock:^(id key, JSPongPlayer *player, BOOL *stop)
     {
         [data rw_appendString:player.peerID];
         [data rw_appendString:player.name];
         // [data rw_appendInt8:player.position];
     }];
}

@end
