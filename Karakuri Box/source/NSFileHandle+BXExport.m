//
//  NSFileHandle+BXExport.m
//  Karakuri Box
//
//  Created by numata on 10/03/17.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "NSFileHandle+BXExport.h"


@implementation NSFileHandle (BXExport)

- (void)writeBuffer:(const void*)buffer length:(unsigned)length
{
    NSData* data = [[NSData alloc] initWithBytesNoCopy:(void*)buffer length:length freeWhenDone:NO];
    [self writeData:data];
    [data release];
}

- (void)writeUnsignedIntValue:(unsigned)value
{
    unsigned char buffer[4];
    
    buffer[0] = (unsigned char)((value >> 24) & 0xff);
    buffer[1] = (unsigned char)((value >> 16) & 0xff);
    buffer[2] = (unsigned char)((value >> 8) & 0xff);
    buffer[3] = (unsigned char)(value & 0xff);

    [self writeBuffer:buffer length:4];
}

@end


