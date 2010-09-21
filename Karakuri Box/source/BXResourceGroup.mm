//
//  BXResourceGroup.m
//  Karakuri Box
//
//  Created by numata on 10/02/27.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXResourceGroup.h"
#import "BXDocument.h"


@implementation BXResourceGroup

#pragma mark -
#pragma mark 項目の管理

- (BOOL)isExpandable
{
    return YES;
}

- (BOOL)isGroupItem
{
    return YES;
}

- (NSData*)groupData
{
    NSMutableArray* infos = [NSMutableArray array];
    
    int count = [self childCount];
    for (int i = 0; i < count; i++) {
        BXResourceElement* aSpec = (BXResourceElement*)[self childAtIndex:i];
        [infos addObject:[aSpec elementInfo]];
    }
    
    return [NSPropertyListSerialization dataFromPropertyList:infos format:NSPropertyListBinaryFormat_v1_0 errorDescription:nil];    
}

- (void)exportIDsToString:(NSMutableString*)str
{
    int count = [self childCount];
    for (int i = 0; i < count; i++) {
        BXResourceElement* aSpec = (BXResourceElement*)[self childAtIndex:i];
        NSMutableString* resourceName = [NSMutableString stringWithString:[aSpec resourceName]];
        [resourceName replaceOccurrencesOfString:@" "
                                      withString:@""
                                         options:0
                                           range:NSMakeRange(0, [resourceName length])];
        int resourceID = [aSpec resourceID];
        [str appendString:@"        "];
        [str appendString:resourceName];
        int spaceCount = 20 - [resourceName length];
        if (spaceCount <= 0) {
            spaceCount = 1;
        }
        for (int j = 0; j < spaceCount; j++) {
            [str appendString:@" "];
        }
        [str appendFormat:@"= %d,\n", resourceID];
    }
}

@end


@implementation BXResourceGroup (Texture2DSerialization)

- (NSMenu*)menuForTextures
{
    NSMenu* menu = [[NSMenu alloc] initWithTitle:@"Textures"];
    
    int texCount = [self childCount];
    for (int i = 0; i < texCount; i++) {
        BXTexture2DSpec* aTexSpec = (BXTexture2DSpec*)[self childAtIndex:i];
        NSMenuItem* item = [menu addItemWithTitle:[aTexSpec textureDescription] action:NULL keyEquivalent:@""];
        [item setTag:[aTexSpec resourceID]];
    }
    
    return menu;
}

- (void)readTexture2DInfosData:(NSData*)data document:(BXDocument*)document
{
    NSArray* infos = [NSPropertyListSerialization propertyListFromData:data
                                                      mutabilityOption:NSPropertyListImmutable
                                                                format:NULL
                                                      errorDescription:nil];
    int infoCount = [infos count];
    for (int i = 0; i < infoCount; i++) {
        NSDictionary* anInfo = [infos objectAtIndex:i];
        [document addTexture2DWithInfo:anInfo];
    }
}

@end


@implementation BXResourceGroup (Chara2DSerialization)

- (void)readChara2DInfosData:(NSData*)data document:(BXDocument*)document
{
    NSArray* infos = [NSPropertyListSerialization propertyListFromData:data
                                                      mutabilityOption:NSPropertyListImmutable
                                                                format:NULL
                                                      errorDescription:nil];

    int infoCount = [infos count];
    for (int i = 0; i < infoCount; i++) {
        NSDictionary* anInfo = [infos objectAtIndex:i];
        [document addChara2DWithInfo:anInfo];
    }
}

@end


@implementation BXResourceGroup (Particle2DSerialization)

- (void)readParticle2DInfosData:(NSData*)data document:(BXDocument*)document
{
    NSArray* infos = [NSPropertyListSerialization propertyListFromData:data
                                                      mutabilityOption:NSPropertyListImmutable
                                                                format:NULL
                                                      errorDescription:nil];
    
    int infoCount = [infos count];
    for (int i = 0; i < infoCount; i++) {
        NSDictionary* anInfo = [infos objectAtIndex:i];
        [document addParticle2DWithInfo:anInfo];
    }
}

@end


@implementation BXResourceGroup (Export)

- (void)exportToFileHandle:(NSFileHandle*)fileHandle
{
    for (int i = 0; i < [self childCount]; i++) {
        BXResourceElement* anElem = [self childAtIndex:i];
        [anElem exportToFileHandle:fileHandle];
    }
}

@end


