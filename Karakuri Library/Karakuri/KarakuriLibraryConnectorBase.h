//
//  KarakuriLibraryConnectorBase.h
//  Karakuri Prototype
//
//  Created by numata on 09/07/18.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Karakuri/KRGameManager.h>


@interface KarakuriLibraryConnectorBase : NSObject {
}

- (KRGameManager*)createGameInstance;

@end
