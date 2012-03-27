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
//@synthesize tabs        = _tabs;

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

- (NSString *)pathForTestImage:(NSUInteger)imageNumber;
// In order to fully test the send and receive code paths, we need some really big 
// files.  Rather than carry these files around in our binary, we synthesise them. 
// Specifically, for each test image, we expand the image by an order of magnitude, 
// based on its image number.  That is, image 1 is not expanded, image 2 
// gets expanded 10 times, and so on.  We expand the image by simply copying it 
// to the temporary directory, writing the same data to the file over and over 
// again.
{
    NSUInteger          power;
    NSUInteger          expansionFactor;
    NSString *          originalFilePath;
    NSString *          bigFilePath;
    NSFileManager *     fileManager;
    NSDictionary *      attrs;
    unsigned long long  originalFileSize;
    unsigned long long  bigFileSize;
     
//    assert( (imageNumber >= 1) && (imageNumber <= 4) );
    
    // Argh, C has no built-in power operator, so I have to do 10 ** (imageNumber - 1)
    // in floating point and then cast back to integer.  Fortunately the range 
    // of values is small enough (1..1000) that floating point isn't going 
    // to cause me any problems.
    
    // On the simulator we expand by an extra order of magnitude; Macs are fast!
    
    power = imageNumber - 1;
#if TARGET_IPHONE_SIMULATOR
    power += 1;
#endif
    expansionFactor = (NSUInteger) pow(10, power);
    
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    // Calculate paths to both the original file and the expanded file.
    
//    originalFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"TestImage%zu", (size_t) imageNumber] ofType:@"png"];
    originalFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"TestImage%zu", (size_t) 1] ofType:@"png"];
    assert(originalFilePath != nil);
    
//    bigFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"TestImage%zu.png", (size_t) imageNumber]];
    bigFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"TestImage%zu.png", (size_t) 1]];

    assert(bigFilePath != nil);
    
    // Get the sizes of each.
    
    attrs = [fileManager attributesOfItemAtPath:originalFilePath error:NULL];
    assert(attrs != nil);
    
    originalFileSize = [[attrs objectForKey:NSFileSize] unsignedLongLongValue];
    
    attrs = [fileManager attributesOfItemAtPath:bigFilePath error:NULL];
    if (attrs == NULL) {
        bigFileSize = 0;
    } else {
        bigFileSize = [[attrs objectForKey:NSFileSize] unsignedLongLongValue];
    }
    
    // If the expanded file is missing, or the wrong size, create it from scratch.
    
    if (bigFileSize != (originalFileSize * expansionFactor)) {
        NSOutputStream *    bigFileStream;
        NSData *            data;
        const uint8_t *     dataBuffer;
        NSUInteger          dataLength;
        NSUInteger          dataOffset;
        NSUInteger          counter;
        
        NSLog(@"%5u - %@", (size_t) expansionFactor, bigFilePath);
        
        data = [NSData dataWithContentsOfMappedFile:originalFilePath];
        assert(data != nil);
        
        dataBuffer = [data bytes];
        dataLength = [data length];
        
        bigFileStream = [NSOutputStream outputStreamToFileAtPath:bigFilePath append:NO];
        assert(bigFileStream != NULL);
        
        [bigFileStream open];
        
        for (counter = 0; counter < expansionFactor; counter++) {
            dataOffset = 0;
            while (dataOffset != dataLength) {
                NSInteger       bytesWritten;
                
                bytesWritten = [bigFileStream write:&dataBuffer[dataOffset] maxLength:dataLength - dataOffset];
                assert(bytesWritten > 0);
                
                dataOffset += bytesWritten;
            }
        }
        
        [bigFileStream close];
    }
    
    return bigFilePath;
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

- (NSURL *)smartURLForString:(NSString *)str
{
    NSURL *     result;
    NSString *  trimmedStr;
    NSRange     schemeMarkerRange;
    NSString *  scheme;
    
    assert(str != nil);
    
    result = nil;
    
    trimmedStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ( (trimmedStr != nil) && (trimmedStr.length != 0) ) {
        schemeMarkerRange = [trimmedStr rangeOfString:@"://"];
        
        if (schemeMarkerRange.location == NSNotFound) {
            result = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", trimmedStr]];
        } else {
            scheme = [trimmedStr substringWithRange:NSMakeRange(0, schemeMarkerRange.location)];
            assert(scheme != nil);
            
            if ( ([scheme compare:@"http"  options:NSCaseInsensitiveSearch] == NSOrderedSame)
                || ([scheme compare:@"https" options:NSCaseInsensitiveSearch] == NSOrderedSame) ) {
                result = [NSURL URLWithString:trimmedStr];
            } else {
                // It looks like this is some unsupported URL scheme.
            }
        }
    }
    
    return result;
}

- (void)didStartNetworking
{
    self.networkingCount += 1;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didStopNetworking
{
    assert(self.networkingCount > 0);
    self.networkingCount -= 1;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = (self.networkingCount != 0);
}

@end

