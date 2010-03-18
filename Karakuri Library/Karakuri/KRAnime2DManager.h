/*!
    @file   KRAnime2DManager.h
    @author Satoshi Numata
    @date   10/01/11
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/Karakuri.h>


class KRParticle2DSystem;
class KRSimulator2D;


extern KRMemoryAllocator*   gKRChara2DAllocator;


static const unsigned       KRCharaStateChangeModeNormalMask            = 0x00;
static const unsigned       KRCharaStateChangeModeIgnoreCancelFlagMask  = 0x01;
static const unsigned       KRCharaStateChangeModeSkipEndMask           = 0x02;



class KRChara2DKoma : public KRObject {

    int     mTextureID;
    int     mAtlasIndex;
    int     mGotoTarget;
    bool    mIsCancelable;
    int     mInterval;
    
    KRVector2DInt   mAtlasPos;

public:
    KRChara2DKoma();

    void    initForManualChara2D(int textureID, KRVector2DInt atlasPos, int interval, bool isCancelable, int gotoTarget);
    void    initForBoxChara2D(const std::string& imageTicket, int atlasIndex, int interval, bool isCancelable, int gotoTarget);

public:
    KRVector2DInt   getAtlasPos();
    KRVector2D      getAtlasSize();
    int             getGotoTarget();
    int             getInterval();
    int             getTextureID();
    
};


class KRChara2DState : public KRObject {
    
    std::vector<KRChara2DKoma*>   mKomas;

    int     mCancelKomaNumber;
    int     mNextStateID;

public:
    KRChara2DState();
    
    void    initForManualChara2D(int cancelKomaNumber, int nextStateID);
    void    initForBoxChara2D(int cancelKomaNumber, int nextStateID);
    
public:
    void    addKoma(KRChara2DKoma* aKoma);
    
public:
    int             getKomaCount();
    KRChara2DKoma*  getKoma(int komaNumber);
    
};


/*
    @-class KRChara2DSpec
    @group Game 2D Graphics
    <p><a href="../../Classes/KRAnime2D/index.html#//apple_ref/cpp/cl/KRAnime2D">KRAnime2D</a> クラスで利用するキャラクタの特徴を表すためのクラスです。</p>
    <p>このクラスのインスタンスは、直接 new することもできますが、<a href="../../Classes/KRAnime2D/index.html#//apple_ref/cpp/instm/KRAnime2D/loadCharacterSpecs/void_loadCharacterSpecs(const_std::string@_specFileName)">KRAnime2D::loadCharacterSpecs()</a> 関数を使って、キャラクタの特徴記述ファイルから読み込むこともできます。キャラクタの特徴記述ファイルの仕様については、「<a href="../../../../guide/2d_anime.html">2Dアニメーションの管理</a>」を参照してください。</p>
 */
class KRChara2DSpec : public KRObject {
    std::map<int, KRChara2DState*>  mStateMap;
    int                             mSpecID;
    int                             mGroupID;
    
    int                             mParticleTexID;

public:
    /*!
        @task コンストラクタ
     */

    /*!
        @method KRChara2DSpec
        テクスチャ名とアトラスのサイズを指定して、新しいキャラクタの特徴を生成します。
     */
    //KRChara2DSpec(int texGroupID, const std::string& textureName, const KRVector2D& atlasSize);
    
    KRChara2DSpec(int groupID);

    ~KRChara2DSpec();
    
    void    initForManualChara2D();
    void    initForManualParticle2D(const std::string& fileName);
    void    initForBoxParticle2D(const std::string& imageTicket);
    
public:
    /*!
        @task 状態の管理
     */

    void    addState(int stateID, KRChara2DState* aState);

    KRChara2DState*         getState(int state);
    int                     getParticleTextureID() const;
    int                     getSpecID() const;
    void                    setSpecID(int specID);
    bool                    isParticle();
    
};

/*!
    @class KRChara2D
    @group Game 2D Graphics
    <p><a href="../../Classes/KRAnime2D/index.html#//apple_ref/cpp/cl/KRAnime2D">KRAnime2D</a> クラスで利用できるアニメーション用のキャラクタを表すためのクラスです。</p>
    <p>このクラスのインスタンスは、グローバル変数 gKRAnime2DInst を使ってアクセスできる <a href="../../Classes/KRAnime2D/index.html#//apple_ref/cpp/cl/KRAnime2D">KRAnime2D</a> クラスの createChara2D() メソッドを使って作成します。</p>
    <p>作成したキャラクタは、ゲーム終了時に自動的に削除されますが、ゲーム実行中に削除する場合には、removeChara2D メソッドを使って削除してください。</p>
    <p>キャラクタの現在位置は、テクスチャアトラス描画の中心点を示します。現在位置は、public な pos 変数を直接いじって変更してください。</p>
    <p>キャラクタの描画色は、public な color 変数を直接いじって変更してください。</p>
    <p>キャラクタのZオーダは、現在位置や描画色とは違い、setZOrder() メソッドを使って変更してください。</p>
 */
class KRChara2D : public KRObject {

    friend class KRAnime2DManager;
    
    KR_DECLARE_USE_ALLOCATOR(gKRChara2DAllocator)

private:
    KRChara2DSpec*      mCharaSpec;

    int                 mCurrentStateID;
    int                 mCurrentKomaNumber;

    int                 mImageInterval;
    int                 mZOrder;
    int                 mRepeatCount;
    bool                mIsFinished;

    void*               mRepresentedObject;
    
public:
    /*!
        @-var    _angle
        キャラクタの現在の角度です。
     */
    double              _angle;
    
    /*!
        @var    blendMode
        キャラクタの現在の描画モードです。
     */
    KRBlendMode         blendMode;

    /*!
        @var    color
        キャラクタの現在の描画色です。
     */
    KRColor             color;
    
    /*!
        @var    pos
        キャラクタの現在の描画位置です。テクスチャアトラス描画の中心点を示します。
     */
    KRVector2D          pos;
    
    /*!
        @var    scale
        キャラクタの現在の拡大率です。
     */
    double              scale;

public:
    KRChara2D(KRChara2DSpec *charaSpec, const KRVector2D& centerPos, int zOrder, void *repObj = NULL);
    
public:
    /*!
        @task 状態の取得
     */

    /*!
        @method getObject
        このキャラクタに関連付けられているオブジェクトのポインタを取得します。
     */
    void    *getObject() const;

    /*!
        @method getSize
        テクスチャ・アトラスの1コマあたりのサイズをリターンします。
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
    void    changeState(int stateID, unsigned modeMask = KRCharaStateChangeModeNormalMask);

    /*!
        @method setObject
        このキャラクタに関連付けるオブジェクトのポインタを指定します。
     */
    void    setObject(void *anObj);

    /*!
        @method setZOrder
        キャラクタのZオーダを変更します。
     */
    void    setZOrder(int zOrder);
    
public:
    void    _step();    KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    void    _draw();    KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY

};

/*!
    @class KRAnime2DManager
    @group Game 2D Graphics
    <p>キャラクタのアニメーションを管理するためのクラスです。</p>
    <p>このクラスのオブジェクトには、gKRAnime2DMan 変数を使ってアクセスしてください。</p>
    <p>主な使い方は、「<a href="../../../../guide/2d_anime.html">2Dアニメーションの管理</a>」を参照してください。</p>
 */
class KRAnime2DManager : public KRObject {

    std::map<int, KRChara2DSpec*>   mCharaSpecMap;
    std::list<KRChara2D*>           mCharas;
    
    std::map<int, KRParticle2DSystem*>  mParticleSystemMap;
    std::map<int, KRSimulator2D*>       mSimulatorMap;
    
    int                             mNextInnerCharaSpecID;
    int                             mNextSimulatorID;

public:
	KRAnime2DManager(int maxChara2DSize);
	virtual ~KRAnime2DManager();

public:
    
#pragma mark ---- アニメーションの描画 ----
    
    /*!
     @task アニメーションの描画
     */

    /*!
        @method draw
        すべてのキャラクタを描画します。重なって表示されるキャラクタには、Zオーダが適用されます。
     */
    void    draw();
    
    /*!
        @-method stepAllCharas
        すべてのキャラクタのアニメーションをステップ実行します。
     */
    void    stepAllCharas();
    
    
#pragma mark ---- キャラクタの管理 ----

    /*!
        @task キャラクタの管理
     */

    /*!
        @-method _addCharaSpec
        @abstract キャラクタの ID を指定して、新しいキャラクタの特徴を追加します。
        追加されたキャラクタの特徴は、ゲーム終了時に自動的に delete されます。
     */
    void    _addCharaSpec(int specID, KRChara2DSpec *spec);
    
    /*!
        @-method loadCharaSpecs
        @abstract ゲーム内で利用するキャラクタの特徴を、指定されたファイルから読み込みます。
        <p>キャラクタの特徴記述ファイルの仕様は、開発ガイドの「<a href="../../../../guide/2d_anime.html">2Dアニメーションの管理</a>」を参照してください。</p>
     */
    void    _loadCharaSpecs(const std::string& specFileName);
    
    /*!
        @method addCharacterSpecs
        @abstract ゲーム内で利用するキャラクタの特徴ファイルを追加します。
        <p>キャラクタの特徴記述ファイルの仕様は、開発ガイドの「<a href="../../../../guide/2d_anime.html">2Dアニメーションの管理</a>」を参照してください。</p>
     */
    void    addCharacterSpecs(int groupID, const std::string& specFileName);
    
    int     _addTexCharaSpec(int groupID, const std::string& imageFileName);
    int     _addTexCharaSpecWithTicket(int groupID, const std::string& ticket);
    

    /*!
        @method createChara2D
        @abstract キャラクタの特徴 ID、最初の表示位置、状態を指定して、新しいキャラクタを生成します。
        オプションで、Zオーダと、このキャラクタに関連付けるオブジェクトも指定できます。
     */
    KRChara2D*  createChara2D(int specID, const KRVector2D& centerPos, int firstState, int zOrder = 0, void *repObj = NULL);

    /*!
        @method removeAllCharas
        生成されたすべてのキャラクタを削除します。
     */
    void    removeAllCharas();
    
    /*!
        @method removeChara2D
        キャラクタを削除します。削除したキャラクタは、自動的に delete されます。
     */
    void    removeChara2D(KRChara2D *chara);

    void    _reorderChara2D(KRChara2D *chara);    KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY

    
#pragma mark ---- 2Dシミュレータの管理 ----

    int     addSimulator(const KRVector2D& gravity);
    void    putCharaInSimulator(KRChara2D* aChara, int simulatorID);
    

#pragma mark ---- パーティクルの管理 ----

    /*!
        @task パーティクルの管理
     */

    
    /*!
        @method addParticle2D
        @abstract 2次元の移動を行うパーティクル管理のシステムを生成します。火、爆発、煙、雲、霧などの表現に利用できます。
     */
    int     addParticle2D(int groupID, const std::string& imageFileName);
    
    void    _addParticle2DWithTicket(int resourceID, int groupID, const std::string& imageTicket);
    
    KRParticle2DSystem* _getParticleSystem(int particleID) const;

    /*!
        @method generateParticle2D
        指定された座標に、新しいパーティクルを生成します。
     */
    void    generateParticle2D(int particleID, const KRVector2D& pos);
    
    void    stepParticles();
    
    /*!
        @task パーティクルの管理（状態の取得）
     */
    
    /*!
        @method getParticle2DBlendMode
        @abstract IDを指定して、パーティクル描画時のブレンドモードを取得します。
     */
    KRBlendMode     getParticle2DBlendMode(int particleID) const;

    /*!
        @method getParticle2DColor
        @abstract IDを指定して、パーティクル描画の基本色を取得します。
     */
    KRColor         getParticle2DColor(int particleID) const;

    /*!
        @method getParticle2DCount
        @abstract IDを指定して、現在までに生成されたパーティクルの個数を取得します。
     */
    int             getParticle2DCount(int particleID) const;

    /*!
        @method getParticle2DAlphaDelta
        @abstract IDを指定して、パーティクルのアルファ値の変化量を取得します。
     */
    double          getParticle2DAlphaDelta(int particleID) const;

    /*!
        @method getParticle2DBlueDelta
        @abstract IDを指定して、パーティクルの青成分の変化量を取得します。
     */
    double          getParticle2DBlueDelta(int particleID) const;

    /*!
        @method getParticle2DGreenDelta
        @abstract IDを指定して、パーティクルの緑成分の変化量を取得します。
     */
    double          getParticle2DGreenDelta(int particleID) const;

    /*!
        @method getParticle2DRedDelta
        @abstract IDを指定して、パーティクルの赤成分の変化量を取得します。
     */
    double          getParticle2DRedDelta(int particleID) const;

    /*!
        @method getParticle2DScaleDelta
        @abstract IDを指定して、拡大率の変化量を取得します。
     */
    double          getParticle2DScaleDelta(int particleID) const;

    /*!
        @method getParticle2DGenerateCount
        @abstract IDを指定して、1フレームあたりのパーティクルの生成量を取得します。
     */
    int             getParticle2DGenerateCount(int particleID) const;

    /*!
        @method getParticle2DGravity
        @abstract IDを指定して、パーティクルに設定される重力を取得します。
     */
    KRVector2D      getParticle2DGravity(int particleID) const;

    /*!
        @method getParticle2DLife
        @abstract IDを指定して、パーティクルに設定される生存期間（フレーム単位）を取得します。
     */
    int             getParticle2DLife(int particleID) const;

    /*!
        @method getParticle2DMaxAngleV
        @abstract IDを指定して、パーティクルに設定される回転の最大の角速度を設定します。
        回転の角速度は、生成時に設定の範囲内でランダムに設定されます。
     */
    double          getParticle2DMaxAngleV(int particleID) const;

    /*!
        @method getParticle2DMaxCount
        @abstract IDを指定して、パーティクルの最大生成量を設定します。
     */
    int             getParticle2DMaxCount(int particleID) const;

    /*!
        @method getParticle2DMaxScale
        @abstract IDを指定して、パーティクルに設定される最大の拡大率を設定します。
        拡大率は、生成時に設定の範囲内でランダムに設定されます。
     */
    double          getParticle2DMaxScale(int particleID) const;

    /*!
        @method getParticle2DMaxV
        @abstract IDを指定して、パーティクルに設定される最大の速度を設定します。
        速度は、生成時に設定の範囲内でランダムに設定されます。
     */
    KRVector2D      getParticle2DMaxV(int particleID) const;

    /*!
        @method getParticle2DMinAngleV
        @abstract IDを指定して、パーティクルに設定される回転の最小の角速度を設定します。
        回転の角速度は、生成時に設定の範囲内でランダムに設定されます。
     */
    double          getParticle2DMinAngleV(int particleID) const;

    /*!
        @method getParticle2DMinScale
        @abstract IDを指定して、パーティクルに設定される最小の拡大率を設定します。
        拡大率は、生成時に設定の範囲内でランダムに設定されます。
     */
    double          getParticle2DMinScale(int particleID) const;

    /*!
        @method getParticle2DMinV
        @abstract IDを指定して、パーティクルに設定される最小の速度を設定します。
        速度は、生成時に設定の範囲内でランダムに設定されます。
     */
    KRVector2D      getParticle2DMinV(int particleID) const;

    /*!
        @task パーティクルの管理（状態の設定）
     */
    
    /*!
        @method setParticle2DBlendMode
        @abstract IDを指定して、パーティクル描画時のブレンドモードを設定します。
     */
    void    setParticle2DBlendMode(int particleID, KRBlendMode blendMode);

    /*!
        @method setParticle2DColor
        @abstract IDを指定して、パーティクル描画の基本色を設定します。
     */
    void    setParticle2DColor(int particleID, const KRColor& color);

    /*!
        @method setParticle2DColorDelta
        @abstract IDを指定して、パーティクルの色の変化量を設定します。
     */
    void    setParticle2DColorDelta(int particleID, double red, double green, double blue, double alpha);

    /*!
        @method setParticle2DGenerateCount
        @abstract IDを指定して、1フレームあたりのパーティクルの生成量を設定します。
     */
    void    setParticle2DGenerateCount(int particleID, int count);

    /*!
        @method setParticle2DGravity
        @abstract IDを指定して、パーティクルに設定される重力を設定します。
     */
    void    setParticle2DGravity(int particleID, const KRVector2D& a);

    /*!
        @method setParticle2DLife
        @abstract IDを指定して、パーティクルに設定される生存期間（フレーム単位）を設定します。
     */
    void    setParticle2DLife(int particleID, unsigned life);

    /*!
        @method setParticle2DMaxAngleV
        @abstract IDを指定して、パーティクルに設定される回転の最大の角速度を設定します。
        回転の角速度は、生成時に設定の範囲内でランダムに設定されます。
     */
    void    setParticle2DMaxAngleV(int particleID, double angleV);

    /*!
        @method setParticle2DMaxCount
        @abstract IDを指定して、パーティクルの最大の生成数を設定します。
     */
    void    setParticle2DMaxCount(int particleID, unsigned count);

    /*!
        @method setParticle2DMaxScale
        @abstract IDを指定して、パーティクルに設定される最大の拡大率を設定します。
        拡大率は、生成時に設定の範囲内でランダムに設定されます。
     */
    void    setParticle2DMaxScale(int particleID, double scale);

    /*!
        @method setParticle2DMaxV
        @abstract IDを指定して、パーティクルに設定される最大の速度を設定します。
        速度は、生成時に設定の範囲内でランダムに設定されます。
     */
    void    setParticle2DMaxV(int particleID, const KRVector2D& v);

    /*!
        @method setParticle2DMinAngleV
        @abstract IDを指定して、パーティクルに設定される回転の最小の角速度を設定します。
        回転の角速度は、生成時に設定の範囲内でランダムに設定されます。
     */
    void    setParticle2DMinAngleV(int particleID, double angleV);

    /*!
        @method setParticle2DMinScale
        @abstract IDを指定して、パーティクルに設定される最小の拡大率を設定します。
        拡大率は、生成時に設定の範囲内でランダムに設定されます。
     */
    void    setParticle2DMinScale(int particleID, double scale);

    /*!
        @method setParticle2DMinV
        @abstract IDを指定して、パーティクルに設定される最小の速度を設定します。
        速度は、生成時に設定の範囲内でランダムに設定されます。
     */
    void    setParticle2DMinV(int particleID, const KRVector2D& v);

    /*!
        @method setParticle2DScaleDelta
        @abstract IDを指定して、パーティクルに設定される拡大率の変化量を設定します。
        拡大率は、生成時に設定の範囲内でランダムに設定されます。
     */
    void    setParticle2DScaleDelta(int particleID, double value);

};


/*!
    @var    gKRAnime2DMan
    @group  Game 2D Graphics
    @abstract 2Dアニメーション管理機構のインスタンスを指す変数です。
    この変数が指し示すオブジェクトは、ゲーム実行の最初から最後まで絶対に変わりません。
 */
extern KRAnime2DManager*    gKRAnime2DMan;


