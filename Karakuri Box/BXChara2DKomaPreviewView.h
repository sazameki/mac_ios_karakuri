//
//  BXChara2DKomaPreviewView.h
//  Karakuri Box
//
//  Created by numata on 10/03/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class BXDocument;


@interface BXChara2DKomaPreviewView : NSView {
    IBOutlet BXDocument*    oDocument;
}

- (void)updateViewSize;

@end

