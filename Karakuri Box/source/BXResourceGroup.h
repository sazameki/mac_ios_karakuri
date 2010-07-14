//
//  BXResourceGroup.h
//  Karakuri Box
//
//  Created by numata on 10/02/27.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXResourceElement.h"


@class BXDocument;


@interface BXResourceGroup : BXResourceElement {
}

- (NSData*)groupData;
- (void)exportIDsToString:(NSMutableString*)str;

@end


@interface BXResourceGroup (Chara2DSerialization)

- (void)readChara2DInfosData:(NSData*)data document:(BXDocument*)document;

@end


@interface BXResourceGroup (Particle2DSerialization)

- (void)readParticle2DInfosData:(NSData*)data document:(BXDocument*)document;

@end


