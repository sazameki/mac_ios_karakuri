/*
 *  KRFont_old.h
 *  Karakuri Library
 *
 *  Created by numata on 10/09/20.
 *  Copyright 2010 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>

#include <Karakuri/KRTexture2D.h>
#include <Karakuri/KRColor.h>
#include <AvailabilityMacros.h>


/*!
    @class KRFont
    @group  Game Graphics
    @deprecated
    @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRLabel クラスのコントロールを利用してください。</strong>
    <p>文字列のテクスチャを生成するためのクラスです。</p>
    <p>利用可能なフォント名については、<a href="../../../../guide/index.html">開発ガイド</a>の「<a href="../../../../guide/font_list.html">フォント名の一覧</a>」を参照してください。
    <p>文字列のテクスチャは、できるだけワールドの becameActive() 関数内で生成してください。ゲーム実行中の生成は強く推奨しません。</p>
 */
class KRFont : public KRObject {
    
    void        *mFontObj;
    std::string mFontName;

public:
    /*!
        @task コンストラクタ
     */

    /*!
        @method KRFont
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRLabel クラスのコントロールを利用してください。</strong>
        <p>フォント名とサイズを指定して、このクラスのインスタンスを生成します。</p>
     */
	KRFont(const std::string& fontName, double size) DEPRECATED_ATTRIBUTE;

	virtual ~KRFont() DEPRECATED_ATTRIBUTE;
    
public:
    /*!
        @task 基本の関数
     */
    
    /*!
        @method createStringTexture
        @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRLabel クラスのコントロールを利用してください。</strong>
        <p>指定された文字列のテクスチャを生成します。</p>
     */
    KRTexture2D*    createStringTexture(const std::string& str) DEPRECATED_ATTRIBUTE;

public:
    void*           getFontObject() const KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

public:
    virtual std::string to_s() const;

};



