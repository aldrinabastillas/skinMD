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
 Edited  by: Aldrin Abastillas, 2012
  
 */

#import "AppDelegate.h"
#import "MyViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"


@interface MyViewController ()

@property (nonatomic, readonly) BOOL              isReceiving;
@property (nonatomic, retain)   NSURLConnection * connection;
@property (nonatomic, copy)     NSString *        filePath;
@property (nonatomic, retain)   NSOutputStream *  fileStream;

@end

@implementation MyViewController

@synthesize imageView, myToolbar, overlayViewController, capturedImages;

#pragma mark -
#pragma mark View Controller

- (void)viewDidLoad
{
    self.overlayViewController =
        [[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil] autorelease];

    // as a delegate we will be notified when pictures are taken and when to dismiss the image picker
    self.overlayViewController.delegate = self;
    
    self.capturedImages = [NSMutableArray array];
    self.sendButton.possibleTitles = [NSSet setWithObjects:@"Send", @"Sent !", @"Cancel", nil];
    self.sendButton.enabled = NO;
    self.clearButton.enabled = NO;
    self.stopWatchLabel.text = @"";
    self.statusLabel.text = @"To start, take a picture using the camera or select a picture from the roll";
    self.activityIndicator.hidden = YES;
    self.imageView.image = nil;

}

- (void)viewDidUnload
{
    self.imageView = nil;
    self.myToolbar = nil;    
    self.overlayViewController = nil;
    self.capturedImages = nil;
    self.sendButton = nil;
    self.clearButton = nil;
    self.stopWatchLabel = nil;
    self.statusLabel = nil;
    self.activityIndicator = nil;
}

- (void)dealloc
{	
	[imageView release];
	[myToolbar release];
    [overlayViewController release];
	[capturedImages release];
    [sendButton release];
    [clearButton release];
    [stopWatchLabel release];
    [statusLabel release];
    [activityIndicator release];
    
    [super dealloc];
}

#pragma mark * View controller boilerplate

@synthesize sendButton           = sendButton;
@synthesize clearButton          = clearButton;
@synthesize stopWatchLabel       = stopWatchLabel;
@synthesize statusLabel          = statusLabel;
@synthesize activityIndicator    = activityIndicator;


#pragma mark -
#pragma mark Toolbar Actions

- (IBAction)clear:(id)sender
{
    [self viewDidLoad];
}

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
    sleep(0.4);
    self.sendButton.enabled = YES;
    self.sendButton.title = @"Send";     
    self.statusLabel.text = @"Hit Send !";
    self.clearButton.enabled = YES;
}

- (IBAction)cameraAction:(id)sender
{
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
//    {
//        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
//        imagePickerController.delegate = self;
//        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
//        [self presentModalViewController:imagePickerController animated:YES];
//        [imagePickerController release];
//        
//        sleep(0.4);
//        self.sendButton.enabled = YES;
//        self.sendButton.title = @"Send";         
//        self.statusLabel.text = @"Hit Send !";
//        self.clearButton.enabled = YES;
//    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
        
        sleep(0.4);
        self.sendButton.enabled = YES;
        self.sendButton.title = @"Send";         
        self.statusLabel.text = @"Hit Send !";
        self.clearButton.enabled = YES;
        
    }
    else
    {
        UIAlertView *newView = [[UIAlertView alloc] initWithTitle:nil 
                                                          message:@"Camera Not Available !"
                                                         delegate:nil 
                                                cancelButtonTitle:@"Close" 
                                                otherButtonTitles:nil];
        [newView show];
        [newView release];
    }
}

- (IBAction)sendImage:(id)sender
{   
    self.sendButton.enabled = NO;
    self.clearButton.enabled = NO;
    [self.activityIndicator startAnimating];
    self.statusLabel.text = @"";

    if (self.imageView.image != nil){
    imageName = [NSString stringWithFormat:@"imageTime_%qu.jpg" , [[NSDate date] timeIntervalSince1970]];
    
    // Create the stop watch timer that fires every 0.1 ms
    startDate = [[NSDate date]retain];
    stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:0.0
                                                      target:self
                                                    selector:@selector(updateTimer)
                                                    userInfo:nil
                                                     repeats:YES];   
        
    NSData * imageData = UIImageJPEGRepresentation(self.imageView.image, 0.25);
        
    NSURL *postURL = [NSURL URLWithString:@"http://li245-100.members.linode.com/upload"];
            
                  
    __block ASIFormDataRequest * postRequest = [ASIFormDataRequest requestWithURL:postURL];
    
    [postRequest appendPostData:imageData];    
    [postRequest setRequestMethod:@"POST"];
    [postRequest setData:imageData withFileName: imageName andContentType:@"image/jpeg" forKey:@"photo"];    
    [postRequest setDelegate:self];
        
    [postRequest setCompletionBlock:^{
        self.sendButton.title = @"Sent !";  
        
        [self getResult];
        
    }];
        
    [postRequest setFailedBlock:^{
        NSError *error = [postRequest error];
        self.statusLabel.text = [error localizedDescription];
        [stopWatchTimer invalidate];
        stopWatchTimer = nil;
        [self updateTimer]; 
        
        self.sendButton.enabled = YES;
        self.clearButton.enabled = YES;
        self.sendButton.title = @"Send";
        [self.activityIndicator stopAnimating];
        }];
        
           
    [postRequest startAsynchronous]; 
        
    }
    else{
        UIAlertView *newView = [[UIAlertView alloc] initWithTitle:nil 
                                                    message:@"Take or Select Picture First"
                                                    delegate:nil 
                                                    cancelButtonTitle:@"Close" 
                                                    otherButtonTitles:nil];
        [newView show];
        [newView release];        
    }  
}

- (void)updateTimer
{
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:startDate];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"sss.SSS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSString *timeString=[dateFormatter stringFromDate:timerDate];
    self.stopWatchLabel.text = [timeString stringByAppendingString:@" s"];
    [dateFormatter release];
}


#pragma mark -
#pragma mark Get Actions

@synthesize connection    = _connection;
@synthesize fileStream    = _fileStream;
@synthesize filePath      = _filePath;


- (BOOL)isReceiving
{
    return (self.connection != nil);
}


-(void)getResult{
    
    NSString *getString = [@"http://li245-100.members.linode.com/mobile/results/" stringByAppendingString: imageName];
    NSURL *getURL = [NSURL URLWithString:getString];
    
//    // testing URL until algorithm is finalized on the server
//    NSURL *getURL = [NSURL URLWithString:@"http://thewallmachine.com/files/1323133721.jpg"];
    
    NSURLRequest * request;
    
    assert(self.connection == nil);         // don't tap receive twice in a row!
    assert(self.fileStream == nil);         // ditto
    assert(self.filePath == nil);           // ditto
    
    // Open a stream for the file we're going to receive into.
        
    self.filePath = [[AppDelegate sharedAppDelegate] pathForTemporaryFileWithPrefix:@"Get"];
    assert(self.filePath != nil);
        
    self.fileStream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:NO];
    assert(self.fileStream != nil);
        
    [self.fileStream open];
        
    // Open a connection for the URL.
        
    request = [NSURLRequest requestWithURL:getURL];
    assert(request != nil);
        
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    assert(self.connection != nil);  
    
}

- (void)_receiveDidStopWithStatus:(NSString *)statusString   // ***** last get method block 
{
    
    [stopWatchTimer invalidate];
    stopWatchTimer = nil;
    [self updateTimer]; 
    
    if (statusString == nil) {
        assert(self.filePath != nil);
        
        self.imageView.image = [UIImage imageWithContentsOfFile:self.filePath];
//        self.statusLabel.text = self.filePath;
//        NSLog(self.filePath);
    }
//
//    self.statusLabel.text = statusString;
    self.sendButton.title = @"Send";
    self.sendButton.enabled = NO;
    self.clearButton.enabled = YES;
    [self.activityIndicator stopAnimating];
    
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
// A delegate method called by the NSURLConnection when the request/response 
// exchange is complete.  We look at the response to check that the HTTP 
// status code is 2xx and that the Content-Type is acceptable.  If these checks 
// fail, we give up on the transfer.
{
#pragma unused(theConnection)
    NSHTTPURLResponse * httpResponse;
    NSString *          contentTypeHeader;
    
    assert(theConnection == self.connection);
    
    httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    
    if ((httpResponse.statusCode / 100) != 2) {
        [self _stopReceiveWithStatus:[NSString stringWithFormat:@"HTTP error %zd", (ssize_t) httpResponse.statusCode]];
    } else {
        contentTypeHeader = [httpResponse.allHeaderFields objectForKey:@"Content-Type"];
        if (contentTypeHeader == nil) {
            [self _stopReceiveWithStatus:@"No Content-Type!"];
        } else {
            self.statusLabel.text = @"Response OK.";
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
    
    assert(theConnection == self.connection);
    
    dataLength = [data length];
    dataBytes  = [data bytes];
    
    bytesWrittenSoFar = 0;
    do {
        bytesWritten = [self.fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
        assert(bytesWritten != 0);
        if (bytesWritten == -1) {
            [self _stopReceiveWithStatus:@"File write error"];
            break;
        } else {
            bytesWrittenSoFar += bytesWritten;
        }
    } while (bytesWrittenSoFar != dataLength);
}


- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
// A delegate method called by the NSURLConnection if the connection fails. 
// We shut down the connection and display the failure.  Production quality code 
// would either display or log the actual error.
{
    assert(theConnection == self.connection);
//    [self _stopReceiveWithStatus: [error localizedFailureReason]];
    [self _stopReceiveWithStatus:@" Connection failed"];

}


- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
// A delegate method called by the NSURLConnection when the connection has been 
// done successfully.  We shut down the connection with a nil status, which 
// causes the image to be displayed.
{
#pragma unused(theConnection)
    assert(theConnection == self.connection);
    
    [self _stopReceiveWithStatus:nil];
}

- (void)_stopReceiveWithStatus:(NSString *)statusString
// Shuts down the connection and displays the result (statusString == nil) 
// or the error status (otherwise).
{
    if (self.connection != nil) {
        [self.connection cancel];
        self.connection = nil;
    }
    if (self.fileStream != nil) {
        [self.fileStream close];
        self.fileStream = nil;
    }
    
    [self _receiveDidStopWithStatus:statusString];   // ****** goes to last method block
    self.filePath = nil;
    
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

@end 
