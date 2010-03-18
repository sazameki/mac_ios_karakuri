//
//  BXResourceImporter.h
//  Karakuri Library
//
//  Created by numata on 10/03/17.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#pragma once

#include <Karakuri/Karakuri.h>

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#endif
#endif

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
#ifdef __OBJC__
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#endif
#endif


typedef enum {
    BXResourceTypeUnknown       = 0,
    BXResourceTypeEndMark       = 1,

    BXResourceTypeTexture2D     = 10,
    BXResourceTypeData          = 11,

    BXResourceTypeChara2D       = 20,
    BXResourceTypeParticle2D    = 30,

} BXResourceType;


@interface BXImportContext : NSObject {
    NSData*     mData;
    unsigned    mPos;
}

- (id)initWithFileAtPath:(NSString*)filepath;

- (BOOL)checkMagic:(const char*)magic;
- (BXResourceType)checkResourceType;

- (unsigned)currentPos;
- (void)reset;

- (void)readBytes:(void*)buffer length:(unsigned)length;
- (NSData*)readDataWithLength:(unsigned)length;
- (unsigned)readUnsignedIntValue;
- (void)skip:(unsigned)length;

@end


@interface BXResourceImporter : NSObject {
    BXImportContext*    mContext;
    NSString*           mFileName;
}

- (id)initWithFileName:(NSString*)fileName;

- (void)importPrimitiveResources;
- (void)importRichResources;

@end
