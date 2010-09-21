//
//  BXTexture2DAtlasListView.h
//  Karakuri Box
//
//  Created by numata on 10/09/22.
//  Copyright 2010 Satoshi Numata. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class BXDocument;


@interface BXTexture2DAtlasListView : NSOutlineView {
    IBOutlet BXDocument*    oDocument;
}

@end

