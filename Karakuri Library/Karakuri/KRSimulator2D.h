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


class KRSimulator2D : public KRObject {

public:
    static void initSimulatorSystem();

private:
    void        *mCPSpace;
    void        *mCPStaticBody;
    float       mNextAngle;
    bool        mHasChangedAngle;
    KRVector2D  mGravity;
    std::list<KRShape2D *>  mShapes;
    std::list<KRJoint2D *>  mJoints;
    std::list<KRCollisionInfo2D>  mCollisions;

public:
	KRSimulator2D(const KRVector2D& gravity);
	virtual ~KRSimulator2D();
    
public:
    void    addShape(KRShape2D *aShape);
    void    removeShape(KRShape2D *aShape);
    std::list<KRShape2D *>  *getAllShapes();
    
    void    addJoint(KRJoint2D *aJoint);
    void    removeJoint(KRJoint2D *aJoint);
    std::list<KRJoint2D *>  *getAllJoints();

    float   getBodyAngle() const;
    void    setBodyAngle(float angle);
    
    KRVector2D  getGravity() const;
    void        setGravity(const KRVector2D& gravity);
    
    KRShape2D   *getShape(const KRVector2D& pos) const;
    
    void    addCollisionPair(unsigned colID1, unsigned colID2);
    void    removeCollisionPair(unsigned colID1, unsigned colID2);
    std::list<KRCollisionInfo2D>  *getCollisions();
    void    addCollisionInfo(const KRCollisionInfo2D& anInfo) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    
public:
    void    step();
    void    step(float time);
    
public:
    void    *getCPSpace() const KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    *getCPStaticBody() const KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
  
public:
    virtual std::string to_s() const;

};

