/*!
    @file   KarakuriLibraryConnector.mm
 */

#import <Karakuri/KarakuriLibraryConnector.h>
#import "GameMain.h"


@implementation KarakuriLibraryConnector

- (KRGame *)createGameInstance { return new GameMain(); }

@end

