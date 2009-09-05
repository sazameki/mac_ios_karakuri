//
//  KRBundle.m
//  Karakuri Library
//
//  Created by numata on 09/09/05.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "KRBundle.h"


@implementation KRBundle

+ (BOOL)loadNibNamed:(NSString *)aNibNamed owner:(id)owner
{
    if (!aNibNamed && owner == NSApp) {
        // We don't use any nib in Karakuri Framework, so don't load anything.
        // This can eliminate log output: "Could not connect the action buttonPressed: to target of class NSApplication".
        return YES;
    } else {
        return [super loadNibNamed:aNibNamed owner:owner];
    }
}

@end


