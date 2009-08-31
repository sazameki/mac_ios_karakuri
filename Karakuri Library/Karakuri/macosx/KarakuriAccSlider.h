//
//  KarakuriAccSlider.h
//  Karakuri Library
//
//  Created by numata on 09/08/06.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface KarakuriAccSlider : NSSlider {
    id  mDelegate;
}

- (void)setDelegate:(id)obj;

@end
