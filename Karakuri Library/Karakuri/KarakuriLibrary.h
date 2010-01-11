/*
 *  KarakuriLibrary.h
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/18.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 *  This header file is intended to be included from Karakuri Framework internals.
 *
 */

#pragma once

#include <Karakuri/KarakuriDefines.h>

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

#import <OpenGL/OpenGL.h>
#endif
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#endif

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
#ifdef __OBJC__
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import <OpenGLES/EAGL.h>
#endif
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#endif

#include <Karakuri/KarakuriGlobals.h>

#include <Karakuri/KarakuriTypes.h>
#include <Karakuri/KarakuriException.h>
#include <Karakuri/KarakuriString.h>
#include <Karakuri/KarakuriFunctions.h>

#include <algorithm>
#include <cmath>
#include <cstdio>
#include <iostream>
#include <list>
#include <map>
#include <set>
#include <string>
#include <vector>

