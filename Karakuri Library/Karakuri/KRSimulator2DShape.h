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


class KRShape2D : public KRObject {
    
protected:
    void    *mCPBody;
    void    *mCPShape;
    bool    mIsStatic;
    float   mMass;
    float   mElasticity;
    float   mFriction;
    KRVector2D  mCenterPos;
    
    KRSimulator2D   *mSimulator;
    
    unsigned    mCollisionID;

private:
    void    *mRepresentedObject;

protected:
    bool    mIsRemovedFromSpace;

protected:
    KRShape2D();
    virtual ~KRShape2D();
    
public:
    bool    isStatic() const;
    
    float       getAngle() const;
    float       getAngleVelocity() const;
    KRVector2D  getCenterPos() const;
    KRVector2D  getVelocity() const;
    
    unsigned    getCollisionID() const;
    void        setCollisionID(unsigned theID);

    void    setMass(float value);
    void    setElasticity(float value);
    void    setFriction(float value);

    void    setAngle(float angle);
    void    setCenterPos(const KRVector2D& pos);
    
    void    setVelocity(const KRVector2D& v);
    void    setAngleVelocity(float w);
    
    void    *getRepresentedObject() const;
    void    setRepresentedObject(float *anObj);
    
    KRSimulator2D   *getSimulator() const;
    
protected:
    void    setStatic(bool flag);

public:
    virtual void    addToSimulator(KRSimulator2D *simulator) = 0 KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    virtual void    removeFromSimulator() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    
    void    *getCPBody() const KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

public:
    virtual std::string to_s() const;

};

class KRShape2DLine : public KRShape2D {
    
    KRVector2D  mP1;
    KRVector2D  mP2;
    float       mLineWidth;
    
public:
    KRShape2DLine(const KRVector2D& p1, const KRVector2D& p2, bool isStatic=false);
    
public:
    void    setLineWidth(float width);
    
public:
    KRVector2D  getP1() const;
    KRVector2D  getP2() const;
    
public:
    virtual void    addToSimulator(KRSimulator2D *simulator) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

public:
    virtual std::string to_s() const;

};


class KRShape2DPoly : public KRShape2D {
    
protected:
    int         mVertexCount;
    KRVector2D  *mVertices;

public:
    KRShape2DPoly(int vertexCount, KRVector2D *verts, const KRVector2D& pos, bool isStatic=false);
    virtual ~KRShape2DPoly();
    
protected:
    KRShape2DPoly();

public:    
    int         getVertexCount() const;
    void        getVertices(KRVector2D *vertices) const;
    
public:
    virtual void    addToSimulator(KRSimulator2D *simulator) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

public:
    virtual std::string to_s() const;

};


class KRShape2DBox : public KRShape2DPoly {
    
public:
    KRShape2DBox(const KRRect2D& rect, bool isStatic=false);
    
public:
    virtual std::string to_s() const;

};

class KRShape2DCircle : public KRShape2D {
    
protected:
    float           mRadius;

public:
    KRShape2DCircle(const KRVector2D& centerPos, float radius, bool isStatic=false);
    
public:
    virtual void    addToSimulator(KRSimulator2D *simulator) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

public:
    virtual std::string to_s() const;

};


