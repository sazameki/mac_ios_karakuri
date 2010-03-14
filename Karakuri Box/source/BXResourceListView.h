//
//  BXResourceListView.h
//  Karakuri Box
//
//  Created by numata on 10/03/14.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class BXDocument;


@interface BXResourceListView : NSOutlineView {
    IBOutlet BXDocument*    oDocument;
}

@end

