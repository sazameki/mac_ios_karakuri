//
//  KRProxyView.h
//  Karakuri Library
//
//  Created by numata on 10/07/21.
//  Copyright 2010 Satoshi Numata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Karakuri/KarakuriLibrary.h>
#import <Karakuri/iphone/KarakuriGLView.h>


@interface KRProxyView : UIView {
    KarakuriGLView*     mGLView;
    NSTimer*            mTimer;
    UIImage*            mScreenImage;
}

- (void)setGLView:(KarakuriGLView*)glView;

@end

