//
//  BXChara2DKomaPreviewView.h
//  Karakuri Box
//
//  Created by numata on 10/03/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class BXDocument;
@class BXChara2DKomaHitInfo;


@interface BXChara2DKomaPreviewView : NSView {
    IBOutlet BXDocument*    oDocument;
    IBOutlet NSPopUpButton* oActionCommandButton;
    
    int     mStartX;
    int     mStartY;
    int     mSizeX;
    int     mSizeY;
    double  mScale;
    
    BXChara2DKomaHitInfo*   mResizingHitInfo;
    
    BOOL    mIsResizingFromTop;
    BOOL    mIsResizingFromBottom;
    BOOL    mIsResizingFromLeft;
    BOOL    mIsResizingFromRight;
}

- (IBAction)doActionCommand:(id)sender;

- (void)selectHitInfo:(BXChara2DKomaHitInfo*)anInfo;
- (void)deselectHitInfo;
- (void)updateViewSize;

@end

