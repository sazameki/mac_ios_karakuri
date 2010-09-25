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


/*!
    @enum KRBlendMode
    @group  Game Graphics
    @constant KRBlendModeAlpha          アルファ合成（glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)）
    @constant KRBlendModeAddition       加算合成（glBlendFunc(GL_SRC_ALPHA, GL_ONE)）
    @constant KRBlendModeMultiplication 乗算合成（glBlendFunc(GL_ZERO, GL_SRC_COLOR)）
    @constant KRBlendModeInversion      反転合成（glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ZERO)）
    @constant KRBlendModeScreen         スクリーン合成（glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ONE)）
    @constant KRBlendModeXOR            XOR合成（glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ONE_MINUS_SRC_COLOR)）
    @constant KRBlendModeCopy           コピー合成（単純な上書き）（glBlendFunc(GL_ONE, GL_ZERO)）
    @abstract ブレンドモードを示す列挙型です。
    <p><a href="../../../guide/index.html">開発ガイド</a>の「<a href="../../../guide/blend_mode.html">ブレンドモードについて</a>」も参照してください。</p>
 */
typedef enum {
    KRBlendModeAlpha            = 0,
    KRBlendModeAddition         = 1,
    KRBlendModeMultiplication   = 2,
    KRBlendModeInversion        = 3,
    KRBlendModeScreen           = 4,
    KRBlendModeXOR              = 5,
    KRBlendModeCopy             = 6,
} KRBlendMode;


/*!
    @class KRGraphics
    @group  Game Graphics
    @abstract 画面描画の基本設定の管理を行います。
 */
class KRGraphics : public KRObject {
private:
    KRBlendMode     mBlendMode;
    
public:
    KRGraphics();

public:
    /*!
        @task 基本の関数
     */
    
    /*!
        @method clear
        @abstract 指定された色で背景をクリアします。
     */
    void    clear(const KRColor& color) const;
    
    /*!
        @method     getBlendMode
        @abstract   現在のブレンドモードを取得します。
        <p><a href="../../../../guide/index.html">開発ガイド</a>の「<a href="../../../../guide/blend_mode.html">ブレンドモードについて</a>」も参照してください。</p>
     */
    KRBlendMode     getBlendMode() const;
    
    /*!
        @method     setBlendMode
        @abstract   ブレンドモードを設定します。
        <p>デフォルトのブレンドモードは KRBlendAlpha です。毎フレームの描画開始前に、このデフォルトのブレンドモードが設定されます。</p>
        <p><a href="../../../../guide/index.html">開発ガイド</a>の「<a href="../../../../guide/blend_mode.html">ブレンドモードについて</a>」も参照してください。</p>
     */
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
    @var gKRGraphicsInst
    @group Game Graphics
    @abstract グラフィック設定のインスタンスを指す変数です。
    この変数が指し示すオブジェクトは、ゲーム実行の最初から最後まで絶対に変わりません。
 */
extern KRGraphics*  gKRGraphicsInst;

