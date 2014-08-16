//
//  JSPongPuck.h
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-06.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import <UIKit/UIKit.h>

int xMove;
int yMove;
//int bounceAngle;

@interface JSPongPuck : UIImageView

- (void)puckCenter;
- (void)puckMove;
- (void)randomMove;
- (void)wallBounce;
- (void)padBounce;

@end
