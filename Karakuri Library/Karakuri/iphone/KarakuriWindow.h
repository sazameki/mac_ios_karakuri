//
//  KarakuriWindow.h
//  Karakuri Prototype
//
//  Created by numata on 09/07/17.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import <Karakuri/KarakuriLibrary.h>

#import <Karakuri/iphone/KarakuriGLView.h>
#import <Karakuri/iphone/KRProxyView.h>


@interface KarakuriWindow : UIWindow {
    KarakuriGLView*     mGLView;
    KRProxyView*        mProxyView;
}

- (KarakuriGLView*)glView;
- (void)changeToSubScreenWindow;

@end


extern KarakuriWindow*  gKRWindowInst;

