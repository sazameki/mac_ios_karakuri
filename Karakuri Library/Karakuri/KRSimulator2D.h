/*!
    @file   KRSimulator2D.h
    @author numata
    @date   09/08/12
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>
#include <Karakuri/KRSimulator2DShape.h>
#include <Karakuri/KRSimulator2DJoint.h>
#include <Karakuri/KRSimulator2DCollision.h>


/*!
    @class KRSimulator2D
    @group Game 2D Simulator
    円や四角などの図形に対して、2次元の物理シミュレーションを行うためのクラスです。
 */
class KRSimulator2D : public KRObject {

public:
    static void initSimulatorSystem();  KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY

private:
    void*       mCPSpace;
    void*       mCPStaticBody;
    double      mNextAngle;
    bool        mHasChangedAngle;
    KRVector2D  mGravity;
    std::list<KRShape2D*>           mShapes;
    std::list<KRJoint2D*>           mJoints;
    std::list<KRCollisionInfo2D>    mCollisions;

public:
    /*!
        @task コンストラクタ
     */

    /*!
        @method KRSimulator2D
        重力を設定して、このシミュレータを作成します。
     */
	KRSimulator2D(const KRVector2D& gravity);

	virtual ~KRSimulator2D();
    
public:
    /*!
        @task 実行に関する関数
     */
    
    /*!
        @method step
        シミュレータを1フレーム（=1秒/設定されたフレームレート）分ステップ実行します。
     */
    void    step();

    /*!
        @method step
        シミュレータを秒数を指定してステップ実行します。
     */
    void    step(double time);

public:
    /*!
        @task 図形管理のための関数
     */
    
    /*!
        @method addShape
        @abstract 新しい図形をシミュレータに追加します。
        追加された図形は、自動的に解放されることはありません。
     */
    
    void    addShape(KRShape2D* aShape);

    /*!
        @method getAllShapes
        このシミュレータに追加されたすべての図形をリターンします。
     */
    std::list<KRShape2D*>*  getAllShapes();

    /*!
        @method getShape
        指定された位置にある図形を取得します。
     */
    KRShape2D*  getShape(const KRVector2D& pos) const;

    /*!
        @method removeShape
        指定された図形をシミュレータから取り除きます。
     */
    void    removeShape(KRShape2D* aShape);    

    /*!
        @task      ジョイント管理のための関数
     */

    /*!
        @method addJoint
        @abstract 新しいジョイントをシミュレータに追加します。
        追加されたジョイントは、自動的に解放されることはありません。
     */
    void    addJoint(KRJoint2D* aJoint);
    
    /*!
        @method getAllJoints
        このシミュレータに追加されたすべてのジョイントをリターンします。
     */
    std::list<KRJoint2D*>*  getAllJoints();
    
    /*!
        @method removeJoint
        @abstract 指定されたジョイントをシミュレータから取り除きます。
     */
    void    removeJoint(KRJoint2D* aJoint);

    /*!
        @task 設定のための関数
     */

    /*!
        @method getBodyAngle
        @abstract 現在のボディの角度を取得します。
     */
    double  getBodyAngle() const;

    /*!
        @method getGravity
        このシミュレータの現在の重力を取得します。
     */
    KRVector2D  getGravity() const;
    
    /*!
        @method setBodyAngle
        ボディの角度を設定します。
     */
    void    setBodyAngle(double angle);
    
    /*!
        @method setGravity
        このシミュレータの重力を設定します。
     */
    void        setGravity(const KRVector2D& gravity);
    
    /*!
        @task 衝突検知のための関数
     */
    
    /*!
        @method addCollisionPair
        @abstract 衝突検知を行う図形の衝突検出IDの組を追加します。
        図形にはデフォルトの衝突検出IDとして 0 が設定されていますが、setCollisionID() 関数を使用して任意の衝突検出IDを設定できます。
     */
    void    addCollisionPair(unsigned colID1, unsigned colID2);

    /*!
        @method getCollisions
        直前のステップ実行で衝突が検知されたすべての図形の組をリターンします。
     */
    std::list<KRCollisionInfo2D>* getCollisions();
    
    /*!
        @method removeCollisionPair
        衝突検知を行う図形の衝突検出IDの組を削除します。
     */
    void    removeCollisionPair(unsigned colID1, unsigned colID2);
    
    void    addCollisionInfo(const KRCollisionInfo2D& anInfo) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    
public:
    void*   getCPSpace() const KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void*   getCPStaticBody() const KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
  
public:
    virtual std::string to_s() const;

};

