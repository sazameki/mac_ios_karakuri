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
    @group Game 2D Graphics
    <p>キャラクタのアニメーションを管理するためのクラスです。</p>
    <p>このクラスのオブジェクトには、gKRAnime2DMan 変数を使ってアクセスしてください。</p>
    <p>主な使い方は、「<a href="../../../../guide/2d_anime.html">2Dアニメーションの管理</a>」を参照してください。</p>
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
    void    _addCharaSpec(int specID, _KRChara2DSpec *spec);
    
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
    int     _addTexCharaSpecWithTicket(int groupID, const std::string& ticket);
    

    _KRChara2DSpec* _getChara2DSpec(int specID);

    /*!
        @method addChara2D
        管理対象のキャラクタを追加します。
     */
    void        addChara2D(KRChara2D* aChara);
    
    /*!
        @method getChara2D
        @abstract 画面上の位置とクラスの種類を指定して、その位置に表示されているキャラクタを取得します。
        もっとも手前に表示されているキャラクタが取得されます。
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

    
    /*
        @-method _addParticle2D
        @abstract 2次元の移動を行うパーティクル管理のシステムを生成します。火、爆発、煙、雲、霧などの表現に利用できます。
     */
    int     _addParticle2D(int groupID, const std::string& imageFileName);
    
    void    _addParticle2DWithTicket(int resourceID, int groupID, const std::string& imageTicket);
    
    _KRParticle2DSystem*    _getParticleSystem(int particleID) const;

    /*!
        @method generateParticle2D
        指定された座標に、新しいパーティクルを生成します。
     */
    void    generateParticle2D(int particleID, const KRVector2D& pos);
    
    void    _stepParticles();
    
    /*!
        @task パーティクルの管理
     */
    
    /*!
        @method getParticle2DBlendMode
        @abstract IDを指定して、パーティクル描画時のブレンドモードを取得します。
     */
    KRBlendMode     getParticle2DBlendMode(int particleID) const;

    /*!
     @method setParticle2DBlendMode
     @abstract IDを指定して、パーティクル描画時のブレンドモードを設定します。
     */
    void    setParticle2DBlendMode(int particleID, KRBlendMode blendMode);

    /*
        @method _getParticle2DColor
        @abstract IDを指定して、パーティクル描画の基本色を取得します。
     */
    //KRColor         _getParticle2DColor(int particleID) const;

    /*
        @method _getParticle2DCount
        @abstract IDを指定して、現在までに生成されたパーティクルの個数を取得します。
     */
    //int             _getParticle2DCount(int particleID) const;

    /*
        @method _getParticle2DAlphaDelta
        @abstract IDを指定して、パーティクルのアルファ値の変化量を取得します。
     */
    //double          _getParticle2DAlphaDelta(int particleID) const;

    /*
        @method _getParticle2DBlueDelta
        @abstract IDを指定して、パーティクルの青成分の変化量を取得します。
     */
    //double          _getParticle2DBlueDelta(int particleID) const;

    /*
        @method _getParticle2DGreenDelta
        @abstract IDを指定して、パーティクルの緑成分の変化量を取得します。
     */
    //double          _getParticle2DGreenDelta(int particleID) const;

    /*
        @method _getParticle2DRedDelta
        @abstract IDを指定して、パーティクルの赤成分の変化量を取得します。
     */
    //double          _getParticle2DRedDelta(int particleID) const;

    /*
        @method _getParticle2DScaleDelta
        @abstract IDを指定して、拡大率の変化量を取得します。
     */
    //double          _getParticle2DScaleDelta(int particleID) const;

    /*
        @method _getParticle2DGenerateCount
        @abstract IDを指定して、1フレームあたりのパーティクルの生成量を取得します。
     */
    //int             _getParticle2DGenerateCount(int particleID) const;

    /*
        @method _getParticle2DGravity
        @abstract IDを指定して、パーティクルに設定される重力を取得します。
     */
    //KRVector2D      _getParticle2DGravity(int particleID) const;

    /*
        @method _getParticle2DLife
        @abstract IDを指定して、パーティクルに設定される生存期間（フレーム単位）を取得します。
     */
    //int             _getParticle2DLife(int particleID) const;

    /*
        @method getParticle2DMaxAngleV
        @abstract IDを指定して、パーティクルに設定される回転の最大の角速度を設定します。
        回転の角速度は、生成時に設定の範囲内でランダムに設定されます。
     */
    //double          _getParticle2DMaxAngleV(int particleID) const;

    /*
        @method _getParticle2DMaxCount
        @abstract IDを指定して、パーティクルの最大生成量を設定します。
     */
    //int             _getParticle2DMaxCount(int particleID) const;

    /*
        @method _getParticle2DMaxScale
        @abstract IDを指定して、パーティクルに設定される最大の拡大率を設定します。
        拡大率は、生成時に設定の範囲内でランダムに設定されます。
     */
    //double          _getParticle2DMaxScale(int particleID) const;

    /*
        @method _getParticle2DMaxV
        @abstract IDを指定して、パーティクルに設定される最大の速度を設定します。
        速度は、生成時に設定の範囲内でランダムに設定されます。
     */
    //KRVector2D      _getParticle2DMaxV(int particleID) const;

    /*
        @method _getParticle2DMinAngleV
        @abstract IDを指定して、パーティクルに設定される回転の最小の角速度を設定します。
        回転の角速度は、生成時に設定の範囲内でランダムに設定されます。
     */
    //double          _getParticle2DMinAngleV(int particleID) const;

    /*
        @method _getParticle2DMinScale
        @abstract IDを指定して、パーティクルに設定される最小の拡大率を設定します。
        拡大率は、生成時に設定の範囲内でランダムに設定されます。
     */
    //double          _getParticle2DMinScale(int particleID) const;

    /*
        @method _getParticle2DMinV
        @abstract IDを指定して、パーティクルに設定される最小の速度を設定します。
        速度は、生成時に設定の範囲内でランダムに設定されます。
     */
    //KRVector2D      _getParticle2DMinV(int particleID) const;

    /*
        @method _setParticle2DColor
        @abstract IDを指定して、パーティクル描画の基本色を設定します。
     */
    //void    _setParticle2DColor(int particleID, const KRColor& color);

    /*
        @method _setParticle2DColorDelta
        @abstract IDを指定して、パーティクルの色の変化量を設定します。
     */
    //void    _setParticle2DColorDelta(int particleID, double red, double green, double blue, double alpha);

    /*
        @method _setParticle2DGenerateCount
        @abstract IDを指定して、1フレームあたりのパーティクルの生成量を設定します。
     */
    //void    _setParticle2DGenerateCount(int particleID, int count);

    /*
        @method _setParticle2DGravity
        @abstract IDを指定して、パーティクルに設定される重力を設定します。
     */
    //void    _setParticle2DGravity(int particleID, const KRVector2D& a);

    /*
        @method _setParticle2DLife
        @abstract IDを指定して、パーティクルに設定される生存期間（フレーム単位）を設定します。
     */
    //void    _setParticle2DLife(int particleID, unsigned life);

    /*
        @method _setParticle2DMaxAngleV
        @abstract IDを指定して、パーティクルに設定される回転の最大の角速度を設定します。
        回転の角速度は、生成時に設定の範囲内でランダムに設定されます。
     */
    //void    _setParticle2DMaxAngleV(int particleID, double angleV);

    /*
        @method _setParticle2DMaxCount
        @abstract IDを指定して、パーティクルの最大の生成数を設定します。
     */
    //void    _setParticle2DMaxCount(int particleID, unsigned count);

    /*
        @method _setParticle2DMaxScale
        @abstract IDを指定して、パーティクルに設定される最大の拡大率を設定します。
        拡大率は、生成時に設定の範囲内でランダムに設定されます。
     */
    //void    _setParticle2DMaxScale(int particleID, double scale);

    /*
        @method _setParticle2DMaxV
        @abstract IDを指定して、パーティクルに設定される最大の速度を設定します。
        速度は、生成時に設定の範囲内でランダムに設定されます。
     */
    //void    _setParticle2DMaxV(int particleID, const KRVector2D& v);

    /*
        @method _setParticle2DMinAngleV
        @abstract IDを指定して、パーティクルに設定される回転の最小の角速度を設定します。
        回転の角速度は、生成時に設定の範囲内でランダムに設定されます。
     */
    //void    _setParticle2DMinAngleV(int particleID, double angleV);

    /*
        @method _setParticle2DMinScale
        @abstract IDを指定して、パーティクルに設定される最小の拡大率を設定します。
        拡大率は、生成時に設定の範囲内でランダムに設定されます。
     */
    //void    _setParticle2DMinScale(int particleID, double scale);

    /*
        @method _setParticle2DMinV
        @abstract IDを指定して、パーティクルに設定される最小の速度を設定します。
        速度は、生成時に設定の範囲内でランダムに設定されます。
     */
    //void    _setParticle2DMinV(int particleID, const KRVector2D& v);

    /*
        @method _setParticle2DScaleDelta
        @abstract IDを指定して、パーティクルに設定される拡大率の変化量を設定します。
        拡大率は、生成時に設定の範囲内でランダムに設定されます。
     */
    //void    _setParticle2DScaleDelta(int particleID, double value);

};


/*!
    @var    gKRAnime2DMan
    @group  Game 2D Graphics
    @abstract 2Dアニメーション管理機構のインスタンスを指す変数です。
    この変数が指し示すオブジェクトは、ゲーム実行の最初から最後まで絶対に変わりません。
 */
extern KRAnime2DManager*    gKRAnime2DMan;


