//
//  BXChara2DState.mm
//  Karakuri Box
//
//  Created by numata on 10/03/08.
//  Copyright 2010 Satoshi Numata. All rights reserved.
//

#import "BXChara2DState.h"


@implementation BXChara2DState

- (id)initWithName:(NSString*)name
{
    self = [super init];
    if (self) {
        mName = [name copy];
        mStateID = 1;
    }
    return self;
}

- (void)dealloc
{
    [mName release];
    
    [super dealloc];
}

- (int)stateID
{
    return mStateID;
}

- (void)setStateID:(int)value
{
    mStateID = value;
}

- (NSString*)name
{
    return mName;
}

- (void)setName:(NSString*)name
{
    [mName release];
    mName = [name copy];
}

@end

