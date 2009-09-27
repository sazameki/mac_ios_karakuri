/*
 *  KRMusic.mm
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/23.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#include "KRMusic.h"

#import "KarakuriGame.h"
#import "KarakuriSound.h"

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
#import <AVFoundation/AVFoundation.h>
#endif


KRMusic::KRMusic(const std::string& filename, bool loop)
{
    mFileName = filename;
    mDoLoop = loop;
    
    mImpl = nil;

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    if (gKRGameInst->getAudioMixType() == KRAudioMixTypeAmbientSolo) {
        NSString *filenameStr = [NSString stringWithCString:filename.c_str() encoding:NSUTF8StringEncoding];
        mImpl = [[KarakuriSound alloc] initWithName:filenameStr doLoop:loop];
        if (!mImpl) {
            const char *errorFormat = "Failed to load \"%s\". Please confirm that the audio file exists.";
            if (gKRLanguage == KRLanguageJapanese) {
                errorFormat = "\"%s\" の読み込みに失敗しました。オーディオファイルが存在することを確認してください。";
            }
            throw KRRuntimeError(errorFormat, filename.c_str());
        }
    }
#endif
    
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    if (gKRGameInst->getAudioMixType() == KRAudioMixTypeAmbientSolo) {
        NSString *filenameStr = [NSString stringWithCString:filename.c_str() encoding:NSUTF8StringEncoding];
        NSString *filepath = [[NSBundle mainBundle] pathForResource:filenameStr ofType:nil];
        NSURL *fileURL = [NSURL fileURLWithPath:filepath];
        
        NSError *error = nil;
        mImpl = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
        if (error) {
            const char *errorFormat = "Failed to load \"%s\". Please confirm that the audio file exists.";
            if (gKRLanguage == KRLanguageJapanese) {
                errorFormat = "\"%s\" の読み込みに失敗しました。オーディオファイルが存在することを確認してください。";
            }
            throw KRRuntimeError(errorFormat, filename.c_str());
        }
        ((AVAudioPlayer *)mImpl).numberOfLoops = (loop? -1: 0);
    }
#endif
    
    prepareToPlay();
}


KRMusic::~KRMusic()
{
    stop();

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        [(NSSound *)mImpl release];
    }
#endif
    
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        [(AVAudioPlayer *)mImpl release];
    }
#endif
}

void KRMusic::prepareToPlay()
{
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        [(AVAudioPlayer *)mImpl prepareToPlay];
    }
#endif    
}

bool KRMusic::isPlaying() const
{
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        return [(NSSound *)mImpl isPlaying];
    }
    return false;
#endif

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        return [(AVAudioPlayer *)mImpl isPlaying];
    }
    return false;
#endif
}

void KRMusic::play()
{
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        [(NSSound *)mImpl play];
    }
#endif

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        [(AVAudioPlayer *)mImpl play];
    }
#endif
}

void KRMusic::pause()
{
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        [(NSSound *)mImpl pause];
    }
#endif
    
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        [(AVAudioPlayer *)mImpl pause];
    }
#endif
}

void KRMusic::stop()
{
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        [(NSSound *)mImpl stop];
    }
#endif
    
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        [(AVAudioPlayer *)mImpl stop];
    }
#endif
}

float KRMusic::getVolume() const
{
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        return [(KarakuriSound *)mImpl volume];
        //return [(NSSound *)mImpl volume];
    }
#endif
    
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        return [(AVAudioPlayer *)mImpl volume];
    }
#endif

    return 0.0f;
}

void KRMusic::setVolume(float value)
{
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        [(KarakuriSound *)mImpl setVolume:value];
        //[(NSSound *)mImpl setVolume:value];
    }
#endif

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    if (mImpl) {
        [(AVAudioPlayer *)mImpl setVolume:value];
    }
#endif
}

std::string KRMusic::to_s() const
{
    return "<music>(file=\"" + mFileName + "\", loop=" + (mDoLoop? "true": "false") + ")";
}

