
#import "JSPongPacketClientMovedPlayer.h"
#import "JSPongPlayer.h"
#import "NSData+JSPongAdditions.h"

@implementation JSPongPacketClientMovedPlayer

+ (id)packetWithPeerID:(NSString *)peerID position:(CGPoint)position
{
	return [[[self class] alloc] initWithPeerID:peerID position:position];
}

- (id)initWithPeerID:(NSString *)peerID position:(CGPoint)position
{
	if ((self = [super initWithType:PacketTypeClientMovedPlayer]))
	{
		self.peerID = peerID;
		self.position = position;
	}
	return self;
}

+ (id)packetWithData:(NSData *)data
{
	size_t offset = PACKET_HEADER_SIZE;
	size_t count;

	NSString *peerID = [data rw_stringAtOffset:offset bytesRead:&count];
	offset += count;

	int xPosition = [data rw_int32AtOffset:offset];
    offset += 4;
    int yPosition = [data rw_int32AtOffset:offset];
    
    CGPoint position = CGPointMake(xPosition, yPosition);
    NSLog(@"JSPongPacketClientMovedPlayer packetWithData x = %f, y = %f", position.x, position.y);


	return [[self class] packetWithPeerID:peerID position:position];
}

- (void)addPayloadToData:(NSMutableData *)data
{
	[data rw_appendString:self.peerID];
	[data rw_appendInt32:(int)self.position.x];
    [data rw_appendInt32:(int)self.position.y];
}

@end
