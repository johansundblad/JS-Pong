//
//  JSPongPacket.m
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-17.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import "JSPongPacket.h"
#import "JSPongPacketSignInResponse.h"
#import "JSPongPacketServerReady.h"
#import "JSPongPacketOtherClientQuit.h"
#import "JSPongPacketMovePlayer.h"
#import "JSPongPacketClientMovedPlayer.h"
#import "NSData+JSPongAdditions.h"

const size_t PACKET_HEADER_SIZE = 10;

@implementation JSPongPacket

//@synthesize packetType = _packetType;

+ (id)packetWithType:(PacketType)packetType
{
	return [[[self class] alloc] initWithType:packetType];
}

+ (id)packetWithData:(NSData *)data
{
	if ([data length] < PACKET_HEADER_SIZE)
	{
		NSLog(@"Error: Packet too small");
		return nil;
	}
    
	if ([data rw_int32AtOffset:0] != 'PONG')
	{
		NSLog(@"Error: Packet has invalid header");
		return nil;
	}
    
	int packetNumber = [data rw_int32AtOffset:4];
	PacketType packetType = [data rw_int16AtOffset:8];
    
	JSPongPacket *packet;
    
	switch (packetType)
	{
		case PacketTypeSignInRequest:
        case PacketTypeClientReady:
        case PacketTypeServerQuit:
		case PacketTypeClientQuit:
			packet = [JSPongPacket packetWithType:packetType];
			break;
            
		case PacketTypeSignInResponse:
			packet = [JSPongPacketSignInResponse packetWithData:data];
			break;
            
        case PacketTypeServerReady:
			packet = [JSPongPacketServerReady packetWithData:data];
			break;
            
        case PacketTypeMovePlayer:
			packet = [JSPongPacketMovePlayer packetWithData:data];
			break;

        case PacketTypeClientMovedPlayer:
			packet = [JSPongPacketClientMovedPlayer packetWithData:data];
			break;
            
        case PacketTypeOtherClientQuit:
			packet = [JSPongPacketOtherClientQuit packetWithData:data];
			break;
            
		default:
			NSLog(@"Error: Packet has invalid type");
			return nil;
	}
    
	return packet;
}

- (void)addPayloadToData:(NSMutableData *)data
{
	// base class does nothing
}

- (id)initWithType:(PacketType)packetType
{
	if ((self = [super init]))
	{
		self.packetType = packetType;
	}
	return self;
}

- (NSData *)data
{
	NSMutableData *data = [[NSMutableData alloc] initWithCapacity:100];
    
	[data rw_appendInt32:'PONG'];   // 0x534E4150
	[data rw_appendInt32:0];
	[data rw_appendInt16:self.packetType];
    
    [self addPayloadToData:data];
	return data;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@, type=%d", [super description], self.packetType];
}

@end
