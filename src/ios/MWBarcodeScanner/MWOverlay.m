//
//  MWOverlay.m
//  mobiscan_ALL
//  version 1.0
//
//  Created by vladimir zivkovic on 12/12/13.
//  Copyright (c) 2013 Manatee Works. All rights reserved.
//


#import "MWOverlay.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreText/CoreText.h>
#import "BarcodeScanner.h"

@implementation MWOverlay

CALayer *viewportLayer;
AVCaptureVideoPreviewLayer * previewLayer;
BOOL isAttached = NO;

MWOverlay *instance = nil;

+ (void)loadCustomFont:(NSURL *) fontURL {
  NSError *error;
  NSData *inData = [NSData dataWithContentsOfURL:fontURL options:NSDataReadingMappedIfSafe error: &error];
  if(inData) {
      CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)inData);
      CGFontRef font = CGFontCreateWithDataProvider(provider);
      if (font != NULL)
      {
          CFErrorRef error;
          if (CTFontManagerRegisterGraphicsFont(font, &error)) {
              //font can be used
              //here you can save font name for quick use in future
              NSString *fontName = (__bridge NSString *)CGFontCopyPostScriptName(font);
              NSLog(@"Loaded font with name : %@", fontName);
          }
      }
  }
}

+ (void)loadAllCustomFonts
{
  NSError *err;
  
  NSURL* fontPath = [[NSBundle mainBundle] URLForResource:@"www/fonts/OpenSans-Regular" withExtension:@"ttf"];
  if ([fontPath checkResourceIsReachableAndReturnError:&err] == YES) {
    [self loadCustomFont:fontPath];
  } else {
    NSLog(@"Open Sans Regular not found");
  }
  
  fontPath = [[NSBundle mainBundle] URLForResource:@"www/fonts/OpenSans-Bold" withExtension:@"ttf"];
  if ([fontPath checkResourceIsReachableAndReturnError:&err] == YES) {
    [self loadCustomFont:fontPath];
  } else {
    NSLog(@"Open Sans Bold not found");
  }

  fontPath = [[NSBundle mainBundle] URLForResource:@"www/fonts/ionicons" withExtension:@"ttf"];
  if ([fontPath checkResourceIsReachableAndReturnError:&err] == YES) {
    [self loadCustomFont:fontPath];
  } else {
    NSLog(@"Ionicons not found");
  }
}

+(CGRect)viewFinderFrame {
  return [self viewFinderFrame:(previewLayer.frame.size.width * 0.666) viewfinderHeight:(previewLayer.frame.size.height * 0.666)];
}

+(CGRect)viewFinderFrame:(float)viewfinderWidth viewfinderHeight:(float)viewfinderHeight {
  float x = (previewLayer.frame.size.width / 2 ) - (viewfinderWidth / 2);
  float y = 20 + ((previewLayer.frame.size.height - 20) / 2) - (viewfinderHeight / 2);
  return CGRectMake(x, y, viewfinderWidth, viewfinderHeight);
}

+(void)drawViewfinder {
  int fontSize = 260;
  NSString *label = @"\uf346";
  CGRect frame = [self viewFinderFrame];
  CGSize labelSize;
  UIFont *font;
  do {
    font = [UIFont fontWithName:@"Ionicons" size:fontSize];
    labelSize = [label sizeWithAttributes:@{NSFontAttributeName:font}];
    fontSize = fontSize + 4;
  } while (labelSize.width < frame.size.width);

  UILabel *viewFinder = [[UILabel alloc] initWithFrame:frame];
  viewFinder.font = font;
  viewFinder.textAlignment = NSTextAlignmentCenter;
  viewFinder.text = label;
  [viewFinder sizeToFit];
  viewFinder.frame = [self viewFinderFrame:viewFinder.frame.size.width viewfinderHeight: viewFinder.frame.size.height];
  
  NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
  [style setAlignment:NSTextAlignmentCenter];
  [style setLineBreakMode:NSLineBreakByWordWrapping];
  
  NSDictionary* attributes = @{
      NSFontAttributeName : font,
      NSParagraphStyleAttributeName : style,
      NSForegroundColorAttributeName : [UIColor colorWithRed:(68/255.f) green:(68/255.f) blue:(68/255.f) alpha:0.6]
  };
  [label drawInRect:viewFinder.frame withAttributes:attributes];
}

+(void)drawHelpLabel{
  UIFont *font = [UIFont fontWithName:@"OpenSans" size:24.0];
  
  UILabel *helpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, previewLayer.frame.size.width, previewLayer.frame.size.height)];
  helpLabel.font = font;
  helpLabel.textAlignment = NSTextAlignmentCenter;

  NSString *label = @"Scan your book's barcode\nto create a citation";
  NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
  if ([language isEqualToString:@"de"]) {
    label = @"Scan den Barcode eines Buchs um es als Quelle zu verwenden";
  }

  CGSize labelSize = [label sizeWithAttributes:@{NSFontAttributeName:helpLabel.font}];

  helpLabel.lineBreakMode = NSLineBreakByWordWrapping;
  helpLabel.numberOfLines = 0;

  helpLabel.text = label;

  UILabel *gettingSizeLabel = [[UILabel alloc] init];
  gettingSizeLabel.font = helpLabel.font;
  gettingSizeLabel.text = label;
  gettingSizeLabel.numberOfLines = 0;
  CGSize maximumLabelSize = CGSizeMake(previewLayer.frame.size.width, labelSize.height * 3);
  CGSize expectedSize = [gettingSizeLabel sizeThatFits:maximumLabelSize];

  helpLabel.frame = CGRectMake(0, previewLayer.frame.size.height - expectedSize.height - 20, previewLayer.frame.size.width, expectedSize.height);
  
  NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
  [style setAlignment:NSTextAlignmentCenter];
  [style setLineBreakMode:NSLineBreakByWordWrapping];

  CGSize myShadowOffset = CGSizeMake(1, -1);
  CGFloat myColorValues[] = {0, 0, 0, .8};

  CGContextRef myContext = UIGraphicsGetCurrentContext();
  CGContextSaveGState(myContext);

  CGColorSpaceRef myColorSpace = CGColorSpaceCreateDeviceRGB();
  CGColorRef myColor = CGColorCreate(myColorSpace, myColorValues);
  CGContextSetShadowWithColor (myContext, myShadowOffset, 5, myColor);

  NSDictionary* attributes = @{
      NSFontAttributeName : font,
      NSParagraphStyleAttributeName : style,
      NSForegroundColorAttributeName : [UIColor colorWithRed:255 green:255 blue:255 alpha:1.0]
  };
  [label drawInRect:helpLabel.frame withAttributes:attributes];

  CGColorRelease(myColor);
  CGColorSpaceRelease(myColorSpace);

  CGContextRestoreGState(myContext);
}


+ (void) addToPreviewLayer:(AVCaptureVideoPreviewLayer *) videoPreviewLayer
{
    [self loadAllCustomFonts];
    
    viewportLayer = [[CALayer alloc] init];
    viewportLayer.frame = CGRectMake(0, 0, videoPreviewLayer.frame.size.width, videoPreviewLayer.frame.size.height);
    
    [videoPreviewLayer addSublayer:viewportLayer];

    isAttached = YES;
    
    previewLayer = videoPreviewLayer;
    
    instance = [[MWOverlay alloc] init];
    [MWOverlay updateOverlay];
}

+ (void) removeFromPreviewLayer {
    
    if (!isAttached){
        return;
    }
    
    if (previewLayer){
        if (viewportLayer){
            [viewportLayer removeFromSuperlayer];
        }
    }
    
    isAttached = NO;
    
}

+ (void) updateOverlay{
    if (!isAttached || !previewLayer){
        return;
    }
    
    CGRect cgRect = viewportLayer.frame;
    UIGraphicsBeginImageContext(cgRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    [self drawViewfinder];
    
    [self drawHelpLabel];

    UIGraphicsPopContext();
    
    viewportLayer.contents = (id)[UIGraphicsGetImageFromCurrentImageContext() CGImage];
    
    UIGraphicsEndImageContext();
}

@end
