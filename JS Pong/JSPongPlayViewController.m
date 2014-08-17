//
//  JSPongPlayViewController.m
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-06.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import "JSPongPlayViewController.h"

@interface JSPongPlayViewController ()

@end

@implementation JSPongPlayViewController

@synthesize moveSlider, myPad, opponentPad, playGround, puck, myGoals, opponentGoals;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *superView = self.moveSlider.superview;
    [self.moveSlider removeFromSuperview];
    [self.moveSlider removeConstraints:self.view.constraints];
    self.moveSlider.translatesAutoresizingMaskIntoConstraints = YES;
    self.moveSlider.transform = CGAffineTransformMakeRotation(M_PI_2);
    [superView addSubview:self.moveSlider];

    // Do any additional setup after loading the view.
    myGoals = 0;
    opponentGoals = 0;
    [self faceOff];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)moveSliderMoves:(UISlider *)sender {
    float theValue = sender.value;
    
    NSLog(@"move = %f", theValue);
    
    [myPad setFrame:CGRectMake( myPad.frame.origin.x, (300 * theValue), myPad.frame.size.width, myPad.frame.size.height)];
}

- (void)faceOff
{
    NSLog(@"faceOff");
    
    [puck puckCenter];
    [puck randomMove];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(gameLoop) userInfo:nil repeats:YES];
}

- (void)opponentMove
{
    if (puck.center.y > opponentPad.center.y) {
        opponentPad.center = CGPointMake(opponentPad.center.x, opponentPad.center.y + 1);
    } else {
        opponentPad.center = CGPointMake(opponentPad.center.x, opponentPad.center.y - 1);
    }
    
}

- (void)gameLoop
{
    [puck puckMove];
    [self opponentMove];
    if ((puck.frame.origin.y < playGround.frame.origin.y) || (puck.frame.origin.y > playGround.frame.origin.y + playGround.frame.size.height))
    {
        [puck wallBounce];
    }
    
    if (CGRectIntersectsRect(puck.frame, myPad.frame)) {
        [puck padBounce];
    }
    
    if (CGRectIntersectsRect(puck.frame, opponentPad.frame)){
        [puck padBounce];
    }
    

    if (puck.frame.origin.x < playGround.frame.origin.x)
    {
        [self goal:true];
    }
    if (puck.frame.origin.x > playGround.frame.origin.x + playGround.frame.size.width)
    {
        [self goal:false];
    }
 //   opponentGoals.center.y = 100;
//    opponentGoals.center.y = opponentGoals.center.y + 1;
}

- (void)goal:(BOOL)myGoal {
    NSLog(@"Goal: %i-%i", opponentGoalsNum, myGoalsNum);
    if (myGoal) {
        myGoalsNum += 1;
    } else {
        opponentGoalsNum += 1;
    }
    [[self myGoals] setText: [NSString stringWithFormat:@"%i", myGoalsNum]];
    [[self opponentGoals] setText: [NSString stringWithFormat:@"%i", opponentGoalsNum]];
    [timer invalidate];
    timer = nil;
    [self faceOff];
}

#pragma mark - JSPongGameDelegate

- (void)gameWaitingForServerReady:(JSPongGame *)game
{
	// self.centerLabel.text = NSLocalizedString(@"Waiting for game to start...", @"Status text: waiting for server");
}

- (void)gameWaitingForClientsReady:(JSPongGame *)game
{
	// self.centerLabel.text = NSLocalizedString(@"Waiting for other players...", @"Status text: waiting for clients");
}

@end
