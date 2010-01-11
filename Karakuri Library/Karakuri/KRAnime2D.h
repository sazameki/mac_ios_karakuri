/*!
    @file   KRAnime2D.h
    @author Satoshi Numata
    @date   10/01/11
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/Karakuri.h>



struct _KRCharacter2DState {
    int     state;
    int     repeatCount;
    bool    doReverse;
    int     imageInterval;
    int     nextState;
    int     repeatHeadIndex;

    std::vector<KRVector2DInt>  atlasPositions;
    std::list<int>              backToState;
};


struct _KRTexture2DInfo {
    std::string     textureName;
    KRVector2D      atlasSize;
    KRTexture2D*    textureObj;
};


/*!
    @class KRCharacter2DSpec
    @group Game 2D Graphics
    <p>キャラクタの特徴を表すためのクラスです。</p>
 */
class KRCharacter2DSpec : public KRObject {
    std::map<int, _KRCharacter2DState*>     mStateMap;
    int                                     mTextureID;
    int                                     mSpecID;

public:
    /*!
        @task コンストラクタ
     */

    /*!
        @method KRCharacter2DSpec
        テクスチャ名とアトラスのサイズを指定して、新しいキャラクタの特徴を生成します。
     */
    KRCharacter2DSpec(const std::string& textureName, const KRVector2D& atlasSize);
    
    ~KRCharacter2DSpec();
    
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
    
    _KRCharacter2DState*    _getState(int state);   KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    int                     _getTextureID() const;  KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    int                     _getSpecID() const;     KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    void                    _setSpecID(int specID); KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    
};

/*!
    @class KRCharacter2D
    @group Game 2D Graphics
    <p>個々のキャラクタを管理するためのクラスです。</p>
 */
class KRCharacter2D : public KRObject {
    
private:
    KRCharacter2DSpec*  mCharaSpec;
    int                 mState;
    int                 mImageInterval;
    int                 mZOrder;
    int                 mImageIndex;
    bool                mIsStateFinished;
    int                 mImageInc;
    int                 mRepeatCount;
    int                 mNextState;
    bool                mHasPassedHead;
    
public:
    KRVector2D          pos;
    KRColor             color;

public:
    KRCharacter2D(KRCharacter2DSpec *charaSpec, const KRVector2D& centerPos, int zOrder, int firstState);
    
public:
    /*!
        @task 状態の取得
     */
    /*!
        @method getSize
        キャラクタのサイズを取得します。
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
        @method setZOrder
        キャラクタのZオーダを変更します。
     */
    void    setZOrder(int zOrder);
    
public:
    void    _step();    KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    void    _draw();    KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY

};

/*!
    @class KRAnime2D
    @group Game 2D Graphics
    <p>キャラクタのアニメーションを管理するためのクラスです。</p>
    <p>このクラスのオブジェクトには、gKRAnime2DInst 変数を使ってアクセスしてください。</p>
 */
class KRAnime2D : public KRObject {

    std::map<int, KRCharacter2DSpec*>   mCharaSpecMap;
    std::list<KRCharacter2D*>           mCharacters;
    std::map<int, _KRTexture2DInfo*>    mTextureInfoMap;
    
public:
	KRAnime2D();
	virtual ~KRAnime2D();

public:
    
#pragma mark ---- キャラクタの特徴の管理 ----
    /*!
        @task キャラクタの特徴の管理
     */

    /*!
        @method addCharacterSpec
        @abstract キャラクタの ID を指定して、新しいキャラクタの特徴を追加します。
        追加されたキャラクタの特徴は、ゲーム終了時に自動的に delete されます。
     */
    void    addCharacterSpec(int specID, KRCharacter2DSpec *spec);
    
    /*!
        @method loadCharacterSpecs
        @abstract ゲーム内で利用するキャラクタの特徴を、指定されたファイルから読み込みます。
        <p>キャラクタの特徴記述の仕様は、開発ガイドの「キャラクタ・アニメーション」を参照してください。</p>
     */
    void    loadCharacterSpecs(const std::string& specFileName);


#pragma mark ---- キャラクタの管理 ----

    /*!
        @task キャラクタの管理
     */

    /*!
        @method createCharacter
        キャラクタの特徴 ID を指定して、新しいキャラクタを生成します。
     */
    KRCharacter2D*  createCharacter(int specID, const KRVector2D& centerPos, int zOrder = 0, int firstState = 0);
    
    /*!
        @method drawAllCharacters
        すべてのキャラクタを描画します。重なって表示されるキャラクタには、Zオーダが適用されます。
     */
    void    drawAllCharacters();

    /*!
        @method removeAllCharacters
        生成されたすべてのキャラクタを削除します。
     */
    void    removeAllCharacters();
    
    /*!
        @method removeCharacter
        キャラクタを削除します。削除したキャラクタは、自動的に delete されます。
     */
    void    removeCharacter(KRCharacter2D *chara);

    void    _reorderCharacter(KRCharacter2D *chara);    KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY

    /*!
        @method stepAllCharacters
        すべてのキャラクタのアニメーションをステップ実行します。
     */
    void    stepAllCharacters();

    
#pragma mark ---- テクスチャの管理 ----
    /*!
        @task テクスチャの管理
     */
    
    int     _addTexture(const std::string& textureName, const KRVector2D& atlasSize);   KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
    void    _drawTexture(int textureID, const KRVector2DInt& atlasPos, const KRVector2D& centerPos, const KRColor& color);  KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY    
    KRTexture2D* _getTexture(int textureID);    KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY

    /*!
        @method getTextureLoadingProgress
        テクスチャ読み込みの進行度合いを取得します。
     */
    double  getTextureLoadingProgress() const;
    
    /*!
        @method isLoadingTextures
        テクスチャ読み込みが行われているかどうかを取得します。
     */
    bool    isLoadingTextures() const;
    
    /*!
        @method startLoadingTextures
        テクスチャの読み込みを開始します。
     */
    void    startLoadingTextures();

};


extern KRAnime2D*   gKRAnime2DInst;

