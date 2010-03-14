//
//  BXResourceListView.mm
//  Karakuri Box
//
//  Created by numata on 10/03/14.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXResourceListView.h"
#import "BXDocument.h"


@implementation BXResourceListView

- (NSMenu*)menuForChara2D:(BXChara2DSpec*)theSpec
{
    NSMenu* theMenu = [[[NSMenu alloc] initWithTitle:@"Chara2D Menu"] autorelease];
    
    NSMenuItem* exportItem = [theMenu addItemWithTitle:NSLocalizedString(@"Export Chara2D", nil)
                                                action:@selector(exportSelectedResource:)
                                         keyEquivalent:@""];
    [exportItem setTarget:oDocument];
    
    // TODO: Chara2D複製のサポート
    /*NSMenuItem* dupItem = [theMenu addItemWithTitle:NSLocalizedString(@"Duplicate Chara2D", nil)
                                             action:@selector(duplicateSelectedChara2D:)
                                      keyEquivalent:@""];
    [dupItem setTarget:oDocument]; */

    [theMenu addItem:[NSMenuItem separatorItem]];    

    NSMenuItem* deleteItem = [theMenu addItemWithTitle:NSLocalizedString(@"Delete Chara2D", nil)
                                                action:@selector(removeSelectedChara2D:)
                                         keyEquivalent:@""];
    [deleteItem setTarget:oDocument];
    
    return theMenu;
}

- (NSMenu*)menuForParticle2D:(BXParticle2DSpec*)theSpec
{
    NSMenu* theMenu = [[[NSMenu alloc] initWithTitle:@"Particle2D Menu"] autorelease];

    NSMenuItem* exportItem = [theMenu addItemWithTitle:NSLocalizedString(@"Export Particle2D", nil)
                                             action:@selector(exportSelectedResource:)
                                      keyEquivalent:@""];
    [exportItem setTarget:oDocument];
    
    // TODO: Particle2D複製のサポート
    /*NSMenuItem* dupItem = [theMenu addItemWithTitle:NSLocalizedString(@"Duplicate Particle2D", nil)
                                             action:@selector(duplicateSelectedParticle2D:)
                                      keyEquivalent:@""];
    [dupItem setTarget:oDocument]; */
    
    [theMenu addItem:[NSMenuItem separatorItem]];

    NSMenuItem* deleteItem = [theMenu addItemWithTitle:NSLocalizedString(@"Delete Particle2D", nil)
                                                action:@selector(removeSelectedParticle2D:)
                                         keyEquivalent:@""];
    [deleteItem setTarget:oDocument];
    
    return theMenu;    
}

- (NSMenu*)menuForChara2DGroup:(BXResourceGroup*)theGroup
{
    NSMenu* theMenu = [[[NSMenu alloc] initWithTitle:@"Chara2D Group Menu"] autorelease];
    
    NSMenuItem* exportItem = [theMenu addItemWithTitle:NSLocalizedString(@"Add Chara2D", nil)
                                                action:@selector(addChara2D:)
                                         keyEquivalent:@""];
    [exportItem setTarget:oDocument];    
    
    return theMenu;
}

- (NSMenu*)menuForParticle2DGroup:(BXResourceGroup*)theGroup
{
    NSMenu* theMenu = [[[NSMenu alloc] initWithTitle:@"Particle2D Group Menu"] autorelease];
    
    NSMenuItem* exportItem = [theMenu addItemWithTitle:NSLocalizedString(@"Add Particle2D", nil)
                                                action:@selector(addParticle2D:)
                                         keyEquivalent:@""];
    [exportItem setTarget:oDocument];    
    
    return theMenu;
}

- (NSMenu*)menuForEvent:(NSEvent*)theEvent
{
    NSPoint pos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    int theRow = [self rowAtPoint:pos];
    id theItem = [self itemAtRow:theRow];
    
    if (theItem) {
        [self selectRowIndexes:[NSIndexSet indexSetWithIndex:theRow] byExtendingSelection:NO];
    }
    
    if ([theItem isKindOfClass:[BXChara2DSpec class]]) {
        return [self menuForChara2D:theItem];
    } else if ([theItem isKindOfClass:[BXParticle2DSpec class]]) {
        return [self menuForParticle2D:theItem];
    } else if (theItem == [oDocument chara2DGroup]) {
        return [self menuForChara2DGroup:theItem];
    } else if (theItem == [oDocument particle2DGroup]) {
        return [self menuForParticle2DGroup:theItem];
    }

    return nil;
}

@end

