//
//  JSPongPacketSignInResponse.m
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-17.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import "JSPongPacketSignInResponse.h"
#import "NSData+JSPongAdditions.h"

@implementation JSPongPacketSignInResponse

+ (id)packetWithPlayerName:(NSString *)playerName
{
	return [[[self class] alloc] initWithPlayerName:playerName];
}

- (id)initWithPlayerName:(NSString *)playerName
{
	if ((self = [super initWithType:PacketTypeSignInResponse]))
	{
		self.playerName = playerName;
	}
	return self;
}

+ (id)packetWithData:(NSData *)data
{
	size_t count;
	NSString *playerName = [data rw_stringAtOffset:PACKET_HEADER_SIZE bytesRead:&count];
	return [[self class] packetWithPlayerName:playerName];
}

- (void)addPayloadToData:(NSMutableData *)data
{
	[data rw_appendString:self.playerName];
}

@end

