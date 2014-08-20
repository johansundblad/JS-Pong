//
//  JSPongMenuViewController.m
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-06.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import "JSPongMenuViewController.h"
#import "JSPongGame.h"

@interface JSPongMenuViewController ()
@property (nonatomic, weak) IBOutlet UIButton *hostGameButton;
@property (nonatomic, weak) IBOutlet UIButton *joinGameButton;
@property (nonatomic, weak) IBOutlet UIButton *singlePlayerGameButton;
@end

@implementation JSPongMenuViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)showNoNetworkAlert
{
	UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"No Network", @"No network alert title")
                              message:NSLocalizedString(@"To use multiplayer, please enable Bluetooth or Wi-Fi in your device's Settings.", @"No network alert message")
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"Button: OK")
                              otherButtonTitles:nil];
    
	[alertView show];
}

- (void)showDisconnectedAlert
{
	UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Disconnected", @"Client disconnected alert title")
                              message:NSLocalizedString(@"You were disconnected from the game.", @"Client disconnected alert message")
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"Button: OK")
                              otherButtonTitles:nil];
    
	[alertView show];
}
- (void)startGameWithBlock:(void (^)(JSPongGame *))block
{
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                  bundle:nil];
    JSPongPlayGameViewController *gameViewController = [sb instantiateViewControllerWithIdentifier:@"JSPongPlayGameViewController"];

	gameViewController.delegate = self;
	[self presentViewController:gameViewController animated:NO completion:^
     {
         JSPongGame *game = [[JSPongGame alloc] init];
         gameViewController.game = game;
         game.delegate = gameViewController;
         block(game);
     }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue: %@", segue.identifier);
    if([segue.identifier isEqualToString:@"SingleGame"])
    {
        JSPongPlayGameViewController *playGameVC = (JSPongPlayGameViewController *) segue.destinationViewController;
        playGameVC.delegate = self;
        
    }
    else if([segue.identifier isEqualToString:@"HostGame"])
    {
        JSPongHostGameViewController *hostGameVC = (JSPongHostGameViewController *) segue.destinationViewController;
        hostGameVC.delegate = self;
        
    }
    else if([segue.identifier isEqualToString:@"JoinGame"])
    {
        JSPongJoinGameViewController *joinGameVC = (JSPongJoinGameViewController *) segue.destinationViewController;
        joinGameVC.delegate = self;
        
    }
}

#pragma mark - JSPongHostGameViewControllerDelegate

- (void)hostViewControllerDidCancel:(JSPongHostGameViewController *)controller
{
	[self dismissViewControllerAnimated:NO completion:nil];
}

- (void)hostViewController:(JSPongHostGameViewController *)controller didEndSessionWithReason:(QuitReason)reason
{
	if (reason == QuitReasonNoNetwork)
	{
		[self showNoNetworkAlert];
	}
}

- (void)hostViewController:(JSPongHostGameViewController *)controller startGameWithSession:(GKSession *)session playerName:(NSString *)name clients:(NSArray *)clients
{
    [self startGameWithBlock:^(JSPongGame *game)
    {
        [game startServerGameWithSession:session playerName:name clients:clients];
    }];
}

#pragma mark - JSPongJoinGameViewControllerDelegate

- (void)joinViewControllerDidCancel:(JSPongJoinGameViewController *)controller
{
	[self dismissViewControllerAnimated:NO completion:nil];
}

- (void)joinViewController:(JSPongJoinGameViewController *)controller didDisconnectWithReason:(QuitReason)reason
{
	// The "No Wi-Fi/Bluetooth" alert does not close the Join screen,
	// but the "Connection Dropped" disconnect does.
    
	if (reason == QuitReasonNoNetwork)
	{
		[self showNoNetworkAlert];
	}
	else if (reason == QuitReasonConnectionDropped)
	{
		[self dismissViewControllerAnimated:NO completion:^
         {
             [self showDisconnectedAlert];
         }];
	}
}

- (void)joinViewController:(JSPongJoinGameViewController *)controller startGameWithSession:(GKSession *)session playerName:(NSString *)name server:(NSString *)peerID
{
    [self startGameWithBlock:^(JSPongGame *game)
    {
        [game startClientGameWithSession:session playerName:name server:peerID];
    }];
}

#pragma mark - JSPongPlayGameViewControllerDelegate

- (void)gameViewController:(JSPongPlayGameViewController *)controller didQuitWithReason:(QuitReason)reason
{
	[self dismissViewControllerAnimated:NO completion:^
     {
         if (reason == QuitReasonConnectionDropped)
         {
             [self showDisconnectedAlert];
         }
     }];
}

@end
