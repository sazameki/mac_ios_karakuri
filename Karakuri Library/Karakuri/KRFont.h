/*!
    @file   KRFont.h
    @author numata
    @date   09/07/30
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>

#include <Karakuri/KRTexture2D.h>
#include <Karakuri/KRColor.h>


/*!
    @-class KRFont
    @group  Game 2D Graphics
    @abstract 文字列のテクスチャを生成するためのクラスです。
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
        @abstract フォント名とサイズを指定して、このクラスのインスタンスを生成します。
     */
	KRFont(const std::string& fontName, double size);

	virtual ~KRFont();
    
public:
    /*!
        @task 基本の関数
     */
    
    /*!
        @method createStringTexture
        @abstract 指定された文字列のテクスチャを生成します。
     */
    _KRTexture2D *createStringTexture(const std::string& str);

public:
    void        *getFontObject() const KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

public:
    virtual std::string to_s() const;

};



