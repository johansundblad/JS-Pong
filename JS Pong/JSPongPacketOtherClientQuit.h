//
//  JSPongPacketOtherClientQuit.h
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-17.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import "JSPongPacket.h"

@interface JSPongPacketOtherClientQuit : JSPongPacket

@property (nonatomic, copy) NSString *peerID;

+ (id)packetWithPeerID:(NSString *)peerID;

@end
