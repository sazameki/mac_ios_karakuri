/*
 *  KRSound.cpp
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/23.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#include <Karakuri/KRSound.h>

#import <Karakuri/KarakuriSound.h>


static KRVector3D   sListenerPos            = KRVector3DZero;


int _KRSound::getResourceSize(const std::string& filename)
{
    int ret = 0;

    NSString* filenameStr = [NSString stringWithCString:filename.c_str() encoding:NSUTF8StringEncoding];
    NSString* filepath = [[NSBundle mainBundle] pathForResource:filenameStr ofType:nil];
    
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    if (filepath) {
        NSDictionary* fileInfo = [[NSFileManager defaultManager] fileAttributesAtPath:filepath traverseLink:NO];
        ret += (int)[fileInfo fileSize];
    }
#endif
    
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    if (filepath) {
        NSDictionary* fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:filepath
                                                                                  error:nil];
        ret += (int)[fileInfo fileSize];
    }
#endif

    return ret;
}

double _KRSound::getListenerHorizontalOrientation()
{
    return [_KarakuriSound listenerHorizontalOrientation];
}

void _KRSound::setListenerHorizontalOrientation(double radAngle)
{
    [_KarakuriSound setListenerHorizontalOrientation:radAngle];
}

KRVector3D _KRSound::getListenerPos()
{
    return sListenerPos;
}

void _KRSound::setListenerPos(double x, double y, double z)
{
    sListenerPos.x = x;
    sListenerPos.y = y;
    sListenerPos.z = z;
    [_KarakuriSound setListenerX:x y:y z:z];
}

void _KRSound::setListenerPos(const KRVector3D &vec3)
{
    setListenerPos(vec3.x, vec3.y, vec3.z);
}

_KRSound::_KRSound(const std::string& filename, bool doLoop)
{
    mFileName = filename;
    mDoLoop = doLoop;
 
    mSourcePos = KRVector3DZero;
    
    // Get the path
    NSString* filenameStr = [NSString stringWithCString:filename.c_str() encoding:NSUTF8StringEncoding];
    mSoundImpl = [[_KarakuriSound alloc] initWithName:filenameStr doLoop:(doLoop? YES: NO)];    
}

_KRSound::~_KRSound()
{
    [(_KarakuriSound*)mSoundImpl release];
}

bool _KRSound::isPlaying() const
{
    return [(_KarakuriSound*)mSoundImpl isPlaying];
}

void _KRSound::play()
{
    [(_KarakuriSound*)mSoundImpl play];
}

void _KRSound::stop()
{
    [(_KarakuriSound*)mSoundImpl stop];
}

KRVector3D _KRSound::getSourcePos() const
{
    return mSourcePos;
}

void _KRSound::setSourcePos(const KRVector3D &vec3)
{
    mSourcePos = vec3;
    [(_KarakuriSound*)mSoundImpl setSourceX:vec3.x y:vec3.y z:vec3.z];
}

double _KRSound::getPitch() const
{
    return (double)[(_KarakuriSound*)mSoundImpl pitch];
}

void _KRSound::setPitch(double value)
{
    [(_KarakuriSound*)mSoundImpl setPitch:(float)value];
}

double _KRSound::getVolume() const
{
    return (double)[(_KarakuriSound*)mSoundImpl volume];
}

void _KRSound::setVolume(double value)
{
    [(_KarakuriSound*)mSoundImpl setVolume:(float)value];
}

std::string _KRSound::to_s() const
{
    return "<sound>(file=\"" + mFileName + "\", loop=" + (mDoLoop? "true": "false") + ")";
}



