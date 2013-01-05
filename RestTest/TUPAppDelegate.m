//
//  TUPAppDelegate.m
//  RestTest
//
//  Created by William Barksdale on 12/21/12.
//  Copyright (c) 2012 Tuple23. All rights reserved.
//

#import "TUPAppDelegate.h"
#import <RestKit/RestKit.h>
#import "TUPUser.h"

@implementation TUPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    RKLogConfigureByName("RestKit/Network*", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    
    
    /********************
     * First we configure the HTTPClient with a url and set any headers we need to
     ********************/
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    //NSURL *baseURL = [NSURL URLWithString:@"http://localhost:8080"];
    NSURL *baseURL = [NSURL URLWithString:@"http://192.168.1.96:80"];
    
    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    
    
    /*********************
     * The objectManager here is basically a singleton that can be
     *  accessed with the class method RKObjectManaker sharedInstance
     * 
     * You tell the object manager about the objects you want to map,
     *  and the API end points that you are going to talk to.
     *
     * Response / Request descriptors kindof describe an API end point
     *  and how to map objects to and from that endpoint
     *********************/
    
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[TUPUser class]];
    [userMapping addAttributeMappingsFromDictionary:@{
     @"name" : @"name",
     @"username" : @"username",
     @"age" : @"age"
     }];
    
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    
    // the mappings from array syntax appears to basically assume that the json
    //  fields are identical to your object fields.
    [requestMapping addAttributeMappingsFromArray:@[@"username", @"name", @"age"]];
    
    
    //[RKObjectMapping addDefaultDateFormatterForString:@"E MMM d HH:mm:ss Z y" inTimeZone:nil];
    

    RKResponseDescriptor *getUserDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                       pathPattern:@"/user/:username"
                                                                                           keyPath:nil
                                                                                       statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    RKResponseDescriptor *listUsersDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                       pathPattern:@"/users"
                                                                                           keyPath:nil
                                                                                       statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    RKRequestDescriptor *postUserDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping
                                                                                    objectClass:[TUPUser class]
                                                                                    rootKeyPath:nil];
    [objectManager addResponseDescriptor:getUserDescriptor];
    [objectManager addResponseDescriptor:listUsersDescriptor];
    [objectManager addRequestDescriptor:postUserDescriptor];
    
    return YES;
}


/******************
 * The below methods are just stubs for hooking into different points in the
 * application life cycle. Such as when the user closes, or re-opens the app, etc...
 ******************/
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
