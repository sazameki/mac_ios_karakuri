//
//  main.mm
//  Karakuri Prototype
//
//  Created by numata on 09/07/17.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "KarakuriLibrary.h"

#import "KarakuriController.h"


int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    int ret = 0;

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    KarakuriController *controller = [KarakuriController new];
    ret = NSApplicationMain(argc, (const char **)argv);
#endif

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    ret = UIApplicationMain(argc, (char **)argv, nil, @"KarakuriController");
#endif
    
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    [controller release];
#endif
    
    [pool release];
    
    return ret;
}






