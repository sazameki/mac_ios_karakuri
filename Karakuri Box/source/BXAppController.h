//
//  BXAppController.h
//  Karakuri Box
//
//  Created by numata on 10/03/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BXGlobals.h"


@interface BXAppController : NSObject {
    IBOutlet NSWindow*  oPrefWindow;
}

- (IBAction)createNewDocument:(id)sender;
- (IBAction)showPreferencesWindow:(id)sender;

@end

