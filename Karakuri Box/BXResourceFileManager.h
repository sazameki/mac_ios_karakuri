//
//  BXResourceFileManager.h
//  Karakuri Box
//
//  Created by numata on 10/03/09.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BXResourceFileInfo : NSObject {
    NSString*   mResourceName;
    
    NSString*   mFilepath;  // TODO: テンポラリの保存場所のサポート
}

- (id)initWithFileAtPath:(NSString*)filepath;

- (NSString*)resourceName;
- (void)setResourceName:(NSString*)name;

- (NSImage*)image72dpi;

@end


@interface BXResourceFileManager : NSObject {
    NSMutableDictionary*    mImageInfoMap;
}

- (int)storeImageFileAtPath:(NSString*)filepath;
- (NSString*)imageNameForTicket:(int)ticket;
- (NSImage*)image72dpiForTicket:(int)ticket;

@end

