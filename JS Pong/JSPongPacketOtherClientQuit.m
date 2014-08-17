//
//  JSPongPacketOtherClientQuit.m
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-17.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import "JSPongPacketOtherClientQuit.h"
#import "NSData+JSPongAdditions.h"

@implementation JSPongPacketOtherClientQuit

+ (id)packetWithPeerID:(NSString *)peerID
{
	return [[[self class] alloc] initWithPeerID:peerID];
}

- (id)initWithPeerID:(NSString *)peerID
{
	if ((self = [super initWithType:PacketTypeOtherClientQuit]))
	{
		self.peerID = peerID;
	}
	return self;
}

+ (id)packetWithData:(NSData *)data
{
	size_t offset = PACKET_HEADER_SIZE;
	size_t count;
    
	NSString *peerID = [data rw_stringAtOffset:offset bytesRead:&count];
    
	return [[self class] packetWithPeerID:peerID];
}

- (void)addPayloadToData:(NSMutableData *)data
{
	[data rw_appendString:self.peerID];
}

@end
