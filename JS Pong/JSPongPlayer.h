//
//  JSPongPlayer.h
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-16.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSPongPlayer : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *peerID;
@property (nonatomic, assign) BOOL receivedResponse;

@end
