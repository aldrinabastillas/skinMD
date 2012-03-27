/*
     File: MyViewController.m 
 Abstract: The main view controller of this app.
  
  Version: 1.1 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2011 Apple Inc. All Rights Reserved. 
  
 */

#import "MyViewController.h"
#import "AppDelegate.h"

#include <sys/socket.h>
#include <unistd.h>

#include <CFNetwork/CFNetwork.h>

@implementation MyViewController

@synthesize imageView, myToolbar, overlayViewController, capturedImages;
@synthesize isReceiving, getConnection, filePath, getFileStream, foundRange;
//@synthesize isSending, postConnection, bodyPrefixData, postFileStream, bodySuffixData, producerStream;
//@synthesize consumerStream, buffer, bufferOnHeap, bufferOffset, bufferLimit;

static NSString * kDefaultGetURLText = @"http://unpbook.com/small.gif";                     // ************************         CHANGE THIS
//static NSString * kDefaultGetURLText = @"http://li245-100.members.linode.com/"
static NSString * kDefaultPostURLText = @"http://localhost:9000/cgi-bin/PostIt.py";

#pragma mark -
#pragma mark View Controller

- (void)viewDidLoad
{
    self.overlayViewController =
        [[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil] autorelease];

    // as a delegate we will be notified when pictures are taken and when to dismiss the image picker
    self.overlayViewController.delegate = self;
    
    self.capturedImages = [NSMutableArray array];

//    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
//    {
//        // camera is not on this device, don't show the camera button
//        NSMutableArray *toolbarItems = [NSMutableArray arrayWithCapacity:self.myToolbar.items.count];
//        [toolbarItems addObjectsFromArray:self.myToolbar.items];
//        [toolbarItems removeObjectAtIndex:2];
//        [self.myToolbar setItems:toolbarItems animated:NO];
//    }
    
    
// ******************************* GetController ********************    
    
    NSString *  defaultURLText;
    
    [super viewDidLoad];
    
    assert(self.geturlText != nil);
    assert(self.getimageView != nil);
    assert(self.getstatusLabel != nil);
    assert(self.getactivityIndicator != nil);
    assert(self.getOrCancelButton != nil);
    
    self.getOrCancelButton.possibleTitles = [NSSet setWithObjects:@"Get", @"Cancel", nil];
    
    // Set up the URL field to be the last value we saved (or the default value 
    // if we have none).
    
    defaultURLText = [[NSUserDefaults standardUserDefaults] stringForKey:@"GetURLText"];
    if (defaultURLText == nil) {
        defaultURLText = kDefaultGetURLText;
    }
    self.geturlText.text = defaultURLText;
    
    self.getactivityIndicator.hidden = YES;
    self.getstatusLabel.text = @"Tap Get to start the GET";
    
// ******************************* PostController ******************** 
    NSString *  currentURLText;
    
    [super viewDidLoad];
    assert(self.posturlText != nil);
    assert(self.poststatusLabel != nil);
    assert(self.postactivityIndicator != nil);
    assert(self.postcancelButton != nil);
    
    // Set up the URL field to be the last value we saved (or the default value 
    // if we have none).
    
    currentURLText = [[NSUserDefaults standardUserDefaults] stringForKey:@"PostURLText"];
    if (currentURLText == nil) {
        currentURLText = kDefaultPostURLText;
    }
    self.posturlText.text = currentURLText;
    
    self.postactivityIndicator.hidden = YES;
    self.poststatusLabel.text = @"Tap a picture to start the POST";
    self.postcancelButton.enabled = NO;
}

- (void)viewDidUnload
{
    self.imageView = nil;
    self.myToolbar = nil;
    
    self.overlayViewController = nil;
    self.capturedImages = nil;
    
    
    
// ******************************* GetController ********************      
    
    [super viewDidUnload];
    
    self.geturlText = nil;
    self.getimageView = nil;
    self.getstatusLabel = nil;
    self.getactivityIndicator = nil;
    self.getOrCancelButton = nil;

// ******************************* PostController ********************      
    
    [super viewDidUnload];
    
    self.posturlText = nil;
    self.poststatusLabel = nil;
    self.postactivityIndicator = nil;
    self.postcancelButton = nil;
}

- (void)dealloc
{	
	[imageView release];
	[myToolbar release];
    
    [overlayViewController release];
	[capturedImages release];
    
    [super dealloc];
    
    
// ******************************* GetController ********************      
    
    [self _stopReceiveWithStatus:@"Stopped"];
    
    [self->_geturlText release];
    [self->_getimageView release];
    [self->_getstatusLabel release];
    [self->_getactivityIndicator release];
    [self->_getOrCancelButton release];
    
    [super dealloc];
    
// ******************************* PostController ********************      
    
    [self _stopSendWithStatus:@"Stopped"];
    
    [self->_posturlText release];
    [self->_poststatusLabel release];
    [self->_postactivityIndicator release];
    [self->_cancelButton release];
    
    [super dealloc];
    
}


#pragma mark -
#pragma mark Toolbar Actions

- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    if (self.imageView.isAnimating)
        self.imageView.stopAnimating;
	
    if (self.capturedImages.count > 0)
        [self.capturedImages removeAllObjects];
    
    if ([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        [self.overlayViewController setupImagePicker:sourceType];
        [self presentModalViewController:self.overlayViewController.imagePickerController animated:YES];
    }
}

- (IBAction)photoLibraryAction:(id)sender
{   
	[self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)cameraAction:(id)sender
{
    [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
}


#pragma mark -
#pragma mark OverlayViewControllerDelegate

// as a delegate we are being told a picture was taken
- (void)didTakePicture:(UIImage *)picture
{
    [self.capturedImages addObject:picture];
}

// as a delegate we are told to finished with the camera
- (void)didFinishWithCamera
{
    [self dismissModalViewControllerAnimated:YES];
    
    if ([self.capturedImages count] > 0)
    {
        if ([self.capturedImages count] == 1)
        {
            // we took a single shot
            [self.imageView setImage:[self.capturedImages objectAtIndex:0]];
        }
        else
        {
            // we took multiple shots, use the list of images for animation
            self.imageView.animationImages = self.capturedImages;
            
            if (self.capturedImages.count > 0)
                // we are done with the image list until next time
                [self.capturedImages removeAllObjects];  
            
            self.imageView.animationDuration = 5.0;    // show each captured photo for 5 seconds
            self.imageView.animationRepeatCount = 0;   // animate forever (show all photos)
            self.imageView.startAnimating;
        }
    }
}












//           ********************************* GetController ******************************

#pragma mark * NSString interface

// Comparing HTTP content types is tricky because a) they are case insensitive and 
// b) there can be parameters at the end of the string.

//@interface NSString (HTTPExtensions)

//- (BOOL)isHTTPContentType:(NSString *)prefixStr;

//@end

//@implementation NSString (HTTPExtensions)

- (BOOL)isHTTPContentType:(NSString *)prefixStr
{
    BOOL    result;
//    NSRange foundRange;
    
    result = NO;
    
    self.foundRange = [self rangeOfString:prefixStr options:NSAnchoredSearch | NSCaseInsensitiveSearch];
    if (self.foundRange->location != NSNotFound) {
        assert(self.foundRange->location == 0);            // because it's anchored
//        if (self.foundRange->length == self.length) {
//            result = YES;
        } else {
            unichar nextChar;
            
            nextChar = [self characterAtIndex:self.foundRange->length];
            result = nextChar <= 32 || nextChar >= 127 || (strchr("()<>@,;:\\<>/[]?={}", nextChar) != NULL);
        }
        /*
         From RFC 2616:
         
         token          = 1*<any CHAR except CTLs or separators>
         separators     = "(" | ")" | "<" | ">" | "@"
         | "," | ";" | ":" | "\" | <">
         | "/" | "[" | "]" | "?" | "="
         | "{" | "}" | SP | HT
         
         media-type     = type "/" subtype *( ";" parameter )
         type           = token
         subtype        = token
         */
    }
//    return result;


//@end

#pragma mark * GetController Interface


//@interface GetController ()

// Properties that don't need to be seen by the outside world.

//@property (nonatomic, readonly) BOOL              isReceiving;
//@property (nonatomic, retain)   NSURLConnection * connection;
//@property (nonatomic, copy)     NSString *        filePath;
//@property (nonatomic, retain)   NSOutputStream *  fileStream;



//@end

//@implementation GetController

#pragma mark * Status management

// These methods are used by the core transfer code to update the UI.

- (void)_receiveDidStart
{
    // Clear the current image so that we get a nice visual cue if the receive fails.
    self.getimageView.image = [UIImage imageNamed:@"NoImage.png"];
    self.getstatusLabel.text = @"Receiving";
    self.getOrCancelButton.title = @"Cancel";
    [self.getactivityIndicator startAnimating];
    [[AppDelegate sharedAppDelegate] didStartNetworking];
}

- (void)_updateGetStatus:(NSString *)statusString
{
    assert(statusString != nil);
    self.getstatusLabel.text = statusString;
}

- (void)_receiveDidStopWithStatus:(NSString *)statusString
{
    if (statusString == nil) {
        assert(self.filePath != nil);
        self.getimageView.image = [UIImage imageWithContentsOfFile:self.filePath];
        statusString = @"GET succeeded";
    }
    self.getstatusLabel.text = statusString;
    self.getOrCancelButton.title = @"Get";
    [self.getactivityIndicator stopAnimating];
    [[AppDelegate sharedAppDelegate] didStopNetworking];
}

#pragma mark * Core transfer code

// This is the code that actually does the networking.

//@synthesize connection    = _connection;
//@synthesize filePath      = _filePath;
//@synthesize fileStream    = _fileStream;

- (BOOL)isReceiving
{
    return (self.getConnection != nil);
}

- (void)_startReceive
// Starts a connection to download the current URL.
{
    BOOL                success;
    NSURL *             url;
    NSURLRequest *      request;
    
    assert(self.getConnection == nil);         // don't tap receive twice in a row!
    assert(self.getFileStream == nil);         // ditto
    assert(self.filePath == nil);           // ditto
    
    // First get and check the URL.
    
    url = [[AppDelegate sharedAppDelegate] smartURLForString:self.geturlText.text];
    success = (url != nil);
    
    // If the URL is bogus, let the user know.  Otherwise kick off the connection.
    
    if ( ! success) {
        self.getstatusLabel.text = @"Invalid URL";
    } else {
        
        // Open a stream for the file we're going to receive into.
        
        self.filePath = [[AppDelegate sharedAppDelegate] pathForTemporaryFileWithPrefix:@"Get"];
        assert(self.filePath != nil);
        
        self.getFileStream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:NO];
        assert(self.getFileStream != nil);
        
        [self.getFileStream open];
        
        // Open a connection for the URL.
        
        request = [NSURLRequest requestWithURL:url];
        assert(request != nil);
        
        self.getConnection = [NSURLConnection connectionWithRequest:request delegate:self];
        assert(self.getConnection != nil);
        
        // Tell the UI we're receiving.
        
        [self _receiveDidStart];
    }
}

- (void)_stopReceiveWithStatus:(NSString *)statusString
// Shuts down the connection and displays the result (statusString == nil) 
// or the error status (otherwise).
{
    if (self.getConnection != nil) {
        [self.getConnection cancel];
        self.getConnection = nil;
    }
    if (self.getFileStream != nil) {
        [self.getFileStream close];
        self.getFileStream = nil;
    }
    [self _receiveDidStopWithStatus:statusString];
    self.filePath = nil;
}

- (void)getConnection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
// A delegate method called by the NSURLConnection when the request/response 
// exchange is complete.  We look at the response to check that the HTTP 
// status code is 2xx and that the Content-Type is acceptable.  If these checks 
// fail, we give up on the transfer.
{
#pragma unused(theConnection)
    NSHTTPURLResponse * httpResponse;
    NSString *          contentTypeHeader;
    
    assert(theConnection == self.getConnection);
    
    httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    
    if ((httpResponse.statusCode / 100) != 2) {
        [self _stopReceiveWithStatus:[NSString stringWithFormat:@"HTTP error %zd", (ssize_t) httpResponse.statusCode]];
    } else {
        contentTypeHeader = [httpResponse.allHeaderFields objectForKey:@"Content-Type"];
        if (contentTypeHeader == nil) {
            [self _stopReceiveWithStatus:@"No Content-Type!"];
        } else if ( ! [contentTypeHeader isHTTPContentType:@"image/jpeg"] 
                   && ! [contentTypeHeader isHTTPContentType:@"image/png"] 
                   && ! [contentTypeHeader isHTTPContentType:@"text/plain: charset=utf-8"] 
                   && ! [contentTypeHeader isHTTPContentType:@"image/gif"] ) {
            [self _stopReceiveWithStatus:[NSString stringWithFormat:@"Unsupported Content-Type (%@)", contentTypeHeader]];
        } else {
            self.getstatusLabel.text = @"Response OK.";
        }
    }    
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
// A delegate method called by the NSURLConnection as data arrives.  We just 
// write the data to the file.
{
#pragma unused(theConnection)
    NSInteger       dataLength;
    const uint8_t * dataBytes;
    NSInteger       bytesWritten;
    NSInteger       bytesWrittenSoFar;
    
    assert(theConnection == self.getConnection);
    
    dataLength = [data length];
    dataBytes  = [data bytes];
    
    bytesWrittenSoFar = 0;
    do {
        bytesWritten = [self.getFileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
        assert(bytesWritten != 0);
        if (bytesWritten == -1) {
            [self _stopReceiveWithStatus:@"File write error"];
            break;
        } else {
            bytesWrittenSoFar += bytesWritten;
        }
    } while (bytesWrittenSoFar != dataLength);
}

- (void)getGonnection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
// A delegate method called by the NSURLConnection if the connection fails. 
// We shut down the connection and display the failure.  Production quality code 
// would either display or log the actual error.
{
#pragma unused(theConnection)
#pragma unused(error)
    assert(theConnection == self.getConnection);
    
    [self _stopReceiveWithStatus:@"Connection failed"];
}

- (void)getConnectionDidFinishLoading:(NSURLConnection *)theConnection
// A delegate method called by the NSURLConnection when the connection has been 
// done successfully.  We shut down the connection with a nil status, which 
// causes the image to be displayed.
{
#pragma unused(theConnection)
    assert(theConnection == self.getConnection);
    
    [self _stopReceiveWithStatus:nil];
}

#pragma mark * UI Actions

- (IBAction)getOrCancelAction:(id)sender
{
#pragma unused(sender)
    if (self.isReceiving) {
        [self _stopReceiveWithStatus:@"Cancelled"];
    } else {
        [self _startReceive];
    }
}

- (void)getTextFieldDidEndEditing:(UITextField *)textField
// A delegate method called by the URL text field when the editing is complete. 
// We save the current value of the field in our settings.
{
#pragma unused(textField)
    NSString *  newValue;
    NSString *  oldValue;
    
    assert(textField == self.geturlText);
    
    newValue = self.geturlText.text;
    oldValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"GetURLText"];
    
    // Save the URL text if there is no pre-existing setting and it's not our 
    // default value, or if there is a pre-existing default and the new value 
    // is different.
    
    if (   ((oldValue == nil) && ! [newValue isEqual:kDefaultGetURLText] ) 
        || ((oldValue != nil) && ! [newValue isEqual:oldValue] ) ) {
        [[NSUserDefaults standardUserDefaults] setObject:newValue forKey:@"GetURLText"];
    }    
}

- (BOOL)getTextFieldShouldReturn:(UITextField *)textField
// A delegate method called by the URL text field when the user taps the Return 
// key.  We just dismiss the keyboard.
{
#pragma unused(textField)
    assert(textField == self.geturlText);
    [self.geturlText resignFirstResponder];
    return NO;
}

#pragma mark * View controller boilerplate

@synthesize geturlText           = _geturlText;
@synthesize getimageView         = _getimageView;
@synthesize getstatusLabel       = _getstatusLabel;
@synthesize getactivityIndicator = _getactivityIndicator;
@synthesize getOrCancelButton = _getOrCancelButton;









//                           ******************************* PostController ********************

#pragma mark Post Controller 
#pragma mark * Utilities

//  CFStream bound pair generates weird log message
//  CFStream bound pair crashers

static void CFStreamCreateBoundPairCompat(
                                          CFAllocatorRef      alloc, 
                                          CFReadStreamRef *   readStreamPtr, 
                                          CFWriteStreamRef *  writeStreamPtr, 
                                          CFIndex             transferBufferSize
                                          )
// This is a drop-in replacement for CFStreamCreateBoundPair that is necessary 
// because the bound pairs are broken on iPhone OS up-to-and-including 
// version 3.0.1 <rdar://problem/7027394> <rdar://problem/7027406>.  It 
// emulates a bound pair by creating a pair of UNIX domain sockets and wrapper 
// each end in a CFSocketStream.  This won't give great performance, but 
// it doesn't crash!
{
#pragma unused(transferBufferSize)
    int                 err;
    Boolean             success;
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
    int                 fds[2];
    
    assert(readStreamPtr != NULL);
    assert(writeStreamPtr != NULL);
    
    readStream = NULL;
    writeStream = NULL;
    
    // Create the UNIX domain socket pair.
    
    err = socketpair(AF_UNIX, SOCK_STREAM, 0, fds);
    if (err == 0) {
        CFStreamCreatePairWithSocket(alloc, fds[0], &readStream,  NULL);
        CFStreamCreatePairWithSocket(alloc, fds[1], NULL, &writeStream);
        
        // If we failed to create one of the streams, ignore them both.
        
        if ( (readStream == NULL) || (writeStream == NULL) ) {
            if (readStream != NULL) {
                CFRelease(readStream);
                readStream = NULL;
            }
            if (writeStream != NULL) {
                CFRelease(writeStream);
                writeStream = NULL;
            }
        }
        assert( (readStream == NULL) == (writeStream == NULL) );
        
        // Make sure that the sockets get closed (by us in the case of an error, 
        // or by the stream if we managed to create them successfull).
        
        if (readStream == NULL) {
            err = close(fds[0]);
            assert(err == 0);
            err = close(fds[1]);
            assert(err == 0);
        } else {
            success = CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            assert(success);
            success = CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            assert(success);
        }
    }
    
    *readStreamPtr = readStream;
    *writeStreamPtr = writeStream;
}



// A category on NSStream that provides a nice, Objective-C friendly way to create 
// bound pairs of streams.

//@interface NSStream (BoundPairAdditions)
//+ (void)createBoundInputStream:(NSInputStream **)inputStreamPtr outputStream:(NSOutputStream **)outputStreamPtr bufferSize:(NSUInteger)bufferSize;
//@end

//@implementation NSStream (BoundPairAdditions)

+ (void)createBoundInputStream:(NSInputStream **)inputStreamPtr outputStream:(NSOutputStream **)outputStreamPtr bufferSize:(NSUInteger)bufferSize
{
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
    
    assert( (inputStreamPtr != NULL) || (outputStreamPtr != NULL) );
    
    readStream = NULL;
    writeStream = NULL;
    
    if (YES) {
        CFStreamCreateBoundPairCompat(
                                      NULL, 
                                      ((inputStreamPtr  != nil) ? &readStream : NULL),
                                      ((outputStreamPtr != nil) ? &writeStream : NULL), 
                                      (CFIndex) bufferSize
                                      );
    } else {
        CFStreamCreateBoundPair(
                                NULL, 
                                ((inputStreamPtr  != nil) ? &readStream : NULL),
                                ((outputStreamPtr != nil) ? &writeStream : NULL), 
                                (CFIndex) bufferSize
                                );
    }
    
    if (inputStreamPtr != NULL) {
        *inputStreamPtr  = [NSMakeCollectable(readStream) autorelease];
    }
    if (outputStreamPtr != NULL) {
        *outputStreamPtr = [NSMakeCollectable(writeStream) autorelease];
    }
}

//@end

#pragma mark * PostController

enum {
    kPostBufferSize = 32768
};



//@interface PostController ()

// Properties that don't need to be seen by the outside world.

//@property (nonatomic, readonly) BOOL              isSending;
//@property (nonatomic, retain)   NSURLConnection * connection;
//@property (nonatomic, copy)     NSData *          bodyPrefixData;
//@property (nonatomic, retain)   NSInputStream *   fileStream;
//@property (nonatomic, copy)     NSData *          bodySuffixData;
//@property (nonatomic, retain)   NSOutputStream *  producerStream;
//@property (nonatomic, retain)   NSInputStream *   consumerStream;
//@property (nonatomic, assign)   const uint8_t *   buffer;
//@property (nonatomic, assign)   uint8_t *         bufferOnHeap;
//@property (nonatomic, assign)   size_t            bufferOffset;
//@property (nonatomic, assign)   size_t            bufferLimit;

//@end

//@implementation PostController

+ (void)releaseObj:(id)obj
// +++ See comment in -_stopSendWithStatus:.
{
    [obj release];
}

#pragma mark * Status management

// These methods are used by the core transfer code to update the UI.

- (void)_sendDidStart
{
    self.poststatusLabel.text = @"Sending";
    self.postcancelButton.enabled = YES;
    [self.postactivityIndicator startAnimating];
    [[AppDelegate sharedAppDelegate] didStartNetworking];
}

- (void)_updatePostStatus:(NSString *)statusString
{
    assert(statusString != nil);
    self.poststatusLabel.text = statusString;
}

- (void)_sendDidStopWithStatus:(NSString *)statusString
{
    if (statusString == nil) {
        statusString = @"POST succeeded";
    }
    self.poststatusLabel.text = statusString;
    self.postcancelButton.enabled = NO;
    [self.postactivityIndicator stopAnimating];
    [[AppDelegate sharedAppDelegate] didStopNetworking];
}

#pragma mark * Core transfer code

// This is the code that actually does the networking.

@synthesize postConnection  = _postConnection;
@synthesize bodyPrefixData  = _bodyPrefixData;
@synthesize postFileStream  = _postFileStream;
@synthesize bodySuffixData  = _bodySuffixData;
@synthesize producerStream  = _producerStream;
@synthesize consumerStream  = _consumerStream;
@synthesize buffer          = _buffer;
@synthesize bufferOnHeap    = _bufferOnHeap;
@synthesize bufferOffset    = _bufferOffset;
@synthesize bufferLimit     = _bufferLimit;

- (BOOL)isSending
{
    return (self.postConnection != nil);
}

- (NSString *)_generateBoundaryString
{
    CFUUIDRef       uuid;
    CFStringRef     uuidStr;
    NSString *      result;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    result = [NSString stringWithFormat:@"Boundary-%@", uuidStr];
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}

- (void)_startSend:(NSString *)filePath
{
    BOOL                    success;
    NSURL *                 url;
    NSMutableURLRequest *   request;
    NSString *              boundaryStr;
    NSString *              contentType;
    NSString *              bodyPrefixStr;
    NSString *              bodySuffixStr;
    NSNumber *              fileLengthNum;
    unsigned long long      bodyLength;
    
    assert(filePath != nil);
    assert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
    assert( [filePath.pathExtension isEqual:@"png"] || [filePath.pathExtension isEqual:@"jpg"] );
    
    assert(self.postConnection == nil);         // don't tap send twice in a row!
    assert(self.bodyPrefixData == nil);     // ditto
    assert(self.postFileStream == nil);         // ditto
    assert(self.bodySuffixData == nil);     // ditto
    assert(self.consumerStream == nil);     // ditto
    assert(self.producerStream == nil);     // ditto
    assert(self.buffer == NULL);            // ditto
    assert(self.bufferOnHeap == NULL);      // ditto
    
    // First get and check the URL.
    
    url = [[AppDelegate sharedAppDelegate] smartURLForString:self.posturlText.text];
    success = (url != nil);
    
    // If the URL is bogus, let the user know.  Otherwise kick off the connection.
    
    if ( ! success) {
        self.poststatusLabel.text = @"Invalid URL";
    } else {
        // Determine the MIME type of the file.
        
        if ( [filePath.pathExtension isEqual:@"png"] ) {
            contentType = @"image/png";
        } else if ( [filePath.pathExtension isEqual:@"jpg"] ) {
            contentType = @"image/jpeg";
        } else if ( [self.filePath.pathExtension isEqual:@"gif"] ) {
            contentType = @"image/gif";
        } else {
            assert(NO);
            contentType = nil;          // quieten a warning
        }
        
        // Calculate the multipart/form-data body.  For more information about the 
        // format of the prefix and suffix, see:
        //
        // o HTML 4.01 Specification
        //   Forms
        //   <http://www.w3.org/TR/html401/interact/forms.html#h-17.13.4>
        //
        // o RFC 2388 "Returning Values from Forms: multipart/form-data"
        //   <http://www.ietf.org/rfc/rfc2388.txt>
        
        boundaryStr = [self _generateBoundaryString];
        assert(boundaryStr != nil);
        
        bodyPrefixStr = [NSString stringWithFormat:
                         @
                         // empty preamble
                         "\r\n"
                         "--%@\r\n"
                         "Content-Disposition: form-data; name=\"fileContents\"; filename=\"%@\"\r\n"
                         "Content-Type: %@\r\n"
                         "\r\n",
                         boundaryStr,
                         [filePath lastPathComponent],       // +++ very broken for non-ASCII
                         contentType
                         ];
        assert(bodyPrefixStr != nil);
        
        bodySuffixStr = [NSString stringWithFormat:
                         @
                         "\r\n"
                         "--%@\r\n"
                         "Content-Disposition: form-data; name=\"uploadButton\"\r\n"
                         "\r\n"
                         "Upload File\r\n"
                         "--%@--\r\n" 
                         "\r\n"
                         //empty epilogue
                         ,
                         boundaryStr, 
                         boundaryStr
                         ];
        assert(bodySuffixStr != nil);
        
        self.bodyPrefixData = [bodyPrefixStr dataUsingEncoding:NSASCIIStringEncoding];
        assert(self.bodyPrefixData != nil);
        self.bodySuffixData = [bodySuffixStr dataUsingEncoding:NSASCIIStringEncoding];
        assert(self.bodySuffixData != nil);
        
        fileLengthNum = (NSNumber *) [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL] objectForKey:NSFileSize];
        assert( [fileLengthNum isKindOfClass:[NSNumber class]] );
        
        bodyLength =
        (unsigned long long) [self.bodyPrefixData length]
        + [fileLengthNum unsignedLongLongValue]
        + (unsigned long long) [self.bodySuffixData length];
        
        // Open a stream for the file we're going to send.  We open this stream 
        // straight away because there's no need to delay.
        
        self.postFileStream = [NSInputStream inputStreamWithFileAtPath:filePath];
        assert(self.postFileStream != nil);
        
        [self.postFileStream open];
        
        // Open producer/consumer streams.  We open the producerStream straight 
        // away.  We leave the consumerStream alone; NSURLConnection will deal 
        // with it.
        
        [NSStream createBoundInputStream:&self->_consumerStream outputStream:&self->_producerStream bufferSize:32768];
        [self->_consumerStream retain];
        [self->_producerStream retain];
        assert(self.consumerStream != nil);
        assert(self.producerStream != nil);
        
        self.producerStream.delegate = self;
        [self.producerStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.producerStream open];
        
        // Set up our state to send the body prefix first.
        
        self.buffer      = [self.bodyPrefixData bytes];
        self.bufferLimit = [self.bodyPrefixData length];
        
        // Open a connection for the URL, configured to POST the file.
        
        request = [NSMutableURLRequest requestWithURL:url];
        assert(request != nil);
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBodyStream:self.consumerStream];
        
        [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=\"%@\"", boundaryStr] forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%llu", bodyLength] forHTTPHeaderField:@"Content-Length"];
        
        self.postConnection = [NSURLConnection connectionWithRequest:request delegate:self];
        assert(self.postConnection != nil);
        
        // Tell the UI we're sending.
        
        [self _sendDidStart];
    }
}

- (void)_stopSendWithStatus:(NSString *)statusString
{
    if (self.bufferOnHeap) {
        free(self.bufferOnHeap);
        self.bufferOnHeap = NULL;
    }
    self.buffer = NULL;
    self.bufferOffset = 0;
    self.bufferLimit  = 0;
    if (self.postConnection != nil) {
        [self.postConnection cancel];
        self.postConnection = nil;
    }
    self.bodyPrefixData = nil;
    if (self.producerStream != nil) {
        self.producerStream.delegate = nil;
        [self.producerStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.producerStream close];
        self.producerStream = nil;
    }
    self.consumerStream = nil;
    if (self.postFileStream != nil) {
        [self.postFileStream close];
        self.postFileStream = nil;
    }
    self.bodySuffixData = nil;
    [self _sendDidStopWithStatus:statusString];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
// An NSStream delegate callback that's called when events happen on our 
// network stream.
{
#pragma unused(aStream)
    assert(aStream == self.producerStream);
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            // NSLog(@"producer stream opened");
        } break;
        case NSStreamEventHasBytesAvailable: {
            assert(NO);     // should never happen for the output stream
        } break;
        case NSStreamEventHasSpaceAvailable: {
            // Check to see if we've run off the end of our buffer.  If we have, 
            // work out the next buffer of data to send.
            
            if (self.bufferOffset == self.bufferLimit) {
                
                // See if we're transitioning from the prefix to the file data.
                // If so, allocate a file buffer.
                
                if (self.bodyPrefixData != nil) {
                    self.bodyPrefixData = nil;
                    
                    assert(self.bufferOnHeap == NULL);
                    self.bufferOnHeap = malloc(kPostBufferSize);
                    assert(self.bufferOnHeap != NULL);
                    self.buffer = self.bufferOnHeap;
                    
                    self.bufferOffset = 0;
                    self.bufferLimit  = 0;
                }
                
                // If we still have file data to send, read the next chunk. 
                
                if (self.postFileStream != nil) {
                    NSInteger   bytesRead;
                    
                    bytesRead = [self.postFileStream read:self.bufferOnHeap maxLength:kPostBufferSize];
                    
                    if (bytesRead == -1) {
                        [self _stopSendWithStatus:@"File read error"];
                    } else if (bytesRead != 0) {
                        self.bufferOffset = 0;
                        self.bufferLimit  = bytesRead;
                    } else {
                        // If we hit the end of the file, transition to sending the 
                        // suffix.
                        
                        [self.postFileStream close];
                        self.postFileStream = nil;
                        
                        assert(self.bufferOnHeap != NULL);
                        free(self.bufferOnHeap);
                        self.bufferOnHeap = NULL;
                        self.buffer       = [self.bodySuffixData bytes];
                        
                        self.bufferOffset = 0;
                        self.bufferLimit  = [self.bodySuffixData length];
                    }
                }
                
                // If we've failed to produce any more data, we close the stream 
                // to indicate to NSURLConnection that we're all done.  We only do 
                // this if producerStream is still valid to avoid running it in the 
                // file read error case.
                
                if ( (self.bufferOffset == self.bufferLimit) && (self.producerStream != nil) ) {
                    // We set our delegate callback to nil because we don't want to 
                    // be called anymore for this stream.  However, we can't 
                    // remove the stream from the runloop (doing so prevents the 
                    // URL from ever completing) and nor can we nil out our 
                    // stream reference (that causes all sorts of wacky crashes). 
                    //
                    // +++ Need bug numbers for these problems.
                    self.producerStream.delegate = nil;
                    // [self.producerStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                    [self.producerStream close];
                    // self.producerStream = nil;
                }
            }
            
            // Send the next chunk of data in our buffer.
            
            if (self.bufferOffset != self.bufferLimit) {
                NSInteger   bytesWritten;
                bytesWritten = [self.producerStream write:&self.buffer[self.bufferOffset] maxLength:self.bufferLimit - self.bufferOffset];
                if (bytesWritten <= 0) {
                    [self _stopSendWithStatus:@"Network write error"];
                } else {
                    self.bufferOffset += bytesWritten;
                }
            }
        } break;
        case NSStreamEventErrorOccurred: {
            NSLog(@"producer stream error %@", [aStream streamError]);
            [self _stopSendWithStatus:@"Stream open error"];
        } break;
        case NSStreamEventEndEncountered: {
            assert(NO);     // should never happen for the output stream
        } break;
        default: {
            assert(NO);
        } break;
    }
}

- (void)postConnection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
// A delegate method called by the NSURLConnection when the request/response 
// exchange is complete.  We look at the response to check that the HTTP 
// status code is 2xx.  If it isn't, we fail right now.
{
#pragma unused(theConnection)
    NSHTTPURLResponse * httpResponse;
    
    assert(theConnection == self.postConnection);
    
    httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    
    if ((httpResponse.statusCode / 100) != 2) {
        [self _stopSendWithStatus:[NSString stringWithFormat:@"HTTP error %zd", (ssize_t) httpResponse.statusCode]];
    } else {
        self.poststatusLabel.text = @"Response OK.";
    }    
}

- (void)postConnection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
// A delegate method called by the NSURLConnection as data arrives.  The 
// response data for a POST is only for useful for debugging purposes, 
// so we just drop it on the floor.
{
#pragma unused(theConnection)
#pragma unused(data)
    
    assert(theConnection == self.postConnection);
    
    // do nothing
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
// A delegate method called by the NSURLConnection if the connection fails. 
// We shut down the connection and display the failure.  Production quality code 
// would either display or log the actual error.
{
#pragma unused(theConnection)
#pragma unused(error)
    assert(theConnection == self.postConnection);
    
    [self _stopSendWithStatus:@"Connection failed"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
// A delegate method called by the NSURLConnection when the connection has been 
// done successfully.  We shut down the connection with a nil status, which 
// causes the image to be displayed.
{
#pragma unused(theConnection)
    assert(theConnection == self.postConnection);
    
    [self _stopSendWithStatus:nil];
}

#pragma mark * Actions

- (IBAction)sendAction:(UIView *)sender
{
    assert( [sender isKindOfClass:[UIView class]] );
    
    if ( ! self.isSending ) {
        NSString *  filePath;
        
        // User the tag on the UIButton to determine which image to send.
        
        filePath = [[AppDelegate sharedAppDelegate] pathForTestImage:sender.tag];
        assert(filePath != nil);
        
        [self _startSend:filePath];
    }
}

- (IBAction)cancelAction:(id)sender
{
#pragma unused(sender)
    [self _stopSendWithStatus:@"Cancelled"];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
// A delegate method called by the URL text field when the editing is complete. 
// We save the current value of the field in our settings.
{
#pragma unused(textField)
    NSString *  newValue;
    NSString *  oldValue;
    
    assert(textField == self.posturlText);
    
    newValue = self.posturlText.text;
    oldValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"PostURLText"];
    
    // Save the URL text if there is no pre-existing setting and it's not our 
    // default value, or if there is a pre-existing default and the new value 
    // is different.
    
    if (   ((oldValue == nil) && ! [newValue isEqual:kDefaultPostURLText] ) 
        || ((oldValue != nil) && ! [newValue isEqual:oldValue] ) ) {
        [[NSUserDefaults standardUserDefaults] setObject:newValue forKey:@"PostURLText"];
    }    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
// A delegate method called by the URL text field when the user taps the Return 
// key.  We just dismiss the keyboard.
{
#pragma unused(textField)
    assert(textField == self.posturlText);
    [self.posturlText resignFirstResponder];
    return NO;
}

#pragma mark * View controller boilerplate

@synthesize posturlText           = _posturlText;
@synthesize poststatusLabel       = _poststatusLabel;
@synthesize postactivityIndicator = _postactivityIndicator;
@synthesize postcancelButton      = _postcancelButton;



@end