/*!
    @file   KRSimulator2DShape.h
    @author numata
    @date   09/08/12
    
    Please write the description of this class.
 */

#pragma once


#include <Karakuri/KarakuriLibrary.h>


#define GRABABLE_MASK_BIT (1 << 31)
#define NOT_GRABABLE_MASK (~GRABABLE_MASK_BIT)


class KRSimulator2D;


/*!
    @class KRShape2D
    @group Game 2D Simulator
    KRSimulator2D クラスで管理される図形を表すための基底クラスです。このクラスは、直接 new することはできません。
 */
class KRShape2D : public KRObject {
    
protected:
    void    *mCPBody;
    void    *mCPShape;
    bool    mIsStatic;
    double  mMass;
    double  mElasticity;
    double  mFriction;
    KRVector2D  mCenterPos;
    
    KRSimulator2D   *mSimulator;
    
    unsigned    mCollisionID;

private:
    void    *mRepresentedObject;
    int     mTag;

protected:
    bool    mIsRemovedFromSpace;

protected:
    KRShape2D();
    virtual ~KRShape2D();
    
public:
    /*!
        @task 図形の状態取得のための関数
     */

    /*!
        @method getAngle
        現在の角度を取得します。
     */
    double      getAngle() const;
    
    /*!
        @method getAngleVelocity
        現在の角速度を取得します。
     */
    double      getAngleVelocity() const;
    
    /*!
        @method getCenterPos
        現在の中心位置を取得します。
     */
    KRVector2D  getCenterPos() const;
    
    /*!
        @method getSimulator
        この図形が追加されているシミュレータを取得します。
     */
    KRSimulator2D   *getSimulator() const;
    
    /*!
        @method getVelocity
        現在の移動速度を取得します。
     */
    KRVector2D  getVelocity() const;
    
    /*!
        @method isStatic
        この図形が動かない図形かどうかをリターンします。
     */
    bool    isStatic() const;
    
    /*!
        @task 図形の設定管理のための関数
     */
    
    /*!
        @method setAngle
        この図形の角度を設定します。
     */
    void    setAngle(double angle);
    
    /*!
        @method setAngleVelocity
        この図形の角速度を設定します。
     */
    void    setAngleVelocity(double w);
    
    /*!
        @method setCenterPos
        この図形の中心点の位置を設定します。
     */
    void    setCenterPos(const KRVector2D& pos);
    
    /*!
        @method setElasticity
        この図形の弾力を設定します。
     */
    void    setElasticity(double value);
    
    /*!
        @method setFriction
        この図形の摩擦を設定します。
     */
    void    setFriction(double value);
    
    /*!
        @method setMass
        この図形の質量を設定します。
     */
    void    setMass(double value);
    
    /*!
        @method setVelocity
        この図形の移動速度を設定します。
     */
    void    setVelocity(const KRVector2D& v);
    
    
    /*!
        @task 関連情報の管理のための関数
     */
    
    /*!
        @method getRepresentedObject
        この図形に関連付けて管理しているオブジェクトのポインタを取得します。
     */
    void    *getRepresentedObject() const;
    
    /*!
        @method getTag
        @abstract この図形に付加された int 型の数値情報を取得します。
        デフォルトではこの値は 0 に設定されています。
     */
    int     getTag() const;
    
    /*!
        @method setRepresentedObject
        この図形に関連付けて管理するオブジェクトのポインタを指定します。
     */
    void    setRepresentedObject(void *anObj);
    
    /*!
        @method setTag
        この図形に int 型の数値情報を付加します。
     */
    void    setTag(int tag);
    
    /*!
        @task 衝突判定のための関数
     */
    
    /*!
        @method getCollisionID
        この図形に設定された衝突検出IDを取得します。
     */
    unsigned    getCollisionID() const;
    
    /*!
        @method setCollisionID
        @abstract この図形に任意の衝突検出IDを設定します。
        初期設定の衝突検出IDは 0 です。
     */
    void        setCollisionID(unsigned theID);
    
protected:
    void    setStatic(bool flag);

public:
    virtual void    addToSimulator(KRSimulator2D *simulator) = 0 KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    virtual void    removeFromSimulator() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    
    void    *getCPBody() const KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

public:
    virtual std::string to_s() const;

};

/*!
    @class KRShape2DLine
    @group Game 2D Simulator
    KRSimulator2D クラスで扱う線分の図形を表すためのクラスです。
 */
class KRShape2DLine : public KRShape2D {
    
    KRVector2D  mP1;
    KRVector2D  mP2;
    double      mLineWidth;
    
public:
    /*!
        @task コンストラクタ
     */
    
    /*!
        @method KRShape2DLine
        @abstract 始点と終点の位置を設定して、この図形を初期化します。
        isStatic 引数を true に指定することで、他の図形に影響を与えても自分は影響を受けない static な図形を作成することができます。
     */
    KRShape2DLine(const KRVector2D& p1, const KRVector2D& p2, bool isStatic=false);

    /*!
        @task 状態の設定
     */    

public:
    /*!
        @method getP1
        この線分の始点の現在位置を取得します。
     */
    KRVector2D  getP1() const;

    /*!
        @method getP2
     この線分の終点の現在位置を取得します。
     */
    KRVector2D  getP2() const;    
    
public:
    /*!
        @method setLineWidth
        @abstract この線分の線幅を設定します。
        この関数は、KRSimulator2D クラスのインスタンスに図形を追加するよりも前に呼び出してください。デフォルトの線幅は 0.0 に指定されています。
     */
    void    setLineWidth(double width);
    
public:
    virtual void    addToSimulator(KRSimulator2D *simulator) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

public:
    virtual std::string to_s() const;

};


/*!
    @class KRShape2DPoly
    @group Game 2D Simulator
    KRSimulator2D クラスで扱う多角形の図形を表すためのクラスです。
 */
class KRShape2DPoly : public KRShape2D {
    
protected:
    int         mVertexCount;
    KRVector2D  *mVertices;

public:
    /*!
        @task コンストラクタ
     */

    /*!
        @method KRShape2DPoly
        @abstract 頂点の個数と頂点のデータと中心点の位置を指定して、この図形を初期化します。
        isStatic 引数を true に指定することで、他の図形に影響を与えても自分は影響を受けない static な図形を作成することができます。
     */
    KRShape2DPoly(int vertexCount, KRVector2D *verts, const KRVector2D& pos, bool isStatic=false);
    virtual ~KRShape2DPoly();
    
protected:
    KRShape2DPoly();

public:
    /*!
        @task 状態の取得関数
     */
    
    /*!
        @method getVertexCount
        この図形に設定された頂点データの個数をリターンします。
     */
    int         getVertexCount() const;
    
    /*!
        @method getVertices
        @abstract この図形のすべての頂点データの現在位置を、与えられた vertices 配列に設定します。
        この配列は、すべての頂点データを格納するための十分なサイズをもっている必要があります。
     */
    void        getVertices(KRVector2D *vertices) const;
    
public:
    virtual void    addToSimulator(KRSimulator2D *simulator) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

public:
    virtual std::string to_s() const;

};


/*!
    @class KRShape2DBox
    @group Game 2D Simulator
    KRSimulator2D クラスで扱う四角形の図形を表すためのクラスです。
 */
class KRShape2DBox : public KRShape2DPoly {
    
public:
    /*!
        @method KRShape2DBox
        @abstract 矩形情報を設定して、この図形を初期化します。
        isStatic 引数を true に指定することで、他の図形に影響を与えても自分は影響を受けない static な図形を作成することができます。
     */
    KRShape2DBox(const KRRect2D& rect, bool isStatic=false);
    
public:
    virtual std::string to_s() const;

};

/*!
    @class KRShape2DCircle
    @group Game 2D Simulator
    KRSimulator2D クラスで扱う円（正円）の図形を表すためのクラスです。
 */
class KRShape2DCircle : public KRShape2D {
    
protected:
    double          mRadius;

public:
    /*!
        @method KRShape2DCircle
        @abstract 中心位置と半径の長さを設定して、この図形を初期化します。
        isStatic 引数を true に指定することで、他の図形に影響を与えても自分は影響を受けない static な図形を作成することができます。
     */
    KRShape2DCircle(const KRVector2D& centerPos, double radius, bool isStatic=false);
    
public:
    virtual void    addToSimulator(KRSimulator2D *simulator) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

public:
    virtual std::string to_s() const;

};


