//
//  BXChara2DState.mm
//  Karakuri Box
//
//  Created by numata on 10/03/08.
//  Copyright 2010 Satoshi Numata. All rights reserved.
//

#import "BXChara2DState.h"
#import "BXDocument.h"
#import "NSMutableArray+Moving.h"


@interface BXChara2DState ()

- (void)renumberKomas;

@end


@implementation BXChara2DState

- (id)initWithName:(NSString*)name
{
    self = [super init];
    if (self) {
        mName = [name copy];
        mStateID = 1;
        mKomas = [[NSMutableArray alloc] init];
        
        mDefaultKomaInterval = 4;
    }
    return self;
}

- (void)dealloc
{
    [mName release];
    [mKomas release];
    
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

- (void)renumberKomas
{
    for (int i = 0; i < [mKomas count]; i++) {
        BXChara2DKoma* aKoma = [mKomas objectAtIndex:i];
        [aKoma setKomaNumber:i+1];
    }
}

- (int)komaCount
{
    return [mKomas count];
}

- (BXChara2DKoma*)insertKomaAtIndex:(int)index
{
    BXChara2DKoma* aKoma = [[[BXChara2DKoma alloc] init] autorelease];
    [mKomas insertObject:aKoma atIndex:index];
    [self renumberKomas];
    return aKoma;
}

- (int)moveKomaFrom:(int)fromIndex to:(int)toIndex
{
    int ret = [mKomas moveObjectAtIndex:fromIndex beforeIndex:toIndex];
    [self renumberKomas];
    return ret;
}

- (BXChara2DKoma*)komaAtIndex:(int)index
{
    return [mKomas objectAtIndex:index];
}

- (void)removeKomaAtIndex:(int)index
{
    BXChara2DKoma* theKoma = [mKomas objectAtIndex:index];
    BXChara2DImage* theImage = [theKoma image];
    [theImage decrementUsedCount];
    [mKomas removeObjectAtIndex:index];
}

- (NSMenu*)makeKomaGotoMenuForKoma:(BXChara2DKoma*)koma document:(id)document
{
    NSMenu* ret = [[[NSMenu alloc] initWithTitle:@"Koma Goto Popup Menu"] autorelease];
    
    NSMenuItem* noneItem = [ret addItemWithTitle:@"----" action:@selector(changedChara2DKomaGotoTarget:) keyEquivalent:@""];
    [noneItem setTag:0];
    [noneItem setTarget:document];
    
    int sourceIndex = [koma komaNumber] - 1;
    
    for (int i = 0; i < [mKomas count]; i++) {
        if (i == sourceIndex) {
            continue;
        }
        
        NSMenuItem* menuItem = [ret addItemWithTitle:[NSString stringWithFormat:@"%d", i+1]
                                              action:@selector(changedChara2DKomaGotoTarget:)
                                       keyEquivalent:@""];
        [menuItem setTag:i+1];
        [menuItem setTarget:document];
    }
    
    return ret;
}

- (int)defaultKomaInterval
{
    return mDefaultKomaInterval;
}

@end

