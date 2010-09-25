/*
 *  KRMusic.mm
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/23.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#include "KRMusic.h"

#import "KRGameManager.h"
#import "KarakuriSound.h"

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
#import <AVFoundation/AVFoundation.h>
#endif


#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
static BOOL sHasOSVersionChecked = NO;
static BOOL sCanUseNSSound = NO;
#endif


int KRMusic::getResourceSize(const std::string& filename)
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

KRMusic::KRMusic(const std::string& filename, bool loop)
{
    mFileName = filename;
    mDoLoop = loop;
    
    mIsPausing = false;
    
    mImpl = nil;
    
    mBGMID = -1;

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    if (!sHasOSVersionChecked) {
        if ([NSSound instancesRespondToSelector:@selector(setVolume:)]) {
            sCanUseNSSound = YES;
        }
        sHasOSVersionChecked = YES;
    }
    
    NSString* filenameStr = [NSString stringWithCString:filename.c_str() encoding:NSUTF8StringEncoding];
    if (sCanUseNSSound) {
        NSString* filepath = [[NSBundle mainBundle] pathForResource:filenameStr ofType:nil];
        if (filepath) {
            mImpl = [[NSSound alloc] initWithContentsOfFile:filepath byReference:YES];
        }
    } else {
        mImpl = [[_KarakuriSound alloc] initWithName:filenameStr doLoop:loop];
    }
    if (!mImpl) {
        const char* errorFormat = "Failed to load \"%s\". Please confirm that the audio file exists.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "\"%s\" の読み込みに失敗しました。オーディオファイルが存在することを確認してください。";
        }
        throw KRRuntimeError(errorFormat, filename.c_str());
    }
    if (sCanUseNSSound && loop) {
        NSMethodSignature* sig = [(NSSound*)mImpl methodSignatureForSelector:@selector(setLoops:)];
        NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
        [invocation setSelector:@selector(setLoops:)];
        [invocation setTarget:(NSSound*)mImpl];
        BOOL boolValue = YES;
        [invocation setArgument:&boolValue atIndex:2];
        [invocation invokeWithTarget:(NSSound*)mImpl];
    }
#endif
    
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    NSString* filenameStr = [NSString stringWithCString:filename.c_str() encoding:NSUTF8StringEncoding];
    NSString* filepath = [[NSBundle mainBundle] pathForResource:filenameStr ofType:nil];
    NSURL* fileURL = nil;
    
    if (filepath) {
        fileURL = [NSURL fileURLWithPath:filepath];
    }
    
    NSError* error = nil;
    mImpl = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
    if (error) {
        const char* errorFormat = "Failed to load \"%s\". Please confirm that the audio file exists.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "\"%s\" の読み込みに失敗しました。オーディオファイルが存在することを確認してください。";
        }
        throw KRRuntimeError(errorFormat, filename.c_str());
    }
    ((AVAudioPlayer*)mImpl).numberOfLoops = (loop? -1: 0);
#endif
    
    prepareToPlay();
}


KRMusic::~KRMusic()
{
    stop();

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        if (sCanUseNSSound) {
            [(NSSound*)mImpl release];
        } else {
            [(_KarakuriSound*)mImpl release];
        }
    }
#endif
    
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        [(AVAudioPlayer*)mImpl release];
    }
#endif
}

void KRMusic::prepareToPlay()
{
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        [(AVAudioPlayer*)mImpl prepareToPlay];
    }
#endif    
}

bool KRMusic::isPlaying() const
{
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        if (sCanUseNSSound) {
            return [(NSSound*)mImpl isPlaying];
        } else {
            return [(_KarakuriSound*)mImpl isPlaying];
        }
    }
    return false;
#endif

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        return [(AVAudioPlayer*)mImpl isPlaying];
    }
    return false;
#endif
}

void KRMusic::play()
{
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        if (sCanUseNSSound) {
            if (mIsPausing) {
                [(NSSound*)mImpl resume];
            } else {
                [(NSSound*)mImpl play];
            }
        } else {
            [(_KarakuriSound*)mImpl play];
        }
    }
#endif

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        [(AVAudioPlayer*)mImpl play];
    }
#endif

    mIsPausing = false;
}

void KRMusic::pause()
{
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        if (sCanUseNSSound) {
            [(NSSound*)mImpl pause];
        } else {
            [(_KarakuriSound*)mImpl pause];
        }
    }
#endif
    
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        [(AVAudioPlayer*)mImpl pause];
    }
#endif
    
    mIsPausing = true;
}

void KRMusic::stop()
{
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        if (sCanUseNSSound) {
            [(NSSound*)mImpl stop];
            [(NSSound*)mImpl setCurrentTime:0.0];
        } else {
            [(_KarakuriSound*)mImpl stop];
        }
    }
#endif
    
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        [(AVAudioPlayer*)mImpl stop];
        ((AVAudioPlayer*)mImpl).currentTime = 0.0;
    }
#endif
    
    mIsPausing = false;
}

double KRMusic::getVolume() const
{
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        if (sCanUseNSSound) {
            NSMethodSignature* sig = [(NSSound*)mImpl methodSignatureForSelector:@selector(volume)];
            NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
            [invocation setSelector:@selector(volume)];
            [invocation setTarget:(NSSound*)mImpl];
            [invocation invokeWithTarget:(NSSound*)mImpl];
            float value;
            [invocation getReturnValue:&value];
            return (double)value;
        } else {
            return (double)[(_KarakuriSound*)mImpl volume];
        }
    }
#endif
    
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        return (double)[(AVAudioPlayer*)mImpl volume];
    }
#endif

    return 0.0;
}

void KRMusic::setVolume(double value)
{
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        if (sCanUseNSSound) {
            NSMethodSignature* sig = [(NSSound*)mImpl methodSignatureForSelector:@selector(setVolume:)];
            NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
            [invocation setSelector:@selector(setVolume:)];
            [invocation setTarget:(NSSound*)mImpl];
            float floatValue = (float)value;
            [invocation setArgument:&floatValue atIndex:2];
            [invocation invokeWithTarget:(NSSound*)mImpl];
        } else {
            [(_KarakuriSound*)mImpl setVolume:(float)value];
        }
    }
#endif

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        [(AVAudioPlayer*)mImpl setVolume:(float)value];
    }
#endif
}

int KRMusic::_getBGMID() const
{
    return mBGMID;
}

void KRMusic::_setBGMID(int bgmID)
{
    mBGMID = bgmID;
}

std::string KRMusic::to_s() const
{
    return "<music>(file=\"" + mFileName + "\", loop=" + (mDoLoop? "true": "false") + ")";
}

