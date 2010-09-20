//
//  BXTexture2DPreviewView.h
//  Karakuri Box
//
//  Created by numata on 10/09/20.
//  Copyright 2010 Satoshi Numata. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BXTexture2DSpec.h"


@class BXDocument;


@interface BXTexture2DPreviewView : NSView {
    IBOutlet BXDocument*    oDocument;
}

- (void)updateFrame;

@end

