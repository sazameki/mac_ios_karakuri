//
//  BXChara2DState.h
//  Karakuri Box
//
//  Created by numata on 10/03/08.
//  Copyright 2010 Satoshi Numata. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BXChara2DState : NSObject {
    int         mStateID;
    NSString*   mName;
}

- (id)initWithName:(NSString*)name;

- (int)stateID;
- (void)setStateID:(int)value;

- (NSString*)name;
- (void)setName:(NSString*)name;

@end

