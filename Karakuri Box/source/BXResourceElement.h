//
//  BXResourceElement.h
//  Karakuri Box
//
//  Created by numata on 10/02/27.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class BXDocument;


@interface BXResourceElement : NSObject {
    BXDocument*         mDocument;
    
    int                 mGroupID;
    int                 mResourceID;
    NSString*           mResourceName;

    BXResourceElement*  mParentElement;
    NSMutableArray*     mChildElements;
}

- (id)initWithName:(NSString*)name;

- (BXDocument*)document;
- (void)setDocument:(BXDocument*)aDocument;

- (NSString*)localizedName;
- (BOOL)isExpandable;
- (BOOL)isGroupItem;

- (int)groupID;
- (int)resourceID;
- (NSString*)resourceName;
- (void)setGroupID:(int)theID;
- (void)setResourceID:(int)theID;
- (void)setResourceName:(NSString*)name;

- (void)addChild:(BXResourceElement*)anElem;
- (int)childCount;
- (BXResourceElement*)childAtIndex:(int)index;
- (void)removeChild:(BXResourceElement*)anElem;

- (void)sortChildrenByResourceID;

- (NSDictionary*)elementInfo;
- (void)restoreElementInfo:(NSDictionary*)theInfo document:(BXDocument*)document;

@end


@interface BXResourceElement (Export)

- (void)exportToFileHandle:(NSFileHandle*)fileHandle;

@end

