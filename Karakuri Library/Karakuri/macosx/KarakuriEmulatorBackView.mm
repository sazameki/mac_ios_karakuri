//
//  KarakuriEmulatorBackView.mm
//  Karakuri Library
//
//  Created by numata on 09/08/06.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "KarakuriEmulatorBackView.h"
#import <Karakuri/KRGameManager.h>


@implementation KarakuriEmulatorBackView

- (id)init
{
    int width = gKRGameMan->getScreenWidth();
    int height = gKRGameMan->getScreenHeight();

    NSRect frameRect;

    // iPhone
    if (width < 500 || height < 500) {
        if (width > height) {
            frameRect = NSMakeRect(0, 0, 750+21, 414+21);
        } else {
            frameRect = NSMakeRect(0, 0, 414+21, 750+21);
        }
    }
    // iPad
    else {
        if (width > height) {
            frameRect = NSMakeRect(0, 0, 1024+21*2, 768+21*2);
        } else {
            frameRect = NSMakeRect(0, 0, 768+21*2, 1024+21*2);
        }
    }

    self = [super initWithFrame:frameRect];
    if (self) {
        //[self setAlphaValue:0.0f];
        
        NSString* imageFilePath = @"/Developer/Extras/Karakuri/images/System/iPhone Emulator/iphone_emu_back.png";
        if (gKRGameMan->getScreenWidth() < gKRGameMan->getScreenHeight()) {
            imageFilePath = @"/Developer/Extras/Karakuri/images/System/iPhone Emulator/iphone_emu_back2.png";
        }
        mBackgroundImage = [[NSImage alloc] initWithContentsOfFile:imageFilePath];
    }
    return self;
}

- (void)dealloc
{
    [mBackgroundImage release];
    [super dealloc];
}

- (void)drawRect:(NSRect)rect
{
    int width = gKRGameMan->getScreenWidth();
    int height = gKRGameMan->getScreenHeight();
    
    // iPhone
    if (width < 500 || height < 500) {
        if (width > height) {
            [mBackgroundImage compositeToPoint:NSMakePoint(0, 0) operation:NSCompositeSourceOver];
        } else {
            [mBackgroundImage compositeToPoint:NSMakePoint(0, -20) operation:NSCompositeSourceOver];
        }
    }
    // iPad
    else {
        [[NSColor blackColor] set];
        NSRectFill(rect);
    }
}

@end
