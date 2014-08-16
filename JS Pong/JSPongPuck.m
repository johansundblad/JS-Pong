//
//  JSPongPuck.m
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-06.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import "JSPongPuck.h"

@implementation JSPongPuck

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)randomMove
{
    xMove = 1;
    yMove = 1;
}
- (void)wallBounce
{
    yMove = -yMove;
}
- (void)padBounce
{
    xMove = -xMove;
}

- (void)puckMove
{
    self.center = CGPointMake(self.center.x + xMove, self.center.y + yMove);
    //[self setFrame:CGRectMake( self.frame.origin.x + xMove, self.frame.origin.y + yMove, self.frame.size.width, self.frame.size.height)];
}

- (void)puckCenter
{
    self.center = CGPointMake(225, 170);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
