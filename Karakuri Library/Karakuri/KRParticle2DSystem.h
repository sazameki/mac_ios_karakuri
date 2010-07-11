/*!
    @file   KRParticle2DSystem.h
    @author numata
    @date   09/08/07
 
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/Karakuri.h>
#include "KRChara2D.h"


struct _KRParticle2DGenInfo {
    KRVector2D  centerPos;
    int         count;
};


const int _KRParticle2DGenMaxCount = 20;


class _KRParticle2D : public KRChara2D {
    
public:
    unsigned    mLife;
    unsigned    mBaseLife;
    KRVector2D  mPos;
    KRVector2D  mV;
    KRVector2D  mGravity;
    KRColor     mColor;
    double      mScale;
    double      mSize;
    double      mAngle;
    double      mAngleV;
    
    double      mDeltaScale;
    double      mDeltaSize;
    double      mDeltaRed;
    double      mDeltaGreen;
    double      mDeltaBlue;
    double      mDeltaAlpha;
    
public:
	_KRParticle2D(int charaSpecID, unsigned life, const KRVector2D& pos, const KRVector2D& v, const KRVector2D& gravity,
                  double angleV, const KRColor& color, double size, double scale,
                  double deltaRed, double deltaGreen, double deltaBlue, double deltaAlpha, double deltaSize, double deltaScale);
    ~_KRParticle2D();
    
public:
    bool    step();
    
public:
    virtual std::string to_s() const;

};

/*!
    @-class  _KRParticle2DSystem
    @group  Game Graphics
    @abstract 2次元の移動を行うパーティクル群を生成し管理するための仕組みです。
    火、爆発、煙、雲、霧などの表現に利用できます。
 */
class _KRParticle2DSystem : public KRObject {
    
    std::list<_KRParticle2D *>  mParticles;
    
    int             mGroupID;
    int             mZOrder;
    int             mCharaSpecID;

    unsigned        mLife;
    KRVector2D      mStartPos;
    
    _KRTexture2D     *mTexture;
    bool            mHasInnerTexture;
    
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
    double          mDeltaSize;
    double          mDeltaRed;
    double          mDeltaGreen;
    double          mDeltaBlue;
    double          mDeltaAlpha;
    
    bool            mDoLoop;
    _KRParticle2DGenInfo    mGenInfos[_KRParticle2DGenMaxCount];
    int             mActiveGenCount;

    double          mMinScale;
    double          mMaxScale;
    double          mMinSize;
    double          mMaxSize;
    
public:
    /*!
        @task コンストラクタ
     */
    
    _KRParticle2DSystem(int groupID, const std::string& imageFileName, int zOrder);
    
    _KRParticle2DSystem(int groupID, const std::string& ticket);
    
    /*!
        @method _KRParticle2DSystem
        @abstract テクスチャに使用する画像ファイルの名前を指定して、このパーティクル・システムを生成します。
        <p>デフォルトでは、addGenerationPoint() 関数を用いて、単発生成を行います。</p>
        <p>doLoop 引数に true を指定することで、パーティクルを無限に生成し続けるようになります。</p>
     */
    _KRParticle2DSystem(const std::string& filename, bool doLoop=false);

    /*!
        @method _KRParticle2DSystem
        @abstract テクスチャを指定して、このパーティクル・システムを生成します。
        <p>このコンストラクタを利用することにより、同じテクスチャを異なる複数のパーティクル・システムで共有して効率的に使うことができます。同じ画像でサイズが異なるパーティクルを生成したい場合などに、このコンストラクタを利用してください。</p>
        <p>デフォルトでは、addGenerationPoint() 関数を用いて、単発生成を行います。</p>
        <p>doLoop 引数に true を指定することで、パーティクルを無限に生成し続けるようになります。</p>
     */
    _KRParticle2DSystem(_KRTexture2D *texture, bool doLoop=false);
    virtual ~_KRParticle2DSystem();
    
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
    
    /*!
        @method setSizeDelta
        パーティクルの生存期間の割り合い（0.0〜1.0）に応じた、サイズの変化の割り合いを設定します。
     */
    void    setSizeDelta(double value);
    
    /*!
        @method setMaxSize
        各パーティクルの生成時の最大サイズを設定します。
     */
    void    setMaxSize(double size);
    
    void    setMaxScale(double scale);
    

    /*!
        @method setMinSize
        各パーティクルの生成時の最小サイズを設定します。
     */
    void    setMinSize(double size);    
    
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
        @method getDeltaSize
        @abstract パーティクルの生存期間の割り合い（0.0〜1.0）に応じたサイズの変化の割り合いを取得します。
     */
    double      getDeltaSize() const;
    
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
    /*!
        @method getMaxSize
        @abstract 各パーティクルの生成時の最大サイズを取得します。
     */
    double      getMaxSize() const;
    double      getMaxScale() const;
    
    /*!
        @method getMinSize
        @abstract 各パーティクルの生成時の最小サイズを取得します。
     */
    double      getMinSize() const;
    double      getMinScale() const;
    
public:
    virtual std::string to_s() const;

};


