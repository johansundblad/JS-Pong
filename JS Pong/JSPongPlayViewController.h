//
//  JSPongPlayViewController.h
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-06.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSPongPuck.h"

int myGoalsNum;
int opponentGoalsNum;

@interface JSPongPlayViewController : UIViewController
{
    IBOutlet UIImageView *myPad;
    IBOutlet UIImageView *opponentPad;
    IBOutlet UIImageView *playGround;
    IBOutlet UILabel *myGoals;
    IBOutlet UILabel *opponentGoals;
    IBOutlet UISlider *moveSlider;
    IBOutlet JSPongPuck *puck;
    
    NSTimer *timer;
}


@property (nonatomic, strong) IBOutlet UIImageView *myPad;
@property (nonatomic, strong) IBOutlet UIImageView *opponentPad;
@property (nonatomic, strong) IBOutlet UIImageView *playGround;
@property (nonatomic, strong) IBOutlet UILabel *myGoals;
@property (nonatomic, strong) IBOutlet UILabel *opponentGoals;
@property (nonatomic, strong) IBOutlet UISlider *moveSlider;
@property (nonatomic, strong) IBOutlet JSPongPuck *puck;

- (IBAction)moveSliderMoves:(UISlider *)sender;
- (void)gameLoop;

@end
