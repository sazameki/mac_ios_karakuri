/*!
    @file   KRButton.h
    @author numata
    @date   09/08/28
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/KRControl.h>
#include <Karakuri/KRLabel.h>


/*!
    @class KRButton
    @group Game Controls
    プッシュボタンを表すためのクラスです。
 */
class KRButton : public KRControl {

protected:
    KRLabel     *mLabel;

    KRColor     mTitleColorNormal;
    KRColor     mTitleColorHighlighted;
    
    std::string mTextureNameNormal;
    KRTexture2D *mTextureNormal;
    
    std::string mTextureNameHighlighted;
    KRTexture2D *mTextureHighlighted;
    
    double      mTextureEdgeSize;

public:
    /*!
        @task コンストラクタ
     */
    
    /*!
        @method KRButton
        位置と大きさを指定して、このボタンを生成します。
     */
	KRButton(const KRRect2D& frame);
	virtual ~KRButton();

public:
    virtual bool    update(KRInput *input); KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    virtual void    draw(KRGraphics *g);    KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    
public:
    /*!
        @task 状態の設定
     */

    /*!
        @method getTitle
        このボタンに設定されているタイトルを取得します。
     */
    std::string getTitle() const;
    
    /*!
        @method setTitle
        このボタンのタイトルを設定します。
     */
    void        setTitle(const std::string& text);
    
    /*!
        @task 見た目の設定
     */
    
    /*!
        @method setTextureNames
        @abstract ボタンの描画に使用するテクスチャの名前を指定します（通常時とハイライト（押されている）時）。
        ボタンの画像は、横方向に可変サイズになるようにデザインされている必要があります。左端と右端のサイズを textureEdgeSize 引数で指定してください。
     */
    void        setTextureNames(const std::string& normalName, const std::string& highlightedName, double textureEdgeSize);
    
    /*!
        @method setTitleColors
        ボタンのタイトルの表示色を設定します（通常時とハイライト（押されている）時）。
     */
    void        setTitleColors(const KRColor& normalColor, const KRColor& hilightedColor);
    
};

