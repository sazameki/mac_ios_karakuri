/*!
    @file   KRSimulator2DJoint.h
    @author numata
    @date   09/08/12
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>


class KRShape2D;
class KRSimulator2D;


/*!
    @class KRJoint2D
    @group Game 2D Simulator
    @abstract 図形と図形、あるいは図形とシミュレータの場を、何らかの方法で結合させるための基底クラスです。
    このクラスは、直接 new することはできません。
 */
class KRJoint2D : public KRObject {
    
private:
    void    *mRepresentedObject;
    int     mTag;
    
protected:
    void    *mConstraint;

    KRShape2D   *mShape1;
    KRShape2D   *mShape2;
    KRVector2D  mAnchor1;
    KRVector2D  mAnchor2;
    bool        mIsStatic;
    
    KRSimulator2D   *mSimulator;

protected:
    bool        mIsRemovedFromSpace;

protected:
    KRJoint2D(KRShape2D *shape, const KRVector2D& anchor, const KRVector2D& staticAnchor);
    KRJoint2D(KRShape2D *shape1, const KRVector2D& anchor1,  KRShape2D *shape2, const KRVector2D& anchor2);
	virtual ~KRJoint2D();

public:
    /*!
        @task 状態管理のための関数
     */
    
    /*!
        @method getAnchor1
        @abstract このジョイントが結合している1つ目の図形における結合点の座標を取得します。
        この座標はローカル座標です。
     */
    KRVector2D  getAnchor1() const;

    /*!
        @method getAnchor2
        @abstract このジョイントが結合している2つ目の図形における結合点の座標を取得します。
        この座標はローカル座標です。
     */
    KRVector2D  getAnchor2() const;
    
    /*!
        @method getShape1
        このジョイントが結合している1つ目の図形を取得します。
     */
    KRShape2D   *getShape1() const;

    /*!
        @method getShape2
        このジョイントが結合している2つ目の図形を取得します。
     */
    KRShape2D   *getShape2() const;

    /*!
        @method getSimulator
        このジョイントが追加されているシミュレータを取得します。
     */
    KRSimulator2D   *getSimulator() const;

    /*!
        @method isStatic
        このジョイントが場に対して設定されたものかどうかをリターンします。
     */
    bool        isStatic() const;

public:
    /*!
        @task 関連情報の管理のための関数
     */
    
    /*!
        @method getRepresentedObject
        このジョイントに関連付けて管理しているオブジェクトのポインタを取得します。
     */
    void    *getRepresentedObject() const;

    /*!
        @method getTag
        @abstract このジョイントに付加された int 型の数値情報を取得します。
        デフォルトではこの値は 0 に設定されています。
     */
    int     getTag() const;
    
    /*!
        @method setRepresentedObject
        このジョイントに関連付けて管理するオブジェクトのポインタを指定します。
     */
    void    setRepresentedObject(float *anObj);

    /*!
        @method setTag
        このジョイントに int 型の数値情報を付加します。
     */
    void    setTag(int tag);


public:
    virtual void    addToSimulator(KRSimulator2D *simulator) = 0 KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    virtual void    removeFromSimulator() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

public:
    virtual std::string to_s() const;

};


/*!
    @class KRJoint2DPivot
    @group Game 2D Simulator
    図形と図形、あるいは図形と場を、1点を軸にして結合させるためのクラスです。
 */
class KRJoint2DPivot : public KRJoint2D {
    
public:
    /*!
        @method KRJoint2DPivot
        @abstract シミュレータの場と図形を結合させるための結合部を作成します。
        anchor は shape のローカル座標であり、staticAnchor はワールド座標であることに注意してください。
     */
    KRJoint2DPivot(KRShape2D *shape, const KRVector2D& anchor, const KRVector2D& staticAnchor);

    /*!
        @method KRJoint2DPivot
        @abstract 2つの図形を結合させるための結合部を作成します。
        anchor1 は shape1 の、anchor2 は shape2 のローカル座標であることに注意してください。
     */
	KRJoint2DPivot(KRShape2D *shape1, const KRVector2D& anchor1,  KRShape2D *shape2, const KRVector2D& anchor2);

public:
    virtual void    addToSimulator(KRSimulator2D *simulator) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

public:
    virtual std::string to_s() const;

};


/*!
    @class KRJoint2DSpring
    @group Game 2D Simulator
    図形と図形、あるいは図形と場を、バネで結合させるためのクラスです。
 */
class KRJoint2DSpring : public KRJoint2D {

    float       mDamping;
    float       mRestLength;
    float       mStiffness;
    
public:
    /*!
        @task コンストラクタ
     */
    
    /*!
        @method KRJoint2DSpring
        @abstract シミュレータの場と図形を結合させるためのバネを作成します。
        anchor は shape のローカル座標であり、staticAnchor はワールド座標であることに注意してください。
     */
	KRJoint2DSpring(KRShape2D *shape, const KRVector2D& anchor, const KRVector2D& staticAnchor);
    
    /*!
        @method KRJoint2DSpring
        @abstract 2つの図形を結合させるためのバネを作成します。
        anchor1 は shape1 の、anchor2 は shape2 のローカル座標であることに注意してください。
     */
	KRJoint2DSpring(KRShape2D *shape1, const KRVector2D& anchor1,  KRShape2D *shape2, const KRVector2D& anchor2);

	virtual ~KRJoint2DSpring();
    
public:
    /*!
        @task 条件取得のための関数
     */
    
    /*!
        @method getDamping
        バネの振幅の減衰度を取得します。
     */
    float   getDamping() const;
    
    /*!
        @method getRestLength
        バネの最小の長さを取得します。
     */
    float   getRestLength() const;

    /*!
        @method getStiffness
        バネの強度を取得します。
     */
    float   getStiffness() const;
    
public:
    /*!
        @task 条件設定のための関数
     */
    
    /*!
        @method setDamping
        バネの振幅の減衰度を設定します。
     */
    void    setDamping(float value);
    
    /*!
        @method setRestLength
        バネの最小の長さを設定します。
     */
    void    setRestLength(float value);
    
    /*!
        @method setStiffness
        バネの強度を設定します。
     */
    void    setStiffness(float value);

public:
    virtual void    addToSimulator(KRSimulator2D *simulator) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

public:
    virtual std::string to_s() const;

};



