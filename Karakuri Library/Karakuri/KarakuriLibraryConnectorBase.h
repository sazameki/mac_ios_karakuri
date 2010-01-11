//
//  KarakuriLibraryConnectorBase.h
//  Karakuri Prototype
//
//  Created by numata on 09/07/18.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Karakuri/KRGame.h>


@interface KarakuriLibraryConnectorBase : NSObject {
}

- (KRGame *)createGameInstance;

@end
