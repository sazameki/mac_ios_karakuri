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
    KRShape2D   *getShape1() const;
    KRVector2D  getAnchor1() const;

    KRShape2D   *getShape2() const;
    KRVector2D  getAnchor2() const;
    
    bool        isStatic() const;

public:
    void    *getRepresentedObject() const;
    void    setRepresentedObject(float *anObj);

    int     getTag() const;
    void    setTag(int tag);

    KRSimulator2D   *getSimulator() const;

public:
    virtual void    addToSimulator(KRSimulator2D *simulator) = 0 KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    virtual void    removeFromSimulator() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

public:
    virtual std::string to_s() const;

};


class KRJoint2DPivot : public KRJoint2D {
    
public:
    KRJoint2DPivot(KRShape2D *shape, const KRVector2D& anchor, const KRVector2D& staticAnchor);
	KRJoint2DPivot(KRShape2D *shape1, const KRVector2D& anchor1,  KRShape2D *shape2, const KRVector2D& anchor2);

public:
    virtual void    addToSimulator(KRSimulator2D *simulator) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

public:
    virtual std::string to_s() const;

};


class KRJoint2DSpring : public KRJoint2D {

    float       mDamping;
    float       mRestLength;
    float       mStiffness;
    
public:
	KRJoint2DSpring(KRShape2D *shape, const KRVector2D& anchor, const KRVector2D& staticAnchor);
	KRJoint2DSpring(KRShape2D *shape1, const KRVector2D& anchor1,  KRShape2D *shape2, const KRVector2D& anchor2);
	virtual ~KRJoint2DSpring();
    
public:
    float   getDamping() const;
    float   getRestLength() const;
    float   getStiffness() const;
    
public:
    void    setDamping(float value);
    void    setRestLength(float value);
    void    setStiffness(float value);

public:
    virtual void    addToSimulator(KRSimulator2D *simulator) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

public:
    virtual std::string to_s() const;

};



