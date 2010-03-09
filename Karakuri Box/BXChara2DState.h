//
//  BXChara2DState.h
//  Karakuri Box
//
//  Created by numata on 10/03/08.
//  Copyright 2010 Satoshi Numata. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BXChara2DKoma.h"


@class BXDocument;


@interface BXChara2DState : NSObject {
    int         mStateID;
    NSString*   mName;
    
    NSMutableArray* mKomas;
    
    int         mDefaultKomaInterval;
}

- (id)initWithName:(NSString*)name;

- (int)stateID;
- (void)setStateID:(int)value;

- (NSString*)name;
- (void)setName:(NSString*)name;

- (int)komaCount;
- (BXChara2DKoma*)insertKomaAtIndex:(int)index;
- (BXChara2DKoma*)komaAtIndex:(int)index;
- (int)moveKomaFrom:(int)fromIndex to:(int)toIndex;
- (void)removeKomaAtIndex:(int)index;

- (NSMenu*)makeKomaGotoMenuForKoma:(BXChara2DKoma*)koma document:(id)document;

- (int)defaultKomaInterval;

@end

