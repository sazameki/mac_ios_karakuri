//
//  NSDictionary+LoadSave.h
//  Karakuri Box
//
//  Created by numata on 10/03/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KRColor.h"


@interface NSDictionary (Loading)

- (BOOL)boolValueForName:(NSString*)name currentValue:(BOOL)value;
- (double)doubleValueForName:(NSString*)name currentValue:(double)value;
- (int)intValueForName:(NSString*)name currentValue:(int)value;
- (NSString*)stringValueForName:(NSString*)name currentValue:(NSString*)value;

@end


@interface NSMutableDictionary (Saving)

- (void)setBoolValue:(BOOL)value forName:(NSString*)name;
- (void)setDoubleValue:(double)value forName:(NSString*)name;
- (void)setIntValue:(int)value forName:(NSString*)name;
- (void)setStringValue:(NSString*)value forName:(NSString*)name;

@end


