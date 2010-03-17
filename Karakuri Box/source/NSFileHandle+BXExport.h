//
//  NSFileHandle+BXExport.h
//  Karakuri Box
//
//  Created by numata on 10/03/17.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSFileHandle (BXExport)

- (void)writeBuffer:(const void*)buffer length:(unsigned)length;
- (void)writeUnsignedIntValue:(unsigned)value;

@end

