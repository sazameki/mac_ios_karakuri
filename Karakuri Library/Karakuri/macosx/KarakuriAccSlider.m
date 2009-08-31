//
//  KarakuriAccSlider.mm
//  Karakuri Library
//
//  Created by numata on 09/08/06.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "KarakuriAccSlider.h"


@implementation KarakuriAccSlider

- (void)setDelegate:(id)obj
{
    mDelegate = obj;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
    // set up our mouseUp event. 
    NSEvent *upEvent = [NSEvent mouseEventWithType:NSLeftMouseUp
                                          location:[theEvent locationInWindow] 
                                     modifierFlags:[theEvent modifierFlags]
                                         timestamp:[theEvent timestamp]
                                      windowNumber:[theEvent windowNumber]
                                           context:[NSGraphicsContext currentContext] 
                                       eventNumber:[theEvent eventNumber]
                                        clickCount:[theEvent clickCount]
                                          pressure:1.0];
    // dispatch mouse-up event
    [NSApp sendEvent:upEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [super mouseUp:theEvent];
    
    [self setFloatValue:0.0f];
    [self sendAction:[self action] to:[self target]];
}

@end
