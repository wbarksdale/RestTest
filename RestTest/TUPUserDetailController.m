//
//  TUPUserDetailController.m
//  RestTest
//
//  Created by William Barksdale on 12/22/12.
//  Copyright (c) 2012 Tuple23. All rights reserved.
//

#import "TUPUserDetailController.h"

@implementation TUPUserDetailController

// update the user on the server
-(IBAction)update:(id)sender{
    
    // update our user model object
    self.user.name = self.nameField.text;
    // age field should really be "sanitized"
    self.user.age = [NSNumber numberWithInteger:[self.ageField.text integerValue]];
    
    
    // and to the cloud!
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager postObject:self.user
                         path: [NSString stringWithFormat:@"user/%@", self.user.username]
                   parameters:nil
                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                          NSLog(@"success");
                      } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                          message:[error localizedDescription]
                                                                         delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil];
                          [alert show];
                          NSLog(@"Hit error: %@", error);
                      }];
}

// set up all our labels and text fields
-(void) viewDidLoad {
    self.usernameLabel.text = self.user.username;
    self.nameField.text = self.user.name;
    self.ageField.text = [self.user.age stringValue];
}

@end
