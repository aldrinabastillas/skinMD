//
//  AppDelegate.m
//  skinMD3
//
//  Created by Aldrin Abastillas on 2/1/12.
//  Copyright (c) 2012 University of Pennsylvania. All rights reserved.
//


#import "AppDelegate.h"

@interface AppDelegate ()
@property (nonatomic, assign) NSInteger             networkingCount;
@end

@implementation AppDelegate 

+ (AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *) [UIApplication sharedApplication].delegate;
}

@synthesize window      = _window;
@synthesize tabs        = _tabs;

@synthesize networkingCount = _networkingCount;


- (void)applicationDidFinishLaunching:(UIApplication *)application
{
#pragma unused(application)
    assert(self.window != nil);
//    assert(self.tabs != nil);
    
//    [self.window addSubview:self.tabs.view];
    
//    self.tabs.selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentTab"];
    
	[self.window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
#pragma unused(application)
//    [[NSUserDefaults standardUserDefaults] setInteger:self.tabs.selectedIndex forKey:@"currentTab"];
}



- (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix
{
    NSString *  result;
    CFUUIDRef   uuid;
    CFStringRef uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    result = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", prefix, uuidStr]];
    assert(result != nil);
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}

//- (void)didStartNetworking
//{
//    self.networkingCount += 1;
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//}
//
//- (void)didStopNetworking
//{
//    assert(self.networkingCount > 0);
//    self.networkingCount -= 1;
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = (self.networkingCount != 0);
//}

@end

