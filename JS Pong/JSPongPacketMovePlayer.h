
#import "JSPongPacket.h"

@interface JSPongPacketMovePlayer : JSPongPacket

@property (nonatomic, copy) NSString *peerID;
@property (nonatomic, assign) CGPoint position;

+ (id)packetWithPeerID:(NSString *)peerID position:(CGPoint)position;

@end
