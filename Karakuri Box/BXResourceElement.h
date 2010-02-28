//
//  BXResourceElement.h
//  Karakuri Box
//
//  Created by numata on 10/02/27.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BXResourceElement : NSObject {
    NSString*           mName;

    BXResourceElement*  mParentElement;
    NSMutableArray*     mChildElements;
}

- (id)initWithName:(NSString*)name;

- (NSString*)localizedName;
- (BOOL)isExpandable;
- (BOOL)isGroupItem;

- (void)addChild:(BXResourceElement*)anElem;
- (int)childCount;
- (BXResourceElement*)childAtIndex:(int)index;
- (void)removeChild:(BXResourceElement*)anElem;

@end

