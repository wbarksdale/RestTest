//
//  TUPViewController.h
//  RestTest
//
//  Created by William Barksdale on 12/21/12.
//  Copyright (c) 2012 Tuple23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

@interface TUPViewController : UITableViewController

@property(nonatomic, retain) NSMutableArray *users;

- (IBAction)addUser:(id)sender;

@end
