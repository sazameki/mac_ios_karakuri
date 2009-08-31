//
//  KarakuriLibraryConnectorBase.mm
//  Karakuri Prototype
//
//  Created by numata on 09/07/18.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "KarakuriLibraryConnectorBase.h"

#import "KarakuriController.h"


@implementation KarakuriLibraryConnectorBase

- (void)registerClassesInNib
{
    [KarakuriController new];
}

- (KarakuriGame *)createGameInstance
{
    // Subclass should return an instance of the game 
    return nil;
}

@end

