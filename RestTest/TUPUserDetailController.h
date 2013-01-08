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

@interface TUPUserDetailController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>

// the user that we are going to viewing the details for
@property(nonatomic, strong) TUPUser *user;

// properties that are hooked up in the storyboards
@property(nonatomic, strong) IBOutlet UILabel *usernameLabel;
@property(nonatomic, strong) IBOutlet UITextField *nameField;
@property(nonatomic, strong) IBOutlet UITextField *ageField;
@property(nonatomic, strong) IBOutlet UIImageView *userImage;

-(IBAction)update:(id)sender;
-(void)takeImage;

@end
