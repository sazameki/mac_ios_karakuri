/*
 *  KRChara2D.h
 *  Karakuri Library
 *
 *  Created by numata on 10/07/09.
 *  Copyright 2010 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include "KRMemoryAllocator.h"
#include "KRColor.h"
#include "KRGraphics.h"


extern KRMemoryAllocator*   _gKRChara2DAllocator;


static const unsigned       KRCharaMotionChangeModeNormalMask            = 0x00;
static const unsigned       KRCharaMotionChangeModeIgnoreCancelFlagMask  = 0x01;
static const unsigned       KRCharaMotionChangeModeSkipEndMask           = 0x02;


enum _KRChara2DHitAreaType {
    _KRChara2DHitAreaTypeRect = 0,
    _KRChara2DHitAreaTypeOval = 1,
};


class _KRChara2DSpec;


struct _KRChara2DHitArea {
    int                     group;
    _KRChara2DHitAreaType   type;
    KRRect2D                rect;
    
    bool    hitTest(const KRVector2D& offset, const KRVector2D& scale, const KRVector2D& pos) const;
    bool    hitTest(const KRVector2D& offset, const KRVector2D& scale, int count, _KRChara2DHitArea* hitAreas, int targetHitType, const KRVector2D& targetOffset, const KRVector2D& targetScale) const;
};


class _KRChara2DKoma : public KRObject {
    
    int         mTextureID;
    KRRect2D    mAtlasRect;
    int         mGotoTargetIndex;
    bool        mIsCancelable;
    int         mInterval;
    
    int                 mHitAreaCount;
    _KRChara2DHitArea*  mHitAreas;
    
public:
    _KRChara2DKoma();
    ~_KRChara2DKoma();
    
    void    initForBoxChara2D(int texID, const KRRect2D& atlasRect, int interval, bool isCancelable, int gotoTargetIndex);
    
public:
    int             getGotoTargetIndex() const;
    int             getInterval() const;
    int             getTextureID() const;
    KRVector2D      getAtlasSize() const;
    
public:
    void            _importHitArea(void* hitInfo);
    KRRect2D        _getAtlasRect() const;
    int             _getHitAreaCount() const;
    _KRChara2DHitArea*  _getHitAreas() const;
    
};


class _KRChara2DMotion : public KRObject {
    _KRChara2DSpec*                 mParentChara2DSpec;
    std::vector<_KRChara2DKoma*>    mKomas;
    
    int     mMotionID;
    int     mCancelKomaNumber;
    int     mNextMotionID;
    
public:
    _KRChara2DMotion();
    
    void    initForBoxChara2D(int motionID, int cancelKomaNumber, int nextMotionID);
    
public:
    void    addKoma(_KRChara2DKoma* aKoma);
    
public:
    int                 getMotionID() const;
    int                 getKomaCount() const;
    _KRChara2DKoma*     getKoma(int komaIndex) const;
    _KRChara2DMotion*   getNextMotion() const;
    
public:
    void            _setParentChara2D(_KRChara2DSpec* chara2d);
    
};


/*
    @-class KRChara2DSpec
    @group Game Graphics
    <p><a href="../../Classes/KRAnime2D/index.html#//apple_ref/cpp/cl/KRAnime2DManager">KRAnime2DManager</a> クラスで利用するキャラクタの特徴を表すためのクラスです。</p>
    <p>このクラスのインスタンスは、直接 new することもできますが、<a href="../../Classes/KRAnime2D/index.html#//apple_ref/cpp/instm/KRAnime2D/loadCharacterSpecs/void_loadCharacterSpecs(const_std::string@_specFileName)">KRAnime2D::loadCharacterSpecs()</a> 関数を使って、キャラクタの特徴記述ファイルから読み込むこともできます。キャラクタの特徴記述ファイルの仕様については、「<a href="../../../../guide/2d_anime.html">2Dアニメーションの管理</a>」を参照してください。</p>
 */
class _KRChara2DSpec : public KRObject {
    std::map<int, _KRChara2DMotion*>    mMotionMap;
    int                                 mSpecID;
    int                                 mGroupID;
    
    int                                 mParticleTexID;
    std::string                         mSpecName;
    
public:
    /*!
        @task コンストラクタ
     */
    
    /*!
        @method KRChara2DSpec
        テクスチャ名とアトラスのサイズを指定して、新しいキャラクタの特徴を生成します。
     */
    //KRChara2DSpec(int texGroupID, const std::string& textureName, const KRVector2D& atlasSize);
    
    _KRChara2DSpec(int groupID, const std::string& specName);
    ~_KRChara2DSpec();
    
    void    initForManualChara2D();
    void    initForManualParticle2D(const std::string& fileName);
    void    initForBoxParticle2D(int texID);
    
public:
    /*!
        @task 状態の管理
     */
    
    void    addMotion(int motionID, _KRChara2DMotion* aMotion);
    
    std::string             getSpecName() const;
    _KRChara2DMotion*       getMotion(int motionID);
    int                     getParticleTextureID() const;
    int                     getSpecID() const;
    void                    setSpecID(int specID);
    bool                    isParticle();
    
};

/*!
    @class KRChara2D
    @group Game Graphics
    <p><a href="../../Classes/KRAnime2DManager/index.html#//apple_ref/cpp/cl/KRAnime2DManager">KRAnime2DManager</a> クラスで利用できるアニメーション用のキャラクタを表すためのクラスです。</p>
    <p>このクラスから継承した独自のサブクラスを作成し、addChara2D() メソッドを使って画面に表示してください。キャラクタは、デフォルト状態では動作が -1 となっており、changeMotion() メソッドを一度は呼び出さなければ画面に表示されないことに注意してください。</p>
    <p>作成したキャラクタは、ゲーム終了時に自動的に削除されますが、ゲーム実行中に削除する場合には、removeChara2D() メソッドを使って削除してください。removeChara2D() メソッドは、自動的に delete でオブジェクトの解放を行ないます。<strong>addChara2D() で追加したキャラクタは、絶対に自分で delete しないでください。</strong></p>
 */
class KRChara2D : public KRObject {
    
    KR_DECLARE_USE_ALLOCATOR(_gKRChara2DAllocator)
    
public:
    bool                _mIsHidden;
    
private:
    _KRChara2DSpec*     _mCharaSpec;
    int                 _mClassType;

    int                 _mCurrentMotionID;
    int                 _mCurrentKomaIndex;
    
    int                 _mImageInterval;
    int                 _mZOrder;
    int                 _mRepeatCount;
    bool                _mIsMotionFinished;
    bool                _mIsMotionPaused;
    bool                _mIsTemporal;
    bool                _mIsInList;
    
    KRVector2D          _mScale;
    KRBlendMode         _mBlendMode;
    KRVector2D          _mPos;
    KRColor             _mColor;

public:
    /*!
        @-var    _angle
        キャラクタの現在の角度です。
     */
    double              _angle;
    
public:
    /*!
        @task コンストラクタ
     */
    
    /*!
        @method KRChara2D
        @param classType    KRAnime2DManager でヒットテストを行う際に使われる、クラスの種類を示す値です。
        @param charaID      Karakuri Box で定義した、このキャラクタの特徴を表す ID です。
        <p>KRAnime2DManager でヒットテストを行う際に使うクラスの種類を示す値を、第1引数の classType に指定します。</p>
        <p>Karakuri Box で作成したキャラクタの ID を、第2引数の charaID に指定します。</p>
     */
    KRChara2D(int classType, int charaID);
    virtual ~KRChara2D();

    bool    _isTemporal() const;
    void    _setAsTemporal();
    
public:
    /*!
        @task 動作の管理
     */
    
    /*!
        @method changeMotion
        キャラクタの動作を変更します。
     */
    void    changeMotion(int motionID);

    /*!
        @method changeMotion
        キャラクタの動作を変更します。
     */
    void    changeMotion(int motionID, unsigned modeMask);

    /*!
        @method getMotionID
        @abstract キャラクタの現在の動作を取得します。
        動作の変更中は、変更完了後に予定されている動作がリターンされます。
     */
    int     getMotionID() const;

    /*!
        @method getCurrentMotionFrameIndex
        @abstract キャラクタの現在の動作におけるコマ番号（0 から開始）を取得します。
        動作の変更中は、変更完了後に予定されている動作に合わせて、0 がリターンされます。
     */
    int     getCurrentMotionFrameIndex() const;
    
    /*!
        @method isMotionFinished
        @abstract キャラクタの現在の動作が完了しているかどうかを取得します。
     */
    bool    isMotionFinished() const;
    
    /*!
        @method isMotionPaused
        @abstract キャラクタの動作が一時停止中かどうかを取得します。
     */
    bool    isMotionPaused() const;
    
    /*!
        @method pauseMotion
        @abstract 動作を一時停止中の状態に変更します。
        既に動作が一時停止中の場合には、何も起こりません。
     */
    void    pauseMotion();

    /*!
        @method startMotion
        @abstract 動作が一時停止中の場合に、動作を再開させます。
     */
    void    startMotion();

    /*!
        @method stopMotion
        @abstract 現在の動作を中断し、動作が完了したことにします。
     */
    void    stopMotion();


public:
    /*!
        @task 状態の取得
     */    
    
    /*!
        @method getCenterPos
        現在の拡大率における中心点の座標を取得します。
     */
    KRVector2D  getCenterPos() const;

    /*!
        @method getColor
        このキャラクタの現在の色を取得します。
     */
    KRColor     getColor() const;
    
    /*!
        @method getPos
        このキャラクタの現在位置（左下の点）を取得します。
     */
    KRVector2D  getPos() const;
    
    /*!
        @method getScale
        このキャラクタの現在の拡大率を取得します。
     */
    KRVector2D  getScale() const;
    
    /*!
        @method getSize
        テクスチャ・アトラスの1コマあたりのサイズをリターンします。拡大率は考慮されていません。
     */
    KRVector2D  getSize() const;
    
    /*!
        @method getZOrder
        キャラクタの現在のZオーダを取得します。
     */
    int         getZOrder() const;
    
    /*!
        @method isHidden
        キャラクが現在隠された（画面に描画されない）状態になっているかどうかを取得します。
     */
    bool        isHidden() const;
    
public:    
    /*!
        @task 状態の変更
     */
    
    /*!
        @method setBlendMode
        キャラクタを描画するためのブレンドモードを設定します。デフォルトでは、KRBlendModeAlpha が設定されています。
     */
    void    setBlendMode(KRBlendMode blendMode);
    
    /*!
        @method setCenterPos
       現在の拡大率における中心点の座標を指定して、キャラクタを移動させます。
     */
    void    setCenterPos(const KRVector2D& pos);
    
    /*!
        @method setColor
        キャラクタを描画する際の色を設定します。デフォルトでは、RGBA=(1.0, 1.0, 1.0, 1.0) の白が設定されています。
     */
    void    setColor(const KRColor& color);
    
    /*!
        @method setHidden
        キャラクタを隠された状態にするかどうかを設定します。
     */
    void    setHidden(bool flag);
    
    /*!
        @method setPos
        キャラクタを描画するための左下の点の座標を設定します。デフォルトでは、(0, 0) の点が設定されています。
     */
    void    setPos(const KRVector2D& pos);
    
    /*!
        @method setScale
        キャラクタの拡大率を設定します。デフォルトでは、1.0 となっています。
     */
    void    setScale(const KRVector2D& scale);
    
    /*!
        @method setZOrder
        キャラクタのZオーダを設定します。デフォルトでは、0 となっています。
     */
    void    setZOrder(int zOrder);

public:
    /*!
        @task 当たり判定
     */

    /*!
        @method contains
        @abstract このキャラクタを囲む境界線の中に、与えられた点が含まれるかどうかを判定します。
     */
    bool    contains(const KRVector2D& pos) const;

    /*!
        @method getClassType
        このキャラクタ・クラスの種類を取得します。この値は、キャラクタ生成時に、KRChara2D クラスのコンストラクタで第2引数として渡されたものです。
     */
    int     getClassType() const;
    
    /*!
        @method hitTest
        @abstract 与えられた点に対して、指定された種類の当たり判定領域との当たり判定を行ないます。
     */
    bool    hitTest(int hitType, const KRVector2D& pos) const;
    
    /*!
        @method hitTest
        @abstract 与えられたキャラクタに対して、指定された種類の当たり判定領域との当たり判定を行ないます。
     */
    bool    hitTest(int hitType, const KRChara2D* targetChara, int targetHitType) const;
    
    
    _KRChara2DKoma* _getCurrentKoma() const;

public:
    void    _step();    KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    void    _draw();    KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    bool    _isInList() const;          KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    void    _setIsInList(bool flag);    KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    
};

