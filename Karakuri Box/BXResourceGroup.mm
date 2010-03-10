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



