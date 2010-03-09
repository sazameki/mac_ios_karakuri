//
//  BXChara2DAtlasView.h
//  Karakuri Box
//
//  Created by numata on 10/03/09.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BXGlobals.h"


@class BXDocument;


@interface BXChara2DAtlasView : NSView {
    IBOutlet BXDocument*    oDocument;

    NSMutableIndexSet*      mSelectionIndexes;
    int                     mLastSelectedIndex;
    
    BOOL                    mHasSelectedAtlasImage;
}

- (NSSize)minSize;

- (void)deselectAll;

@end

