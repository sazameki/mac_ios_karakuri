//
//  NSDictionary+LoadSave.mm
//  Karakuri Box
//
//  Created by numata on 10/03/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "NSDictionary+LoadSave.h"


@implementation NSDictionary (Loading)

- (BOOL)boolValueForName:(NSString*)name currentValue:(BOOL)value
{
    NSNumber* numberObj = [self objectForKey:name];
    if (numberObj) {
        value = [numberObj boolValue];
    }
    return value;
}

- (int)intValueForName:(NSString*)name currentValue:(int)value
{
    NSNumber* numberObj = [self objectForKey:name];
    if (numberObj) {
        value = [numberObj intValue];
    }
    return value;
}

- (double)doubleValueForName:(NSString*)name currentValue:(double)value
{
    NSNumber* numberObj = [self objectForKey:name];
    if (numberObj) {
        value = [numberObj doubleValue];
    }
    return value;
}

- (NSString*)stringValueForName:(NSString*)name currentValue:(NSString*)value
{
    NSString* str = [self objectForKey:name];
    if (str) {
        value = str;
    }
    return value;
}

@end


@implementation NSMutableDictionary (Saving)

- (void)setBoolValue:(BOOL)value forName:(NSString*)name
{
    [self setObject:[NSNumber numberWithBool:value] forKey:name];
}

- (void)setDoubleValue:(double)value forName:(NSString*)name
{
    [self setObject:[NSNumber numberWithDouble:value] forKey:name];
}

- (void)setIntValue:(int)value forName:(NSString*)name
{
    [self setObject:[NSNumber numberWithInt:value] forKey:name];
}

- (void)setStringValue:(NSString*)value forName:(NSString*)name
{
    [self setObject:value forKey:name];
}

@end


