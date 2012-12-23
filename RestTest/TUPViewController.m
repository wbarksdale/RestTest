//
//  TUPViewController.m
//  RestTest
//
//  Created by William Barksdale on 12/21/12.
//  Copyright (c) 2012 Tuple23. All rights reserved.
//

#import "TUPViewController.h"
#import "TUPUser.h"
#import "TUPUserDetailController.h"

// Private Methods
@interface TUPViewController ()
-(void)loadUsers;
-(void)deleteUser: (TUPUser *) user;
@end



@implementation TUPViewController

- (void)loadUsers {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager getObjectsAtPath:@"users"
                         parameters:nil
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                self.users = [[mappingResult array] mutableCopy];
                                NSLog(@"Loaded users: %@", self.users);
                                if(self.isViewLoaded)
                                    [self.tableView reloadData];
                            }
                            failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                message:[error localizedDescription]
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles:nil];
                                [alert show];
                                NSLog(@"Hit error: %@", error);
                            }];
}

- (void)deleteUser: (TUPUser *) user {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager deleteObject:user
                           path:[NSString stringWithFormat:@"/user/%@", user.username]
                     parameters:nil
                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                            NSLog(@"success");
                            [self.users removeObject:user];
                            [self.tableView reloadData];
                            if(self.isViewLoaded)
                                [self.tableView reloadData];
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

/********************
 * addUser is called when the user taps the "+" button
 * addUser creates an alertView with a text input field
 *  which will prompt the user to enter a username for the new user
 * When the an alertView's button's are pressed, it will call the
 *  alertView:clickedButtonAtIndex: method on the delegate, which is set to self
 *  and in that method we will post the user with the new username to the server
 ********************/
- (IBAction)addUser:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New User"
                                                    message:@"Enter A Username"
                                                   delegate:self
                                          cancelButtonTitle:@"nevermind"
                                          otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}



#pragma mark UIAlertView delegate methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        TUPUserDetailController *vc = [sb instantiateViewControllerWithIdentifier:@"UserDetailVC"];
        vc.user = [[TUPUser alloc] init];
        vc.user.name = @"JohnDoe";
        vc.user.username = [[alertView textFieldAtIndex:0] text];
        vc.user.age = [NSNumber numberWithInt:35];
        
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        [objectManager postObject:vc.user
                             path:[NSString stringWithFormat:@"user/%@", vc.user.username]
                       parameters:nil
                          success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                             [self.navigationController pushViewController:vc animated:YES];
                          } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                              message:[error localizedDescription]
                                                                             delegate:nil
                                                                    cancelButtonTitle:@"OK"
                                                                    otherButtonTitles:nil];
                              [alert show];
                          }];
    }
}

#pragma mark UIViewController overrides

/**************
 * These are basically just life cycle methods for the UIViewController
 * that we are overriding to get custom behavior
 **************/

- (void)loadView
{
    [self loadUsers];
    [super loadView];
}

-(void) viewWillAppear:(BOOL)animated {
    [self loadUsers];
    [super viewWillAppear:animated];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"Source Controller = %@", [segue sourceViewController]);
    NSLog(@"Destination Controller = %@", [segue destinationViewController]);
    NSLog(@"Segue Identifier = %@", [segue identifier]);
    
    NSInteger row = [[self.tableView indexPathForCell:sender] row];
    [[segue destinationViewController] setUser:[self.users objectAtIndex:row]];
}

#pragma mark UITableViewDelegate methods

-(BOOL)tableView:(UITableView *) tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger row = [indexPath row];
        [self deleteUser: [self.users objectAtIndex: row]];
    }
}

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return [self.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"UserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    TUPUser* user = [self.users objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
    cell.detailTextLabel.text = user.name;
    cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

@end
