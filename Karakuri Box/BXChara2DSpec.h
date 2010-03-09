//
//  BXChara2DSpec.h
//  Karakuri Box
//
//  Created by numata on 10/02/28.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXResourceElement.h"
#import "BXChara2DState.h"
#import "BXChara2DImage.h"


@interface BXChara2DSpec : BXResourceElement {
    NSMutableArray*     mStates;

    NSMutableArray* mImages;
}

- (BXChara2DState*)addNewState;
- (int)stateCount;
- (BXChara2DState*)stateAtIndex:(int)index;
- (void)removeState:(BXChara2DState*)theState;

- (BXChara2DImage*)addImageAtPath:(NSString*)path document:(BXDocument*)document;
- (int)imageCount;
- (BXChara2DImage*)imageAtIndex:(int)index;

@end

