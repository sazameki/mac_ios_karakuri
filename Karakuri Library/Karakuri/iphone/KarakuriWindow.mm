//
//  KarakuriWindow.mm
//  Karakuri Prototype
//
//  Created by numata on 09/07/17.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "KarakuriWindow.h"


KarakuriWindow* gKRWindowInst = nil;


@implementation KarakuriWindow

- (id)init
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self = [super initWithFrame:bounds];
    if (self) {
        gKRWindowInst = self;

        self.backgroundColor = [UIColor whiteColor];
        
        mGLView = [[KarakuriGLView alloc] initWithScreenSize:bounds.size];
        [self addSubview:mGLView];
    }
    return self;
}

- (void)dealloc
{
    [mGLView release];
    
    [super dealloc];
}

@end


