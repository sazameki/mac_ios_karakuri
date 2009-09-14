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

test;

/*!
    @enum KRBlendMode
    @group  Game Foundation
    @constant KRBlendModeAlpha          アルファ合成（glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)）
    @constant KRBlendModeAddition       加算合成（glBlendFunc(GL_SRC_ALPHA, GL_ONE)）
    @constant KRBlendModeMultiplication 乗算合成（glBlendFunc(GL_ZERO, GL_SRC_COLOR)）
    @constant KRBlendModeInversion      反転合成（glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ZERO)）
    @constant KRBlendModeScreen         スクリーン合成（glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ONE)）
    @constant KRBlendModeXOR            XOR合成（glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ONE_MINUS_SRC_COLOR)）
    @constant KRBlendModeCopy           コピー合成（単純な上書き）（glBlendFunc(GL_ONE, GL_ZERO)）
 
    ブレンドモードを示す列挙型です。
 */
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

/*!
    @var KRGraphicsInst
    @group Game Foundation
    @abstract グラフィック設定のインスタンスを指す変数です。
    この変数が指し示すオブジェクトは、ゲーム実行の最初から最後まで絶対に変わりません。
 */
extern KRGraphics *KRGraphicsInst;

