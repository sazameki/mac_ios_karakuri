//
//  KarakuriFunctions.mm
//  Karakuri Prototype
//
//  Created by numata on 09/07/22.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "KarakuriFunctions.h"
#import "Karakuri_Defines.h"

#include <string>

#import <Foundation/Foundation.h>


void KRSleep(double interval)
{
    [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:interval]];
}

double KRCurrentTime()
{
    return [NSDate timeIntervalSinceReferenceDate];
}

bool KRCheckOpenGLExtensionSupported(const std::string& extensionName)
{
    const char *extensions = (const char *)glGetString(GL_EXTENSIONS);
    return (strstr(extensions, extensionName.c_str()) != NULL);
}

std::string KRGetKarakuriVersion()
{
    return KARAKURI_FRAMEWORK_VERSION;
}

