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
#include <Karakuri/KRWorld.h>


const double _gKRControlDisabledAlpha   = 0.1;


/*!
    @class KRControl
    @group  Game Controls
    ボタンやスライダなど、ユーザから入力を受け付けるためのすべてのコントロールの基本クラスです。
 */
class KRControl : public KRObject {
    
protected:
    KRWorld*    mWorld;

    bool        mIsEnabled;
    bool        mIsHidden;
    bool        mIsSelected;
    KRRect2D    mFrame;
    int         mGroupID;

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
        @task 基本の操作
     */

    /*!
        @method contains
        与えられた座標がこのコントロールの領域内に含まれているかどうかをリターンします。
     */
    bool    contains(const KRVector2D& pos);
    
    /*!
        @method getFrame
        このコントロールのフレーム枠をリターンします。
     */
    KRRect2D    getFrame() const;
    
    /*!
        @method isEnabled
        このコントロールが使用可能かどうかをリターンします。
     */
    bool    isEnabled() const;
    
    /*!
        @method isHidden
        このコントロールが不可視状態かどうかをリターンします。
     */
    bool    isHidden() const;
    
    /*!
        @method setEnabled
        このコントロールを使用可能または使用不可能な状態にします。
     */
    void    setEnabled(bool flag);
    
    /*!
        @method setFrame
        このコントロールのフレーム枠を設定します。
        実際のコントロールの種類によっては、縦方向あるいは横方向のサイズ変更に対応できない場合があることに注意してください。
     */
    virtual void    setFrame(const KRRect2D& rect);

    /*!
        @method setFrameOrigin
        このコントロールのフレーム枠の開始位置を設定します。
     */
    virtual void    setFrameOrigin(const KRVector2D& pos);

    /*!
        @method setFrameSize
        このコントロールのフレーム枠のサイズを設定します。
        実際のコントロールの種類によっては、縦方向あるいは横方向のサイズ変更に対応できない場合があることに注意してください。
     */
    virtual void    setFrameSize(const KRVector2D& size);

    /*!
        @method setHidden
        このコントロールを不可視状態または可視状態に設定します。
     */
    void    setHidden(bool flag);
    
    int     getGroupID() const;                     KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    void    setGroupID(int groupID);                KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    virtual bool    _isUpdatableControl() const;    KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    
public:
    void            setWorld(KRWorld* aWorld);      KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    virtual bool    update(KRInput* input) = 0;     KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    virtual void    draw(KRGraphics* g) = 0;        KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    
};

