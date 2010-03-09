//
//  BXChara2DSpec.h
//  Karakuri Box
//
//  Created by numata on 10/02/28.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXResourceElement.h"
#import "BXChara2DState.h"


@interface BXChara2DSpec : BXResourceElement {
    NSMutableArray*     mStates;
}

- (BXChara2DState*)addNewState;
- (int)stateCount;
- (BXChara2DState*)stateAtIndex:(int)index;

@end

