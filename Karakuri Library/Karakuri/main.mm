//
//  main.mm
//  Karakuri Prototype
//
//  Created by numata on 09/07/17.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "KarakuriLibrary.h"

#import "KRGameController.h"

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
#import "KRBundle.h"
#endif


int main(int argc, char* argv[])
{
    NSAutoreleasePool* pool = [NSAutoreleasePool new];

    int ret = 0;

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    [[KRBundle class] poseAsClass:[NSBundle class]];

    KRGameController* controller = [KRGameController new];
    ret = NSApplicationMain(argc, (const char**)argv);
#endif

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    ret = UIApplicationMain(argc, (char**)argv, nil, @"KRGameController");
#endif
    
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    [controller release];
#endif
    
    [pool release];
    
    return ret;
}






