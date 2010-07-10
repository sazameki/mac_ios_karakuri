/*!
    @file   KRSlider.h
    @author numata
    @date   09/08/28
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/KRControl.h>
#include <Karakuri/KRTexture2D.h>


/*!
    @class KRSlider
    @group Game Controls
    横方向のスライダを表すクラスです。
 */
class KRSlider : public KRControl {

protected:
    double  mMaxValue;
    double  mMinValue;
    double  mValue;
    
    std::string     mThumbTextureName;
    _KRTexture2D     *mThumbTexture;

    std::string     mBackTextureName;
    _KRTexture2D     *mBackTexture;
    double          mBackTextureEdgeSize;

public:
	KRSlider(const KRRect2D& frame);
	virtual ~KRSlider();

public:
    virtual bool    update(KRInput *input); KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    virtual void    draw(KRGraphics *g);    KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    
public:
    /*!
        @task 状態の設定
     */
    
    /*!
        @method getMaxValue
        スライダの最大値を取得します。
     */
    double  getMaxValue() const;

    /*!
        @method getMinValue
        スライダの最小値を取得します。
     */
    double  getMinValue() const;
    
    /*!
        @method getValue
        スライダの現在の値を取得します。
     */
    double  getValue() const;

    /*!
        @method setMaxValue
        スライダの最大値を設定します。
     */
    void    setMaxValue(double value);

    /*!
        @method setMinValue
        スライダの最小値を設定します。
     */
    void    setMinValue(double value);
    
    /*!
        @method setValue
        @abstract スライダの現在の値を設定します。
        この関数による値の設定では、KRWorld クラスの sliderValueChanged() 関数は呼ばれません。
     */
    void    setValue(double value);
    
    /*!
        @task 見た目の設定
     */

    /*!
        @method setTextureNames
        スライダの背景画像とつまみ画像に使用するテクスチャの名前を設定します。
     */
    void    setTextureNames(const std::string& backName, double edgeSize, const std::string& thumbName);

};

