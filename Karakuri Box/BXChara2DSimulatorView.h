//
//  BXChara2DSimulatorView.h
//  Karakuri Box
//
//  Created by numata on 10/03/11.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXOpenGLView.h"
#import "KRColor.h"
#import "BXChara2DSpec.h"
#import "BXChara2DState.h"
#import "BXChara2DKoma.h"
#import "KRTexture2D.h"
#import "KarakuriTypes.h"


@interface BXChara2DSimulatorView : BXOpenGLView {
    NSTimer*    mTimer;
    
    BXChara2DSpec*  mTargetSpec;

    BXChara2DState* mCurrentState;
    BXChara2DKoma*  mCurrentKoma;
    int             mKomaNumber;
    int             mKomaInterval;
    
    KRVector2D*     mCurrentPos;
}

- (void)startAnimation;
- (void)stopAnimation;

- (void)setupForChara2DSpec:(BXChara2DSpec*)aSpec;

@end

