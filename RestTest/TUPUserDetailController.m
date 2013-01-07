//
//  TUPUserDetailController.m
//  RestTest
//
//  Created by William Barksdale on 12/22/12.
//  Copyright (c) 2012 Tuple23. All rights reserved.
//

#import "TUPUserDetailController.h"

// Private Methods
@interface TUPUserDetailController ()
@property(nonatomic, strong) UIImage *loadingIcon;
@end


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

-(void)uploadUserImage:(UIImage *)image{
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *urlString = [NSString stringWithFormat:@"http://192.168.1.96:80/image/%@", self.user.username];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];;
    NSString *boundary = @"0x0hHai1CanHazB0undar135";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];

    NSMutableData *body = [NSMutableData data];
    [body appendData:
     [[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData:
     [[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:
     [[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:imageData];
    [body appendData:
     [[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];

    NSHTTPURLResponse *response;
    NSError *error = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error == nil){
        if(response.statusCode == 200)
            NSLog(@"ok!");
        else
            NSLog(@"No way");
    }else{
        NSLog(@"Error UPloading: %@", error);
    }
}

-(UIImage *)downloadUserImage:(NSString *)username{
    NSLog(@"downloading image");
    NSString *urlString = [NSString stringWithFormat:@"http://192.168.1.96:80/image/%@", self.user.username];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSData *pngData = [NSData dataWithContentsOfURL:url];
    if(pngData == nil) return nil;
    UIImage *finalImage = [UIImage imageWithData:pngData];
    NSLog(@"width: %f height: %f", finalImage.size.width, finalImage.size.height);
    return finalImage;
}

-(void)takeImage{
    
    NSLog(@"Taking Image");
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO){
        // User does not have camera, so prepare to get a photo from the library
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        cameraUI.allowsEditing = NO;
        cameraUI.delegate = self;
    } else {
        // User has a camera, so prepare to take picture
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        // Displays a control that allows the user to choose picture or
        // movie capture, if both are available:
        cameraUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
        
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        cameraUI.allowsEditing = NO;
        cameraUI.delegate = self;
    }
    
    [self presentViewController:cameraUI animated:YES completion:nil];
}

#pragma mark ImagePickerDelegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.userImage setImage:self.loadingIcon];
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    NSLog(@"MediaType: %@", mediaType);
    UIImage *image = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];
    [self uploadUserImage:image];
    [self.userImage setImage:image];
}

// set up all our labels and text fields
-(void) viewDidLoad {
    self.usernameLabel.text = self.user.username;
    self.nameField.text = self.user.name;
    self.ageField.text = [self.user.age stringValue];
    
    //load the loading icon
    self.loadingIcon = [UIImage imageNamed:@"spinner.gif"];
    [self.userImage setImage:self.loadingIcon];
    
    //Load the image concurrently from the server
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        UIImage *image = [self downloadUserImage:self.user.username];
        if(image == nil) {
            image = [UIImage imageNamed:@"place_holder.png"];
        }
        //Update the image on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"setting image...");
            [self.userImage setImage:image];
            [self.userImage setNeedsDisplay];
        });

    });
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    //Hook up the UIImage vew so that it launches the UIImagePicker when tapped
    self.userImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takeImage)];
    [self.userImage addGestureRecognizer:tapImage];
}

-(void)dismissKeyboard {
    [self.nameField resignFirstResponder];
    [self.ageField resignFirstResponder];
}

-(BOOL) textFieldShouldReturn:(UITextField*) textField {
    [textField resignFirstResponder];
    return YES;
}

@end
