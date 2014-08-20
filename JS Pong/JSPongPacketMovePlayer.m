
#import "JSPongPacketMovePlayer.h"
#import "JSPongPlayer.h"
#import "NSData+JSPongAdditions.h"

@implementation JSPongPacketMovePlayer

+ (id)packetWithPeerID:(NSString *)peerID position:(CGPoint)position
{
	return [[[self class] alloc] initWithPeerID:peerID position:position];
}

- (id)initWithPeerID:(NSString *)peerID position:(CGPoint)position
{
	if ((self = [super initWithType:PacketTypeMovePlayer]))
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
    NSString *xPos = [data rw_stringAtOffset:offset bytesRead:&count];
	offset += count;
    NSString *yPos = [data rw_stringAtOffset:offset bytesRead:&count];
	offset += count;
    
    CGPoint position = CGPointMake(xPos.intValue, yPos.intValue);
	return [[self class] packetWithPeerID:peerID position:position];
}

- (void)addPayloadToData:(NSMutableData *)data
{
	[data rw_appendString:self.peerID];
    [data rw_appendString:[NSString stringWithFormat:@"%d", (int)self.position.x]];
    [data rw_appendString:[NSString stringWithFormat:@"%d", (int)self.position.y]];
}

@end
