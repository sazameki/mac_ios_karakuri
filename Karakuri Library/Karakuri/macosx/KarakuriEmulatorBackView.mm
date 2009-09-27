//
//  KarakuriEmulatorBackView.mm
//  Karakuri Library
//
//  Created by numata on 09/08/06.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "KarakuriEmulatorBackView.h"
#import <Karakuri/KarakuriGame.h>


@implementation KarakuriEmulatorBackView

- (id)init
{
    NSRect frameRect = NSMakeRect(0, 0, 750+21, 414+21);
    if (gKRGameInst->getScreenWidth() < gKRGameInst->getScreenHeight()) {
        frameRect = NSMakeRect(0, 0, 414+21, 750+21);
    }
    self = [super initWithFrame:frameRect];
    if (self) {
        //[self setAlphaValue:0.0f];
        
        NSString *imageFilePath = @"/Developer/Extras/Karakuri/images/System/iPhone Emulator/iphone_emu_back.png";
        if (gKRGameInst->getScreenWidth() < gKRGameInst->getScreenHeight()) {
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
    if (gKRGameInst->getScreenWidth() > gKRGameInst->getScreenHeight()) {
        [mBackgroundImage compositeToPoint:NSMakePoint(3, 21) operation:NSCompositeSourceOver];
    } else {
        [mBackgroundImage compositeToPoint:NSMakePoint(3, 3) operation:NSCompositeSourceOver];
    }
}

@end
