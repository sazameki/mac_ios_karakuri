//
//  NSString+UUID.m
//  Shiki
//
//  Created by numata on 08/09/03.
//  Copyright 2008 Satoshi Numata. All rights reserved.
//

#import "NSString+UUID.h"


@implementation NSString (UUID)

+ (NSString *)generateUUIDString
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return [(NSString *)uuidStr autorelease];
}

@end

