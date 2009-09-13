/*
 *  KRGraphics.h
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/18.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>

#include <Karakuri/KRColor.h>


/* cf. http://d.hatena.ne.jp/keim_at_Si/searchdiary?word=*%5BOpenGL%5D */

typedef enum {
    KRBlendModeAlpha,
    KRBlendModeAddition,
    KRBlendModeMultiplication,
    KRBlendModeInversion,
    KRBlendModeScreen,
    KRBlendModeXOR,
    KRBlendModeCopy
} KRBlendMode;


/*!
    @class KRGraphics
    @group  Game Foundation
 */
class KRGraphics : public KRObject {
private:
    KRBlendMode     mBlendMode;
    
public:
    KRGraphics();

public:
    void    clear(const KRColor& color) const;
    
    /*!
        @method     getBlendMode
        @abstract   現在のブレンドモードを取得します。
     */
    KRBlendMode     getBlendMode() const;
    void            setBlendMode(KRBlendMode mode);
    
public:
    void    setupDefaultSetting();

private:
    void    reflectBlendMode();

    
#pragma mark -
#pragma mark Debug Support

public:
    std::string to_s() const;

};

extern KRGraphics *KRGraphicsInst;

