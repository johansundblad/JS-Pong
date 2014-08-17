//
//  JSPongMenuViewController.h
//  JS Pong
//
//  Created by Johan Sundblad on 2014-08-06.
//  Copyright (c) 2014 Johan Sundblad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSPongHostGameViewController.h"
#import "JSPongJoinGameViewController.h"
#import "JSPongPlayGameViewController.h"

@interface JSPongMenuViewController : UIViewController <JSPongHostGameViewControllerDelegate, JSPongJoinGameViewControllerDelegate, JSPongPlayGameViewControllerDelegate>

@end
