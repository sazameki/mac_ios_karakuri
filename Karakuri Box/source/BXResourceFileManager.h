//
//  BXResourceFileManager.h
//  Karakuri Box
//
//  Created by numata on 10/03/09.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class BXDocument;


@interface BXResourceFileInfo : NSObject {
    BXDocument* mDocument;

    NSString*   mResourceName;
    
    NSString*   mFileName;
}

- (id)initWithFileAtPath:(NSString*)filepath document:(BXDocument*)document;
- (id)initWithFileName:(NSString*)fileName resourceName:(NSString*)resourceName document:(BXDocument*)document;

- (NSString*)fileName;

- (NSString*)resourceName;
- (void)setResourceName:(NSString*)name;

- (NSImage*)image72dpi;

@end


@interface BXResourceFileManager : NSObject {
    BXDocument*             mDocument;
    
    NSMutableDictionary*    mImageInfoMap;
}

- (id)initWithDocument:(BXDocument*)document;

- (int)storeImageFileAtPath:(NSString*)filepath;
- (NSString*)imageNameForTicket:(int)ticket;
- (NSImage*)image72dpiForTicket:(int)ticket;

- (NSData*)resourceMapData;
- (void)restoreResourceMapData:(NSData*)data;

@end

