//
//  JSPongJoinGameViewController.m
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-16.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import "JSPongJoinGameViewController.h"

@interface JSPongJoinGameViewController ()
@property (nonatomic, weak) IBOutlet UILabel *headingLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation JSPongJoinGameViewController
{
	JSPongClient *_pongClient;
    QuitReason _quitReason;
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
    
	if (_pongClient == nil)
	{
        _quitReason = QuitReasonConnectionDropped;
        
		_pongClient = [[JSPongClient alloc] init];
        _pongClient.delegate = self;
		[_pongClient startSearchingForServersWithSessionID:SESSION_ID];
        
		self.nameTextField.placeholder = _pongClient.session.displayName;
		[self.tableView reloadData];
	}
}

- (IBAction)exitAction:(id)sender
{
	_quitReason = QuitReasonUserQuit;
	[_pongClient disconnectFromServer];
	[self.delegate joinViewControllerDidCancel:self];
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (_pongClient != nil)
		return [_pongClient availableServerCount];
	else
		return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"CellIdentifier";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
	NSString *peerID = [_pongClient peerIDForAvailableServerAtIndex:indexPath.row];
	cell.textLabel.text = [_pongClient displayNameForPeerID:peerID];
    
	return cell;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return NO;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
	if (_pongClient != nil)
	{
		NSString *peerID = [_pongClient peerIDForAvailableServerAtIndex:indexPath.row];
		[_pongClient connectToServerWithPeerID:peerID];
	}
}

#pragma mark - JSPongClientDelegate

- (void)pongClient:(JSPongClient *)client serverBecameAvailable:(NSString *)peerID
{
	[self.tableView reloadData];
}

- (void)pongClient:(JSPongClient *)client serverBecameUnavailable:(NSString *)peerID
{
	[self.tableView reloadData];
}

- (void)pongClient:(JSPongClient *)client didDisconnectFromServer:(NSString *)peerID
{
	_pongClient.delegate = nil;
	_pongClient = nil;
	[self.tableView reloadData];
	[self.delegate joinViewController:self didDisconnectWithReason:_quitReason];
}
- (void)pongClient:(JSPongClient *)client didConnectToServer:(NSString *)peerID
{
	NSString *name = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([name length] == 0)
		name = _pongClient.session.displayName;
    
	[self.delegate joinViewController:self startGameWithSession:_pongClient.session playerName:name server:peerID];
}
- (void)pongClient:(JSPongClient *)client
{
	_quitReason = QuitReasonNoNetwork;
}
@end
