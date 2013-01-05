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

//-(void)uploadUserImage:(UIImage *)image{
//    NSLog(@"uploading image");
//    NSData *pngData = UIImagePNGRepresentation(image);
//    NSString *urlString = [NSString stringWithFormat:@"http://192.168.1.96:80/image/%@", self.user.username];
//    NSURL *url = [NSURL URLWithString:urlString];
//    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    [request setHTTPMethod:@"PUT"];
//    [request setValue:@"image/png" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:@"binary" forHTTPHeaderField:@"Content-Transfer-Encoding"];
//    [request setHTTPBody:pngData];
//    
//    NSHTTPURLResponse *response;
//    NSError *error = nil;
//    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    if(error == nil){
//        if(response.statusCode == 200)
//            NSLog(@"ok!");
//        else
//            NSLog(@"No way");
//    }else{
//        NSLog(@"Error UPloading: %@", error);
//    }
//}

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

//-(UIImage *)downloadUserImage:(NSString *)username{
//    NSLog(@"downloading image");
//    NSString *urlString = [NSString stringWithFormat:@"http://192.168.1.96:80/image/%@", self.user.username];
//    NSURL *url = [NSURL URLWithString:urlString];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    [request setHTTPMethod:@"GET"];
//    NSHTTPURLResponse *response;
//    NSError *error = nil;
//    
//    NSData *pngData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    if(error == nil){
//        if(response.statusCode == 200){
//            CFDataRef imgData = (__bridge CFDataRef) pngData;
//            CGDataProviderRef imgDataProvider = CGDataProviderCreateWithCFData(imgData);
//            CGImageRef image = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
//            UIImage *finalImage = [UIImage imageWithCGImage:image];
//            NSLog(@"width: %f height: %f", finalImage.size.width, finalImage.size.height);
//            return finalImage;
//        }
//        if(response.statusCode == 404){
//            NSLog(@"404 Response");
//        }
//    } else{
//        NSLog(@"Error Downloading: %@", error);
//    }
//    return nil;
//}

-(void)takeImage{
    
    NSLog(@"Taking Image");
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO){
        NSLog(@"Camera Not Available");
        return;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:nil];
}

#pragma mark ImagePickerDelegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    NSLog(@"MediaType: %@", mediaType);
    UIImage *image = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];
    [self.userImage setImage:image];
    [self uploadUserImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// set up all our labels and text fields
-(void) viewDidLoad {
    self.usernameLabel.text = self.user.username;
    self.nameField.text = self.user.name;
    self.ageField.text = [self.user.age stringValue];
    
    UIImage *image = [self downloadUserImage:self.user.username];
    if(image != nil){
        NSLog(@"setting image...");
        [self.userImage setImage:image];
    }
    
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
