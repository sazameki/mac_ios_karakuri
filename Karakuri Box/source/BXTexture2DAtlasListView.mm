//
//  BXTexture2DAtlasListView.mm
//  Karakuri Box
//
//  Created by numata on 10/09/22.
//  Copyright 2010 Satoshi Numata. All rights reserved.
//

#import "BXTexture2DAtlasListView.h"
#import "BXDocument.h"


@implementation BXTexture2DAtlasListView

- (void)keyDown:(NSEvent*)theEvent
{
    unsigned short keyCode = [theEvent keyCode];
    
    // Backspace / Delete
    if (keyCode == 0x33 || keyCode == 0x75) {
        [oDocument removeSelectedTexture2DAtlas];
    }
    // Otherwise
    else {
        [super keyDown:theEvent];
    }
}

@end

