/*!
    @file   KRControl.h
    @author numata
    @date   09/08/28
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>
#include <Karakuri/KRGraphics.h>
#include <Karakuri/KRInput.h>
#include <Karakuri/KarakuriWorld.h>


/*!
    @class KRControl
    @group  Game Controls
    ボタンやスライダなど、ユーザから入力を受け付けるためのすべてのコントロールの基本クラスです。
 */
class KRControl : public KRObject {
    
protected:
    KarakuriWorld   *mWorld;

    bool        mEnabled;
    bool        mSelected;
    KRRect2D    mFrame;

public:
    /*!
        @task コンストラクタ
     */
    
    /*!
        @method KRControl
        位置と大きさを指定して、このコントロールを生成します。
     */
	KRControl(const KRRect2D& frame);

	virtual ~KRControl();
    
public:
    /*!
        @method contains
        与えられた座標がこのコントロールの領域内に含まれているかどうかをリターンします。
     */
    bool    contains(const KRVector2D& pos);
    
public:
    void            setWorld(KarakuriWorld *aWorld);    KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    virtual bool    update(KRInput *input) = 0;         KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    virtual void    draw(KRGraphics *g) = 0;            KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    
};

