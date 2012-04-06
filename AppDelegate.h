//
//  AppDelegate.h
//  skinMD3
//
//  Created by Aldrin Abastillas on 2/1/12.
//  Copyright (c) 2012 University of Pennsylvania. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : NSObject
{
	UIWindow *              _window;
	UITabBarController *    _tabs;
    
    NSInteger               _networkingCount;
    NSTimeInterval          _time;

}

@property (nonatomic, retain) IBOutlet UIWindow *           window;
@property (nonatomic, retain) IBOutlet UITabBarController * tabs;

+ (AppDelegate *)sharedAppDelegate;

- (NSString *)pathForTestImage:(NSUInteger)imageNumber;

- (NSString *)pathForTestImage;
- (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix;

- (NSURL *)smartURLForString:(NSString *)str;

//- (void)didStartNetworking;
- (void)didStopNetworking;

@end