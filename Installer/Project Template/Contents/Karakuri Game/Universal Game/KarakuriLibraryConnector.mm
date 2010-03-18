/*!
    @file   KarakuriLibraryConnector.mm
 */

#import <Karakuri/KarakuriLibraryConnector.h>
#import "GameMain.h"


@implementation KarakuriLibraryConnector

- (KRGameManager*)createGameInstance { return new GameMain(); }

@end

