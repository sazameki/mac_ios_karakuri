/*
 *  KRMusic.h
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/23.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>


class KRMusic : public KRObject {
    
private:
    std::string mFileName;
    void        *mImpl;
    bool        mDoLoop;
    
public:
    KRMusic(const std::string& filename, bool loop=true);
    ~KRMusic();
    
public:
    void    prepareToPlay() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    play();
    void    pause();
    void    stop();

    bool    isPlaying() const;
    float   getVolume() const;
    void    setVolume(float value);

    
#pragma mark -
#pragma mark Debug Support

public:
    std::string to_s() const;

};

