//
//  JSPongPlayer.m
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-16.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import "JSPongPlayer.h"

@implementation JSPongPlayer

- (void)dealloc
{
#ifdef DEBUG
	NSLog(@"dealloc %@", self);
#endif
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ peerID = %@, name = %@", [super description], self.peerID, self.name];
}

@end
