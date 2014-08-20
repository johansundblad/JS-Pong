
#import "JSPongPacket.h"

@interface JSPongPacketClientMovedPlayer : JSPongPacket

@property (nonatomic, copy) NSString *peerID;
@property (nonatomic, assign) CGPoint position;

+ (id)packetWithPeerID:(NSString *)peerID position:(CGPoint)position;

@end
