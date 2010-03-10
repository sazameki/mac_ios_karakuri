//
//  BXChara2DKomaListView.m
//  Karakuri Box
//
//  Created by numata on 10/03/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXChara2DKomaListView.h"


@implementation BXChara2DKomaListView

- (void)keyDown:(NSEvent*)theEvent
{
    unsigned short keyCode = [theEvent keyCode];
    
    // Backspace / Delete
    if (keyCode == 0x33 || keyCode == 0x75) {
        [oDocument removeSelectedChara2DKoma];
    }
    // Otherwise
    else {
        [super keyDown:theEvent];
    }
}

@end

