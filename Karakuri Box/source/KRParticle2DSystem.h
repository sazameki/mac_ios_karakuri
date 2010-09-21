/*!
    @file   KRParticle2DSystem.h
    @author numata
    @date   09/08/07
 
    Please write the description of this class.
 */

#pragma once

#include "KarakuriTypes.h"
#include "KRColor.h"
#include "KRTexture2D.h"
#include "KRGraphics.h"
#include <list>


struct _KRParticle2DGenInfo {
    KRVector2D  centerPos;
    int         count;
};


const int _KRParticle2DGenMaxCount = 20;


class _KRParticle2D : public KRObject {
    
public:
    unsigned    mLife;
    unsigned    mBaseLife;
    KRVector2D  mPos;
    KRVector2D  mV;
    KRVector2D  mGravity;
    KRColor     mColor;
    double      mScale;
    double      mAngle;
    double      mAngleV;
    
    double      mDeltaScale;
    double      mDeltaRed;
    double      mDeltaGreen;
    double      mDeltaBlue;
    double      mDeltaAlpha;
    
public:
	_KRParticle2D(unsigned life, const KRVector2D& pos, const KRVector2D& v, const KRVector2D& gravity,
                  double angleV, const KRColor& color, double scale,
                  double deltaRed, double deltaGreen, double deltaBlue, double deltaAlpha, double deltaScale);
    ~_KRParticle2D();
    
public:
    bool    step();
    
public:
    virtual std::string to_s() const;

};

/*!
    @-class  KRParticle2DSystem
    @group  Game 2D Graphics
    @abstract 2次元の移動を行うパーティクル群を生成し管理するための仕組みです。
    火、爆発、煙、雲、霧などの表現に利用できます。
 */
class KRParticle2DSystem {
    
    std::list<_KRParticle2D *>  mParticles;
    
    unsigned        mLife;
    KRVector2D      mStartPos;
    
    KRTexture2D     *mTexture;
    
    KRVector2D      mMinV;
    KRVector2D      mMaxV;
    KRVector2D      mGravity;
    
    double          mMinAngleV;
    double          mMaxAngleV;
    
    unsigned        mParticleCount;
    int             mGenerateCount;
    
    KRBlendMode     mBlendMode;
    
    KRColor         mColor;
    double          mDeltaScale;
    double          mDeltaRed;
    double          mDeltaGreen;
    double          mDeltaBlue;
    double          mDeltaAlpha;
    
    _KRParticle2DGenInfo    mGenInfos[_KRParticle2DGenMaxCount];
    int             mActiveGenCount;

    double          mMinScale;
    double          mMaxScale;
    
public:
    /*!
        @task コンストラクタ
     */

    /*!
        @method KRParticle2DSystem
        @abstract テクスチャに使用する画像ファイルの名前を指定して、このパーティクル・システムを生成します。
        <p>デフォルトでは、addGenerationPoint() 関数を用いて、単発生成を行います。</p>
     */
    KRParticle2DSystem(const std::string& filename);
    KRParticle2DSystem(int imageTag, std::string& customPath, void* document);

    virtual ~KRParticle2DSystem();
    
private:
    void    init();
    
public:
    /*!
        @task 実行のための関数
     */
    
    /*!
        @method draw
        このパーティクル・システムで生成されたすべてのパーティクルを描画します。
     */
    void    draw();
    
    /*!
        @method step
        設定に基づいて必要なパーティクルを生成し、生成されたすべてのパーティクルを動かします。基本的に、1フレームに1回この関数を呼び出してください。
     */
    void    step();

public:
    /*!
        @task ループ実行のための関数
     */
    
    /*!
        @method getStartPos
        ループ実行時のパーティクルの生成時の位置を取得します。
     */
    KRVector2D  getStartPos() const;
    
    /*!
        @method setStartPos
        ループ実行時のパーティクルの生成時の位置を設定します。
     */
    void    setStartPos(const KRVector2D& pos);
    
public:
    /*!
        @task 単発実行のための関数
     */
    
    /*!
        @method addGenerationPoint
        @abstract 新しいパーティクル生成ポイントを指定された座標に追加します。
        setParticleCount() 関数で設定された最大個数だけパーティクルを生成した時点で、その生成ポイントは削除されます。
     */
    void    addGenerationPoint(const KRVector2D& pos);

public:
    /*!
        @task 設定のための関数
     */

    /*!
        @method setBlendMode
        @abstract パーティクルを描画するためのブレンドモードを設定します。
        デフォルトのブレンドモードは、KRBlendModeAddition に設定されています。
     */
    void    setBlendMode(KRBlendMode blendMode);
    
    /*!
        @method setColor
        パーティクル描画時に適用される初期カラーを設定します。
     */
    void    setColor(const KRColor& color);
    
    /*!
        @method setColorDelta
        パーティクルの生存期間の割り合い（0.0〜1.0）に応じた、各色成分の変化の割り合いを設定します。
     */
    void    setColorDelta(double red, double green, double blue, double alpha);
    
    /*!
        @method setGenerateCount
        @abstract 1フレーム（1回の step() 関数呼び出し）ごとのパーティクルの最大生成個数を設定します。
        マイナスの値を設定すると、それ以降パーティクルは生成されなくなります。
     */
    void    setGenerateCount(int count);
    
    /*!
        @method setGravity
        @abstract 各パーティクルの1フレーム（1回の step() 関数呼び出し）ごとに適用される加速度を設定します。
        デフォルトでは加速度は (0.0, 0.0) に設定されています。
     */
    void    setGravity(const KRVector2D& a);
    
    /*!
        @method setLife
        @abstract 各パーティクルの生存期間を設定します。
        既に生成されているパーティクルには影響を及ぼしません。デフォルトの生存期間は、60フレーム（=1秒）です。
     */
    void    setLife(unsigned life);
    
    /*!
        @method setMaxAngleV
        @abstract パーティクル生成時にランダムで設定される角速度の最大値を設定します。
     */
    void    setMaxAngleV(double angleV);
    
    /*!
        @method setMaxV
        @abstract パーティクル生成時にランダムで設定される移動速度の最大値を設定します。
     */
    void    setMaxV(const KRVector2D& v);

    /*!
        @method setMinAngleV
        @abstract パーティクル生成時にランダムで設定される角速度の最小値を設定します。
     */
    void    setMinAngleV(double angleV);

    /*!
        @method setMinV
        @abstract パーティクル生成時にランダムで設定される移動速度の最小値を設定します。
     */
    void    setMinV(const KRVector2D& v);
    
    /*!
        @method setParticleCount
        @abstract パーティクルの最大個数を設定します。
        デフォルトの設定では256個です。
     */
    void    setParticleCount(unsigned count);
    
    void    setScaleDelta(double value);
    
    void    setMaxScale(double scale);
    
    
    void    setMinScale(double scale);

public:
    /*!
        @task 現在の設定確認のための関数
     */
    
    /*!
        @method getBlendMode
        @abstract パーティクルを描画するためのブレンドモードを取得します。
     */
    KRBlendMode getBlendMode() const;
    
    /*!
        @method getColor
        @abstract パーティクル描画時に適用される初期カラーを取得します。
     */
    KRColor     getColor() const;

    /*!
        @method getDeltaAlpha
        @abstract パーティクルの生存期間の割り合い（0.0〜1.0）に応じたアルファ成分の変化の割り合いを取得します。
     */
    double      getDeltaAlpha() const;

    /*!
        @method getDeltaBlue
        @abstract パーティクルの生存期間の割り合い（0.0〜1.0）に応じた青成分の変化の割り合いを取得します。
     */
    double      getDeltaBlue() const;

    /*!
        @method getDeltaGreen
        @abstract パーティクルの生存期間の割り合い（0.0〜1.0）に応じた緑成分の変化の割り合いを取得します。
     */
    double      getDeltaGreen() const;

    /*!
        @method getDeltaRed
        @abstract パーティクルの生存期間の割り合い（0.0〜1.0）に応じた赤成分の変化の割り合いを取得します。
     */
    double      getDeltaRed() const;
    
    double      getDeltaScale() const;
    
    /*!
        @method getGenerateCount
        @abstract 1フレーム（1回の step() 関数呼び出し）ごとのパーティクルの最大生成個数を取得します。
     */
    int         getGenerateCount() const;
    
    /*!
        @method getGeneratedParticleCount
        @abstract 現時点で生成されているパーティクルの個数を取得します。
     */
    unsigned    getGeneratedParticleCount() const;
    
    /*!
        @method getGravity
        @abstract 各パーティクルの1フレーム（1回の step() 関数呼び出し）ごとに適用される加速度を取得します。
     */
    KRVector2D  getGravity() const;
    
    /*!
        @method getLife
        @abstract 各パーティクルの生存期間を取得します。
     */
    unsigned    getLife() const;
    
    double      getMaxAngleV() const;
    double      getMinAngleV() const;
    
    /*!
        @method getMaxV
        @abstract パーティクル生成時にランダムで設定される移動速度の最大値を取得します。
     */
    KRVector2D  getMaxV() const;
    
    /*!
        @method getMinV
        @abstract パーティクル生成時にランダムで設定される移動速度の最小値を取得します。
     */
    KRVector2D  getMinV() const;
    
    /*!
        @method getParticleCount
        @abstract パーティクルの最大個数を取得します。
     */
    unsigned    getParticleCount() const;
    
public:
    double      getMaxScale() const;
    double      getMinScale() const;

};


