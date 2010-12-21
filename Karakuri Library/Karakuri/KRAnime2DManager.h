/*!
    @file   KRAnime2DManager.h
    @author Satoshi Numata
    @date   10/01/11
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/Karakuri.h>

#include "KRChara2D.h"


class _KRParticle2DSystem;
class KRSimulator2D;


/*!
    @class KRAnime2DManager
    @group Game Graphics
    <p>Karakuri Box を利用して作成された 2D キャラクタのアニメーションを管理するためのクラスです。</p>
    <p><strong>このクラスのインスタンスには、グローバル変数 gKRAnime2DMan を使ってアクセス</strong>してください。</p>
 */
class KRAnime2DManager : public KRObject {

    std::map<int, _KRChara2DSpec*>  mCharaSpecMap;
    std::list<KRChara2D*>           mCharas;
    
    std::map<int, _KRParticle2DSystem*> mParticleSystemMap;
    std::map<int, KRSimulator2D*>       mSimulatorMap;
    
    int                             mNextInnerCharaSpecID;
    int                             mNextSimulatorID;

public:
	KRAnime2DManager(int maxChara2DCount, size_t maxChara2DSize);
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
        @-method _stepAllCharas
        すべてのキャラクタのアニメーションをステップ実行します。
     */
    void    _stepAllCharas();
    
    
#pragma mark ---- キャラクタの管理 ----

    /*!
        @task キャラクタの管理
     */

    /*!
        @-method _addCharaSpec
        @abstract キャラクタの ID を指定して、新しいキャラクタの特徴を追加します。
        追加されたキャラクタの特徴は、ゲーム終了時に自動的に delete されます。
     */
    void    _addCharaSpec(int specID, _KRChara2DSpec* spec);
    
    /*!
        @-method loadCharaSpecs
        @abstract ゲーム内で利用するキャラクタの特徴を、指定されたファイルから読み込みます。
        <p>キャラクタの特徴記述ファイルの仕様は、開発ガイドの「<a href="../../../../guide/2d_anime.html">2Dアニメーションの管理</a>」を参照してください。</p>
     */
    void    _loadCharaSpecs(const std::string& specFileName);
    
    /*
        @method addCharacterSpecs
        @abstract ゲーム内で利用するキャラクタの特徴ファイルを追加します。
        <p>キャラクタの特徴記述ファイルの仕様は、開発ガイドの「<a href="../../../../guide/2d_anime.html">2Dアニメーションの管理</a>」を参照してください。</p>
     */
    //void    addCharacterSpecs(int groupID, const std::string& specFileName);
    
    int     _addTexCharaSpec(int groupID, const std::string& imageFileName);
    int     _addTexCharaSpecWithTextureID(int groupID, int texID);
    

    _KRChara2DSpec* _getChara2DSpec(int specID);

    /*!
        @method addChara2D
        管理対象のキャラクタを追加します。いったん追加されたキャラクタは、自動的にメモリ管理が行われますので、delete しないようにしてください。
     */
    void        addChara2D(KRChara2D* aChara);
    
    /*!
        @method getChara2D
        @abstract 画面上の位置とクラスの種類を指定して、その位置に表示されているキャラクタを取得します。
        現在の拡大率が反映された状態で、現在のコマに設定されたテクスチャサイズに基づいて当たり判定が行われます。もっとも手前に表示されているキャラクタが取得されます。
     */
    KRChara2D*  getChara2D(int classType, const KRVector2D& pos) const;
    
    /*!
        @method hitChara2D
        @abstract クラスの種類、当たり判定の種類、画面上の位置を指定して、その位置に当たり判定をもつキャラクタを取得します。
        もっとも手前に表示されているキャラクタが取得されます。
     */
    KRChara2D*  hitChara2D(int classType, int hitType, const KRVector2D& pos) const;
    
    /*!
        @method hitChara2D
        @abstract 特定のクラスのキャラクタの特定の当たり判定の領域と、当たり判定の領域が重なっているキャラクタを取得します。
        もっとも手前に表示されているキャラクタが取得されます。
     */
    KRChara2D*  hitChara2D(int classType, int hitType, const KRChara2D* targetChara, int targetHitType) const;
    
    /*!
        @method playChara2D
        @abstract キャラクタアニメーションを再生するための、もっとも簡単な方法です。指定したキャラクタの特定の動作のアニメーションだけを、指定された位置で再生します。
        アニメーション完了後は、このアニメーションは自動的に削除されます。
     */
    void    playChara2D(int charaSpecID, int motionID, const KRVector2D& pos, int zOrder);

    /*!
        @method playChara2DCenter
        @abstract キャラクタアニメーションを再生するための、もっとも簡単な方法です。指定したキャラクタの特定の動作のアニメーションだけを、指定された中心位置で再生します。
        アニメーション完了後は、このアニメーションは自動的に削除されます。
     */
    void    playChara2DCenter(int charaSpecID, int motionID, const KRVector2D& centerPos, int zOrder);
    
    /*!
        @method removeAllCharas
        生成されたすべてのキャラクタを削除します。
     */
    void    removeAllCharas();
    
    /*!
        @method removeChara2D
        キャラクタを削除します。削除したキャラクタは即座に delete されますので、このメソッドの呼び出し後のタイミングでキャラクタオブジェクトに対する操作を行わないでください。
     */
    void    removeChara2D(KRChara2D* chara);

    void    _reorderChara2D(KRChara2D* chara);    KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY

    
#pragma mark ---- 2Dシミュレータの管理 ----

    int     addSimulator(const KRVector2D& gravity);
    void    putCharaInSimulator(KRChara2D* aChara, int simulatorID);
    

#pragma mark ---- パーティクルの管理 ----

    /*!
        @task パーティクルの管理
     */

    
    /*
        @-method _addParticle2DWithTextureID
        @abstract 2次元の移動を行うパーティクル管理のシステムを生成します。火、爆発、煙、雲、霧などの表現に利用できます。
     */
    void    _addParticle2DWithTextureID(int groupID, int resourceID, int texID);
    
    _KRParticle2DSystem*    _getParticleSystem(int particleID) const;

    /*!
        @method generateParticle2D
        指定された座標に、新しいパーティクルを生成します。
     */
    void    generateParticle2D(int particleID, const KRVector2D& pos, int zOrder = 0);
    
    void    _stepParticles();

};


/*!
    @var    gKRAnime2DMan
    @group  Game Graphics
    @abstract 2Dアニメーション管理機構のインスタンスを指す変数です。
    この変数が指し示すオブジェクトは、ゲーム実行の最初から最後まで絶対に変わりません。
 */
extern KRAnime2DManager*    gKRAnime2DMan;


