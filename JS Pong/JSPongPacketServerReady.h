//
//  JSPongPacketServerReady.h
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-17.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import "JSPongPacket.h"

@interface JSPongPacketServerReady : JSPongPacket

@property (nonatomic, strong) NSMutableDictionary *players;

+ (id)packetWithPlayers:(NSMutableDictionary *)players;

@end
