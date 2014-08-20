//
//  JSPongPlayGameViewController.m
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-17.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import "JSPongPlayGameViewController.h"
#import "JSPongPuck.h"

@interface JSPongPlayGameViewController ()

@property (nonatomic, weak) IBOutlet UILabel *infoLabel;

@property (nonatomic, weak) IBOutlet UIImageView *myPad;
@property (nonatomic, weak) IBOutlet UIImageView *opponentPad;
@property (nonatomic, weak) IBOutlet UIImageView *playGround;
@property (nonatomic, weak) IBOutlet UILabel *myGoals;
@property (nonatomic, weak) IBOutlet UILabel *opponentGoals;
@property (nonatomic, weak) IBOutlet UISlider *moveSlider;
@property (nonatomic, weak) IBOutlet JSPongPuck *puck;

@end

@implementation JSPongPlayGameViewController
{
    UIAlertView *_alertView;
    int myGoalsNum;
    int opponentGoalsNum;
    NSTimer *timer;
}

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
    // Do any additional setup after loading the view.
    UIView *superView = self.moveSlider.superview;
    [self.moveSlider removeFromSuperview];
    [self.moveSlider removeConstraints:self.view.constraints];
    self.moveSlider.translatesAutoresizingMaskIntoConstraints = YES;
    self.moveSlider.transform = CGAffineTransformMakeRotation(M_PI_2);
    [superView addSubview:self.moveSlider];
    
    myGoalsNum = 0;
    opponentGoalsNum = 0;
    //[self faceOff];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
	[_alertView dismissWithClickedButtonIndex:_alertView.cancelButtonIndex animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)exitAction:(id)sender
{
	if (self.game.isServer)
	{
		_alertView = [[UIAlertView alloc]
                      initWithTitle:NSLocalizedString(@"End Game?", @"Alert title (user is host)")
                      message:NSLocalizedString(@"This will terminate the game for all other players.", @"Alert message (user is host)")
                      delegate:self
                      cancelButtonTitle:NSLocalizedString(@"No", @"Button: No")
                      otherButtonTitles:NSLocalizedString(@"Yes", @"Button: Yes"),
                      nil];
        
		[_alertView show];
	}
	else
	{
		_alertView = [[UIAlertView alloc]
                      initWithTitle: NSLocalizedString(@"Leave Game?", @"Alert title (user is not host)")
                      message:nil
                      delegate:self
                      cancelButtonTitle:NSLocalizedString(@"No", @"Button: No")
                      otherButtonTitles:NSLocalizedString(@"Yes", @"Button: Yes"),
                      nil];
        
		[_alertView show];
	}
}

- (IBAction)moveSliderMoves:(UISlider *)sender {
    float theValue = sender.value;
    NSLog(@"move = %f", theValue);
    
//    [self.game playerMovedPadToPosition: CGRectMake( _myPad.frame.origin.x, (300 * theValue), _myPad.frame.size.width, _myPad.frame.size.height)];
    
    [self.game playerMovedPadToPosition: CGPointMake(_myPad.frame.origin.x, (300 * theValue))];
    
    //[_myPad setFrame:CGRectMake( _myPad.frame.origin.x, (300 * theValue), _myPad.frame.size.width, _myPad.frame.size.height)];
}

/*

- (void)faceOff
{
    NSLog(@"faceOff");
    
    [_puck puckCenter];
    [_puck randomMove];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(gameLoop) userInfo:nil repeats:YES];
}

- (void)opponentMove
{
    if (_puck.center.y > _opponentPad.center.y) {
        _opponentPad.center = CGPointMake(_opponentPad.center.x, _opponentPad.center.y + 1);
    } else {
        _opponentPad.center = CGPointMake(_opponentPad.center.x, _opponentPad.center.y - 1);
    }
}

- (void)gameLoop
{
    [_puck puckMove];
    //[self opponentMove];
    if ((_puck.frame.origin.y < _playGround.frame.origin.y) || (_puck.frame.origin.y > _playGround.frame.origin.y + _playGround.frame.size.height))
    {
        [_puck wallBounce];
    }
    
    if (CGRectIntersectsRect(_puck.frame, _myPad.frame)) {
        [_puck padBounce];
    }
    
    if (CGRectIntersectsRect(_puck.frame, _opponentPad.frame)){
        [_puck padBounce];
    }
    
    
    if (_puck.frame.origin.x < _playGround.frame.origin.x)
    {
        [self goal:true];
    }
    if (_puck.frame.origin.x > _playGround.frame.origin.x + _playGround.frame.size.width)
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
 
*/

#pragma mark - JSPongGameDelegate

- (void)gameWaitingForServerReady:(JSPongGame *)game
{
    self.infoLabel.text = NSLocalizedString(@"Waiting for game to start...", @"Status text: waiting for server");
}

- (void)gameWaitingForClientsReady:(JSPongGame *)game
{
    self.infoLabel.text = NSLocalizedString(@"Waiting for other players...", @"Status text: waiting for clients");
}

- (void)gameDidSetup:(JSPongGame *)game
{
     [self.game setupPlayGroundWithRect:(CGRect) _playGround.frame];
}

- (void)gameDidBegin:(JSPongGame *)game
{
    [self.game faceOff];
}

- (void)game:(JSPongGame *)game didMovePlayer:(JSPongPlayer *)player toPosition:(CGPoint)playerPosition
{
    NSLog(@"didMovePlayer player.isMyPlayer=%@", player.isMyPlayer ? @"YES" : @"NO");
    if (player.isMyPlayer) {
        _myPad.center = CGPointMake(_myPad.center.x, playerPosition.y);
    }
    else
    {
        _opponentPad.center = CGPointMake(_opponentPad.center.x, playerPosition.y);
    }
}

- (void)game:(JSPongGame *)game didMovePuckToPosition:(CGPoint)puckPosition
{
    _puck.center = puckPosition;
}

- (void)game:(JSPongGame *)game didQuitWithReason:(QuitReason)reason
{
    [self.delegate gameViewController:self didQuitWithReason:reason];
}

- (void)game:(JSPongGame *)game playerDidDisconnect:(JSPongPlayer *)disconnectedPlayer
{
    /*
	[self hidePlayerLabelsForPlayer:disconnectedPlayer];
	[self hideActiveIndicatorForPlayer:disconnectedPlayer];
    */
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != alertView.cancelButtonIndex)
	{
		[self.game quitGameWithReason:QuitReasonUserQuit];
	}
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

@end
