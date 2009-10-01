//
//  KarakuriLibraryConnector.m
//  Karakuri Prototype
//
//  Created by numata on 09/07/18.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import <Karakuri/KarakuriLibraryConnector.h>
#import "GameMain.h"


@implementation KarakuriLibraryConnector

- (KRGame *)createGameInstance { return new GameMain(); }

@end

