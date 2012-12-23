//
//  TUPUserDetailController.h
//  RestTest
//
//  Created by William Barksdale on 12/22/12.
//  Copyright (c) 2012 Tuple23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "TUPUser.h"

@interface TUPUserDetailController : UIViewController

// the user that we are going to viewing the details for
@property(nonatomic, retain) TUPUser *user;

// properties that are hooked up in the storyboards
@property(nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property(nonatomic, retain) IBOutlet UITextField *nameField;
@property(nonatomic, retain) IBOutlet UITextField *ageField;

-(IBAction)update:(id)sender;

@end
