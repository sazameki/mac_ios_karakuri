//
//  KarakuriWindow.mm
//  Karakuri Prototype
//
//  Created by numata on 09/07/17.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "KarakuriWindow.h"


KarakuriWindow *KRWindowInst = nil;


@implementation KarakuriWindow

- (id)init
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        KRWindowInst = self;

        self.backgroundColor = [UIColor whiteColor];
        
        mGLView = [KarakuriGLView new];
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


