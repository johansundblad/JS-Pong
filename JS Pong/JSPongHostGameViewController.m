//
//  JSPongHostGameViewController.m
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-16.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import "JSPongHostGameViewController.h"

@interface JSPongHostGameViewController ()
@property (nonatomic, weak) IBOutlet UILabel *headingLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *startButton;
@end

@implementation JSPongHostGameViewController
{
    JSPongServer *_pongServer;
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
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.nameTextField action:@selector(resignFirstResponder)];
	gestureRecognizer.cancelsTouchesInView = NO;
	[self.view addGestureRecognizer:gestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
	if (_pongServer == nil)
	{
		_pongServer = [[JSPongServer alloc] init];
        _pongServer.delegate = self;
		_pongServer.maxClients = 1;
		[_pongServer startAcceptingConnectionsForSessionID:SESSION_ID];
        
		self.nameTextField.placeholder = _pongServer.session.displayName;
		[self.tableView reloadData];
	}
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

- (IBAction)startAction:(id)sender
{
	if (_pongServer != nil && [_pongServer connectedClientCount] > 0)
	{
		NSString *name = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if ([name length] == 0)
			name = _pongServer.session.displayName;
        
		[_pongServer stopAcceptingConnections];
        
		[self.delegate hostViewController:self startGameWithSession:_pongServer.session playerName:name clients:_pongServer.connectedClients];
	}
}

- (IBAction)exitAction:(id)sender
{
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (_pongServer != nil)
		return [_pongServer connectedClientCount];
	else
		return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"CellIdentifier";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
	NSString *peerID = [_pongServer peerIDForConnectedClientAtIndex:indexPath.row];
	cell.textLabel.text = [_pongServer displayNameForPeerID:peerID];
    
	return cell;
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return NO;
}

#pragma mark - jSPongServerDelegate

- (void)pongServer:(JSPongServer *)server clientDidConnect:(NSString *)peerID
{
	[self.tableView reloadData];
}

- (void)pongServer:(JSPongServer *)server clientDidDisconnect:(NSString *)peerID
{
	[self.tableView reloadData];
}

@end
