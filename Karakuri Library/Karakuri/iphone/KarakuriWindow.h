//
//  KarakuriWindow.h
//  Karakuri Prototype
//
//  Created by numata on 09/07/17.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import <Karakuri/KarakuriLibrary.h>

#import <Karakuri/iphone/KarakuriGLView.h>


@interface KarakuriWindow : UIWindow {
    KarakuriGLView      *mGLView;
}

@end


extern KarakuriWindow *gKRWindowInst;

