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


struct _KRChara2DState {
    int     state;
    int     repeatCount;
    bool    doReverse;
    int     imageInterval;
    int     nextState;
    int     repeatHeadIndex;

    std::vector<KRVector2DInt>  atlasPositions;
    std::list<int>              backToState;
};


/*
    @-class KRChara2DSpec
    @group Game 2D Graphics
    <p><a href="../../Classes/KRAnime2D/index.html#//apple_ref/cpp/cl/KRAnime2D">KRAnime2D</a> クラスで利用するキャラクタの特徴を表すためのクラスです。</p>
    <p>このクラスのインスタンスは、直接 new することもできますが、<a href="../../Classes/KRAnime2D/index.html#//apple_ref/cpp/instm/KRAnime2D/loadCharacterSpecs/void_loadCharacterSpecs(const_std::string@_specFileName)">KRAnime2D::loadCharacterSpecs()</a> 関数を使って、キャラクタの特徴記述ファイルから読み込むこともできます。キャラクタの特徴記述ファイルの仕様については、「<a href="../../../../guide/2d_anime.html">2Dアニメーションの管理</a>」を参照してください。</p>
 */
class KRChara2DSpec : public KRObject {
    std::map<int, _KRChara2DState*> mStateMap;
    int                             mTextureID;
    int                             mSpecID;

public:
    /*!
        @task コンストラクタ
     */

    /*!
        @method KRChara2DSpec
        テクスチャ名とアトラスのサイズを指定して、新しいキャラクタの特徴を生成します。
     */
    KRChara2DSpec(int texGroupID, const std::string& textureName, const KRVector2D& atlasSize);
    
    ~KRChara2DSpec();
    
public:
    /*!
        @task 状態の管理
     */

    /*!
        @method addState
        キャラクタの特徴として、新しいキャラクタ状態を追加します。
     */
    void    addState(int state, int imageInterval, int repeatCount, bool doReverse, int nextState=-1);

    /*!
        @method addStateImage
        キャラクタの状態を指定して、新しいアニメーションのコマを、テクスチャのアトラスの座標として追加します。
     */
    void    addStateImage(int state, const KRVector2DInt& atlasPos, bool isRepeatHead = false);
    
    _KRChara2DState*        _getState(int state);   KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    int                     _getTextureID() const;  KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    int                     _getSpecID() const;     KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    bool                    _isTextureAtlased() const;  KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    void                    _setSpecID(int specID); KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    
};

/*!
    @class KRChara2D
    @group Game 2D Graphics
    <p><a href="../../Classes/KRAnime2D/index.html#//apple_ref/cpp/cl/KRAnime2D">KRAnime2D</a> クラスで利用できるアニメーション用のキャラクタを表すためのクラスです。</p>
    <p>このクラスのインスタンスは、グローバル変数 gKRAnime2DInst を使ってアクセスできる <a href="../../Classes/KRAnime2D/index.html#//apple_ref/cpp/cl/KRAnime2D">KRAnime2D</a> クラスの <a href="../../Classes/KRAnime2D/index.html#//apple_ref/cpp/instm/KRAnime2D/createCharacter/KRCharacter2D*_createCharacter(int_specID,_const_KRVector2D@_centerPos,_int_zOrder_=_0,_int_firstState_=_0)">createCharacter</a> メソッドを使って作成します。</p>
    <p>作成したキャラクタは、ゲーム終了時に自動的に削除されますが、ゲーム実行中に削除する場合には、<a href="../../Classes/KRAnime2D/index.html#//apple_ref/cpp/instm/KRAnime2D/removeCharacter/void_removeCharacter(KRCharacter2D_*chara)">removeCharacter</a> メソッドを使って削除してください。</p>
    <p>キャラクタの現在位置は、テクスチャアトラス描画の中心点を示します。現在位置は、public な pos 変数を直接いじって変更してください。</p>
    <p>キャラクタの描画色は、public な color 変数を直接いじって変更してください。</p>
    <p>キャラクタのZオーダは、現在位置や描画色とは違い、setZOrder() メソッドを使って変更してください。</p>
 */
class KRChara2D : public KRObject {

    friend class KRAnime2DManager;
    
    KR_DECLARE_USE_ALLOCATOR(gKRChara2DAllocator)

private:
    KRChara2DSpec*      mCharaSpec;
    int                 mState;
    int                 mImageInterval;
    int                 mZOrder;
    int                 mImageIndex;
    bool                mIsStateFinished;
    int                 mImageInc;
    int                 mRepeatCount;
    int                 mNextState;
    bool                mHasPassedHead;
    
    void*               mRepresentedObject;
    
    bool                mIsParticle;
    
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
    void    changeState(int state);

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
    <p>基本的には、<a href="#//apple_ref/cpp/instm/KRAnime2D/loadCharacterSpecs/void_loadCharacterSpecs(const_std::string@_specFileName)">loadCharacterSpecs()</a> メソッドを使ってキャラクタの特徴記述ファイルを読み込み、<a href="#//apple_ref/cpp/instm/KRAnime2D/startLoadingTextures/void_startLoadingTextures()">startLoadingTextures()</a> メソッドを使ってテクスチャの読み込みを行います。その後、<a href="#//apple_ref/cpp/instm/KRAnime2D/createCharacter/KRCharacter2D*_createCharacter(int_specID,_const_KRVector2D@_centerPos,_int_zOrder_=_0,_int_firstState_=_0)">createCharacters()</a> メソッドを使ってキャラクタを生成してください。生成されたキャラクタは、<a href="../../Classes/KRCharacter2D/index.html#//apple_ref/cpp/cl/KRCharacter2D">KRCharacter2D</a> クラスのインスタンスとして参照できます。</p>
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
        @method addCharaSpecs
        @abstract ゲーム内で利用するキャラクタの特徴ファイルを追加します。
        <p>キャラクタの特徴記述ファイルの仕様は、開発ガイドの「<a href="../../../../guide/2d_anime.html">2Dアニメーションの管理</a>」を参照してください。</p>
     */
    void    addCharaSpecs(int groupID, const std::string& specFileName);
    
    int     _addTexCharaSpec(int groupID, const std::string& imageFileName);
    

    /*!
        @method createChara2D
        @abstract キャラクタの特徴 ID、最初の表示位置、状態を指定して、新しいキャラクタを生成します。
        オプションで、Zオーダと、このキャラクタに関連付けるオブジェクトも指定できます。
     */
    KRChara2D*  createChara2D(int specID, const KRVector2D& centerPos, int firstState, int zOrder = 0, void *repObj = NULL);
    KRChara2D*  _createChara2DParticle(int specID, const KRVector2D& centerPos, int firstState, int zOrder = 0, void *repObj = NULL);

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
        @method addParticleSystem
        @abstract 2次元の移動を行うパーティクル管理のシステムを生成します。火、爆発、煙、雲、霧などの表現に利用できます。
     */
    int     addParticleSystem(int groupID, const std::string& imageFileName, int zOrder);
    
    KRParticle2DSystem* _getParticleSystem(int particleID) const;

    /*!
        @method generateParticles
        指定された座標に、新しいパーティクルを生成します。
     */
    void    generateParticles(int particleID, const KRVector2D& pos);
    
    void    stepParticles();
    
    KRBlendMode     getParticleBlendMode(int particleID) const;
    KRColor         getParticleColor(int particleID) const;
    int             getParticleCount(int particleID) const;
    double          getParticleAlphaDelta(int particleID) const;
    double          getParticleBlueDelta(int particleID) const;
    double          getParticleGreenDelta(int particleID) const;
    double          getParticleRedDelta(int particleID) const;
    double          getParticleScaleDelta(int particleID) const;
    int             getParticleGenerateCount(int particleID) const;
    KRVector2D      getParticleGravity(int particleID) const;
    int             getParticleLife(int particleID) const;
    double          getParticleMaxAngleV(int particleID) const;
    int             getParticleMaxCount(int particleID) const;
    double          getParticleMaxScale(int particleID) const;
    KRVector2D      getParticleMaxV(int particleID) const;
    double          getParticleMinAngleV(int particleID) const;
    double          getParticleMinScale(int particleID) const;
    KRVector2D      getParticleMinV(int particleID) const;
    
    void    setParticleBlendMode(int particleID, KRBlendMode blendMode);
    void    setParticleColor(int particleID, const KRColor& color);
    void    setParticleColorDelta(int particleID, double red, double green, double blue, double alpha);
    void    setParticleGenerateCount(int particleID, int count);
    void    setParticleGravity(int particleID, const KRVector2D& a);
    void    setParticleLife(int particleID, unsigned life);
    void    setParticleMaxAngleV(int particleID, double angleV);
    void    setParticleMaxCount(int particleID, unsigned count);
    void    setParticleMaxScale(int particleID, double scale);
    void    setParticleMaxV(int particleID, const KRVector2D& v);
    void    setParticleMinAngleV(int particleID, double angleV);
    void    setParticleMinScale(int particleID, double scale);
    void    setParticleMinV(int particleID, const KRVector2D& v);
    void    setParticleScaleDelta(int particleID, double value);

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

};


/*!
    @var    gKRAnime2DMan
    @group  Game 2D Graphics
    @abstract 2Dアニメーション管理機構のインスタンスを指す変数です。
    この変数が指し示すオブジェクトは、ゲーム実行の最初から最後まで絶対に変わりません。
 */
extern KRAnime2DManager*    gKRAnime2DMan;


