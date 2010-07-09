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


extern KRMemoryAllocator*   gKRChara2DAllocator;


static const unsigned       KRCharaStateChangeModeNormalMask            = 0x00;
static const unsigned       KRCharaStateChangeModeIgnoreCancelFlagMask  = 0x01;
static const unsigned       KRCharaStateChangeModeSkipEndMask           = 0x02;


enum _KRChara2DHitAreaType {
    _KRChara2DHitAreaTypeRect = 0,
    _KRChara2DHitAreaTypeOval = 1,
};


struct _KRChara2DHitArea {
    int                     group;
    _KRChara2DHitAreaType   type;
    KRRect2D                rect;
    
    bool    hitTest(const KRVector2D& offset, const KRVector2D& scale, const KRVector2D& pos) const;
    bool    hitTest(const KRVector2D& offset, const KRVector2D& scale, int count, _KRChara2DHitArea* hitAreas, int targetHitType, const KRVector2D& targetOffset, const KRVector2D& targetScale) const;
};


class _KRChara2DKoma : public KRObject {
    
    int     mTextureID;
    int     mAtlasIndex;
    int     mGotoTarget;
    bool    mIsCancelable;
    int     mInterval;
    
    KRVector2DInt       mAtlasPos;
    int                 mHitAreaCount;
    _KRChara2DHitArea*  mHitAreas;
    
public:
    _KRChara2DKoma();
    ~_KRChara2DKoma();
    
    void    initForManualChara2D(int textureID, KRVector2DInt atlasPos, int interval, bool isCancelable, int gotoTarget);
    void    initForBoxChara2D(const std::string& imageTicket, int atlasIndex, int interval, bool isCancelable, int gotoTarget);
    
public:
    KRVector2DInt   getAtlasPos();
    KRVector2D      getAtlasSize();
    int             getGotoTarget();
    int             getInterval();
    int             getTextureID();
    
public:
    void            _importHitArea(void* hitInfo);
    int             _getHitAreaCount() const;
    _KRChara2DHitArea*  _getHitAreas() const;
    
};


class _KRChara2DState : public KRObject {
    
    std::vector<_KRChara2DKoma*>   mKomas;
    
    int     mCancelKomaNumber;
    int     mNextStateID;
    
public:
    _KRChara2DState();
    
    void    initForManualChara2D(int cancelKomaNumber, int nextStateID);
    void    initForBoxChara2D(int cancelKomaNumber, int nextStateID);
    
public:
    void    addKoma(_KRChara2DKoma* aKoma);
    
public:
    int             getKomaCount();
    _KRChara2DKoma* getKoma(int komaNumber);
    
};


/*
    @-class KRChara2DSpec
    @group Game 2D Graphics
    <p><a href="../../Classes/KRAnime2D/index.html#//apple_ref/cpp/cl/KRAnime2D">KRAnime2D</a> クラスで利用するキャラクタの特徴を表すためのクラスです。</p>
    <p>このクラスのインスタンスは、直接 new することもできますが、<a href="../../Classes/KRAnime2D/index.html#//apple_ref/cpp/instm/KRAnime2D/loadCharacterSpecs/void_loadCharacterSpecs(const_std::string@_specFileName)">KRAnime2D::loadCharacterSpecs()</a> 関数を使って、キャラクタの特徴記述ファイルから読み込むこともできます。キャラクタの特徴記述ファイルの仕様については、「<a href="../../../../guide/2d_anime.html">2Dアニメーションの管理</a>」を参照してください。</p>
 */
class _KRChara2DSpec : public KRObject {
    std::map<int, _KRChara2DState*>  mStateMap;
    int                             mSpecID;
    int                             mGroupID;
    
    int                             mParticleTexID;
    std::string                     mSpecName;
    
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
    void    initForBoxParticle2D(const std::string& imageTicket);
    
public:
    /*!
     @task 状態の管理
     */
    
    void    addState(int stateID, _KRChara2DState* aState);
    
    std::string             getSpecName() const;
    _KRChara2DState*        getState(int state);
    int                     getParticleTextureID() const;
    int                     getSpecID() const;
    void                    setSpecID(int specID);
    bool                    isParticle();
    
};

/*!
    @class KRChara2DElem
    @group Game 2D Graphics
    <p><a href="../../Classes/KRAnime2D/index.html#//apple_ref/cpp/cl/KRAnime2D">KRAnime2D</a> クラスで利用できるアニメーション用のキャラクタを表すためのクラスです。</p>
    <p>このクラスのインスタンスは、グローバル変数 gKRAnime2DInst を使ってアクセスできる <a href="../../Classes/KRAnime2D/index.html#//apple_ref/cpp/cl/KRAnime2D">KRAnime2D</a> クラスの createChara2D() メソッドを使って作成します。</p>
    <p>作成したキャラクタは、ゲーム終了時に自動的に削除されますが、ゲーム実行中に削除する場合には、removeChara2D メソッドを使って削除してください。</p>
    <p>キャラクタの現在位置は、テクスチャアトラス描画の中心点を示します。現在位置は、public な pos 変数を直接いじって変更してください。</p>
    <p>キャラクタの描画色は、public な color 変数を直接いじって変更してください。</p>
    <p>キャラクタのZオーダは、現在位置や描画色とは違い、setZOrder() メソッドを使って変更してください。</p>
 */
class KRChara2D : public KRObject {
    
    KR_DECLARE_USE_ALLOCATOR(gKRChara2DAllocator)
    
private:
    _KRChara2DSpec*     _mCharaSpec;
    int                 _mClassType;

    int                 _mCurrentStateID;
    int                 _mCurrentKomaNumber;
    
    int                 _mImageInterval;
    int                 _mZOrder;
    int                 _mRepeatCount;
    bool                _mIsFinished;    
    bool                _mIsTemporal;
    
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
    KRChara2D(int charaSpecID, int charaType);
    virtual ~KRChara2D();

    bool    _isTemporal() const;
    bool    _isFinished() const;
    void    _setAsTemporal();
    
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
    
    
    /*!
        @task 状態の取得
     */    
    
    /*!
        @method getCenterPos
        現代の拡大率における中心点の座標を取得します。
     */
    KRVector2D  getCenterPos() const;

    /*!
        @method getClassType
        このキャラクタ・クラスの種類を取得します。
     */
    int     getClassType() const;
    
    KRColor     getColor() const;
    
    KRVector2D  getPos() const;
    
    KRVector2D  getScale() const;
    
    /*!
        @method getSize
        テクスチャ・アトラスの1コマあたりのサイズをリターンします。拡大率は考慮されていません。
     */
    KRVector2D  getSize() const;
    
    /*!
        @method getState
        @abstract キャラクタの現在の状態を取得します。
        状態の変更中は、変更後の状態がリターンされます。
     */
    int         getState() const;
    
    /*!
        @method getZOrder
        キャラクタの現在のZオーダを取得します。
     */
    int         getZOrder() const;
    
public:
    /*!
        @task 状態の変更
     */
    
    /*!
        @method changeState
        キャラクタの状態を変更します。
     */
    void    changeState(int stateID);

    void    changeState(int stateID, unsigned modeMask);
    
    void    setBlendMode(KRBlendMode blendMode);
    
    /*!
        @method setCenterPos
       現在の拡大率における中心点の座標を指定して、キャラクタを移動させます。
     */
    void    setCenterPos(const KRVector2D& pos);
    
    void    setColor(const KRColor& color);
    
    void    setPos(const KRVector2D& pos);
    
    /*!
        @method setScale
        キャラクタの拡大率を設定します。
     */
    void    setScale(const KRVector2D& scale);
    
    /*!
        @method setZOrder
        キャラクタのZオーダを設定します。
     */
    void    setZOrder(int zOrder);
    
public:
    void    _step();    KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    void    _draw();    KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    
};

