/*
     File: MyViewController.h 
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

#import <UIKit/UIKit.h>
#import "OverlayViewController.h"

#pragma mark -
#pragma mark MyViewController

// ******************************* MyViewController ********************  

@interface MyViewController : UIViewController <UIImagePickerControllerDelegate,
                                                OverlayViewControllerDelegate,
                                                UITextFieldDelegate>
{
  
    UIImageView *imageView;
    UIToolbar *myToolbar;
    
    OverlayViewController *overlayViewController; // the camera custom overlay view

    NSMutableArray *capturedImages; // the list of images captures from the camera (either 1 or multiple)
 
            
// ******************************* GetController ********************    
    UITextField *               _geturlText;
    UIImageView *               _getimageView;
    UILabel *                   _getstatusLabel;
    UIActivityIndicatorView *   _getactivityIndicator;
    UIBarButtonItem *           _getOrCancelButton;
    
    // NSString interface
    NSURLConnection *           _connection;
    NSString *                  _filePath;
    NSOutputStream *            _fileStream;    
    NSRange *                   _foundRange;
    
    
// ******************************* PostController ********************
    UITextField *               _posturlText;
    UILabel *                   _poststatusLabel;
    UIActivityIndicatorView *   _postactivityIndicator;
    UIBarButtonItem *           _cancelButton;
    
    NSURLConnection *           _postconnection;
    NSData *                    _bodyPrefixData;
    NSInputStream *             _postfileStream;
    NSData *                    _bodySuffixData;
    NSOutputStream *            _producerStream;
    NSInputStream *             _consumerStream;
    const uint8_t *             _buffer;
    uint8_t *                   _bufferOnHeap;
    size_t                      _bufferOffset;
    size_t                      _bufferLimit;
}

#pragma mark Properties and Actions 

//                      ****** Properties and Actions *********


// ******************************* MyViewController ********************  

@property (nonatomic, retain) IBOutlet UIImageView *               imageView;
@property (nonatomic, retain) IBOutlet UIToolbar *                 myToolbar;
@property (nonatomic, retain) OverlayViewController *              overlayViewController;
@property (nonatomic, retain) NSMutableArray *                     capturedImages;

// toolbar buttons
- (IBAction)photoLibraryAction:(id)sender;
- (IBAction)cameraAction:(id)sender;



// ******************************* GetController ********************

@property (nonatomic, retain) IBOutlet UITextField *               geturlText;
@property (nonatomic, retain) IBOutlet UIImageView *               getimageView;
@property (nonatomic, retain) IBOutlet UILabel *                   getstatusLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *   getactivityIndicator;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *           getOrCancelButton;

// NSString interface
@property (nonatomic, readonly) BOOL              isReceiving;
@property (nonatomic, retain)   NSURLConnection * getConnection; // **
@property (nonatomic, copy)     NSString *        filePath;
@property (nonatomic, retain)   NSOutputStream *  getFileStream;  // **
@property                       NSRange *         foundRange;

// toolbar buttons
- (IBAction)getOrCancelAction:(id)sender;





// ******************************* PostController ********************

@property (nonatomic, retain) IBOutlet UITextField *               posturlText;
@property (nonatomic, retain) IBOutlet UILabel *                   poststatusLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *   postactivityIndicator;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *           postcancelButton;

// post controller interface
@property (nonatomic, readonly) BOOL              isSending;
@property (nonatomic, retain)   NSURLConnection * postConnection;  // **
@property (nonatomic, copy)     NSData *          bodyPrefixData;
@property (nonatomic, retain)   NSInputStream *   postFileStream;  // **
@property (nonatomic, copy)     NSData *          bodySuffixData;
@property (nonatomic, retain)   NSOutputStream *  producerStream;
@property (nonatomic, retain)   NSInputStream *   consumerStream;
@property (nonatomic, assign)   const uint8_t *   buffer;
@property (nonatomic, assign)   uint8_t *         bufferOnHeap;
@property (nonatomic, assign)   size_t            bufferOffset;
@property (nonatomic, assign)   size_t            bufferLimit;

- (IBAction)sendAction:(UIView *)sender;
- (IBAction)cancelAction:(id)sender;



@end


