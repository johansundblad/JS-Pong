//
//  JSPongPacketSignInResponse.h
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-17.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import "JSPongPacket.h"

@interface JSPongPacketSignInResponse : JSPongPacket

@property (nonatomic, copy) NSString *playerName;

+ (id)packetWithPlayerName:(NSString *)playerName;

@end