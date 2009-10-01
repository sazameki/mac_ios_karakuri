/*!
    @file   KRSwitch.h
    @author numata
    @date   09/08/28
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/KRControl.h>
#include <Karakuri/KRTexture2D.h>


/*!
    @class KRSwitch
    @group Game Controls
    ON/OFF の2つの状態を切り替えるスイッチ入力を提供するためのクラスです。
 */
class KRSwitch : public KRControl {
    
protected:
    bool    mIsOn;

    std::string     mBackTextureName;
    KRTexture2D     *mBackTexture;

    std::string     mThumbTextureName;
    KRTexture2D     *mThumbTexture;

    double          mTextureEdgeSize;
    double          mTextureThumbX;
    
public:
    /*!
        @task コンストラクタ
     */
    
    /*!
        @method KRSwitch
        位置と大きさを指定して、このスイッチを生成します。
     */
	KRSwitch(const KRRect2D& frame);
	virtual ~KRSwitch();
    
public:
    virtual bool    update(KRInput *input); KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    virtual void    draw(KRGraphics *g);    KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY

public:
    /*!
        @task 状態の設定
     */
    
    /*!
        @method isOn
        スイッチが ON 状態かどうかを取得します。
     */
    bool    isOn() const;
    
    /*!
        @method setOn
        @abstract スイッチを ON 状態 (true) あるいは OFF 状態 (false) にします。
        なお、この関数で状態が変更された場合には、KRWorld クラスの switchStateChanged() 関数は呼ばれません。
     */
    void    setOn(bool flag);
    
    /*!
        @task 見た目の設定
     */
    
    /*!
        @method setTextureNames
        スイッチの背景とつまみに使用するテクスチャの名前を設定します。
     */
    void    setTextureNames(const std::string& backName, double edgeSize, const std::string& thumbName, double thumbX);

};

