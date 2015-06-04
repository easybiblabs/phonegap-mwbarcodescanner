//
//  MWOverlay.h
//  mobiscan_ALL
//
//  Created by vladimir zivkovic on 12/12/13.
//  Copyright (c) 2013 Manatee Works. All rights reserved.
//

#import "MWScannerViewController.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MWOverlay : NSObject

+ (void) addToPreviewLayer:(AVCaptureVideoPreviewLayer *) videoPreviewLayer viewController:(MWScannerViewController *) passedViewController;
+ (void) removeFromPreviewLayer;
+ (void) updateOverlay;

@property (nonatomic, retain) AVCaptureVideoPreviewLayer * previewLayer;
@property (nonatomic, retain) MWScannerViewController * viewController;

@end
