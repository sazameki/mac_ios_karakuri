/*!
    @file   KarakuriLibraryConnector.mm
 */

#import <Karakuri/KarakuriLibraryConnector.h>
#import "GameMain.h"


@implementation KarakuriLibraryConnector

- (KarakuriGame *)createGameInstance { return new GameMain(); }

@end

