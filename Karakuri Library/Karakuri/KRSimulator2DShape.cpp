/*!
    @file   KRSimulator2DShape.cpp
    @author numata
    @date   09/08/12
 */

#include "KRSimulator2DShape.h"
#include "KRSimulator2D.h"

#include <Karakuri/chipmunk/chipmunk.h>


#pragma mark -
#pragma mark Shape Base

KRShape2D::KRShape2D()
    : mCPBody(NULL), mCPShape(NULL), mIsStatic(false), mMass(1.0f), mElasticity(0.0f), mFriction(1.0f),
      mIsRemovedFromSpace(true), mRepresentedObject(NULL), mSimulator(NULL), mCollisionID(0), mTag(0)
{
    // Nothing to do.
}

KRShape2D::~KRShape2D()
{
    removeFromSimulator();
}

bool KRShape2D::isStatic() const
{
    return mIsStatic;
}

void KRShape2D::setStatic(bool flag)
{
    mIsStatic = flag;
}

unsigned KRShape2D::getCollisionID() const
{
    return mCollisionID;
}

void KRShape2D::setCollisionID(unsigned theID)
{
    mCollisionID = theID;
    if (mCPShape != NULL) {
        ((cpShape *)mCPShape)->collision_type = theID;
    }
}

void KRShape2D::setMass(float value)
{
    mMass = value;
}

void KRShape2D::setElasticity(float value)
{
    mElasticity = value;
}

void KRShape2D::setFriction(float value)
{
    mFriction = value;
}

KRVector2D KRShape2D::getCenterPos() const
{
    if (mIsStatic) {
        return mCenterPos;
    }    
    return KRVector2D(((cpBody *)mCPBody)->p.x, ((cpBody *)mCPBody)->p.y);
}

float KRShape2D::getAngle() const
{
    if (mIsStatic) {
        return 0.0f;
    }    
    return ((cpBody *)mCPBody)->a;
}

float KRShape2D::getAngleVelocity() const
{
    if (mIsStatic) {
        return 0.0f;
    }    
    return ((cpBody *)mCPBody)->w;
}

KRVector2D KRShape2D::getVelocity() const
{
    if (mIsStatic) {
        return KRVector2DZero;
    }    
    return KRVector2D(((cpBody *)mCPBody)->v.x, ((cpBody *)mCPBody)->v.y);
}

void KRShape2D::setAngle(float angle)
{
    if (mIsStatic) {
        return;
    }
    cpBodySetAngle((cpBody *)mCPBody, angle);
}

void KRShape2D::setCenterPos(const KRVector2D& pos)
{
    if (mIsStatic) {
        return;
    }
    cpBodySetPos((cpBody *)mCPBody, cpv(pos.x, pos.y));
}

void KRShape2D::setVelocity(const KRVector2D& v)
{
    if (mIsStatic) {
        return;
    }
    cpBodySetVel((cpBody *)mCPBody, cpv(v.x, v.y));
}

void KRShape2D::setAngleVelocity(float w)
{
    if (mIsStatic) {
        return;
    }
    cpBodySetAngVel((cpBody *)mCPBody, w);
}

void *KRShape2D::getRepresentedObject() const
{
    return mRepresentedObject;
}

void KRShape2D::setRepresentedObject(float *anObj)
{
    mRepresentedObject = anObj;
}

int KRShape2D::getTag() const
{
    return mTag;
}

void KRShape2D::setTag(int tag)
{
    mTag = tag;
}

KRSimulator2D *KRShape2D::getSimulator() const
{
    return mSimulator;
}

void KRShape2D::removeFromSimulator() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
{
    if (mIsRemovedFromSpace) {
        return;
    }
    
    if (mIsStatic) {
        cpSpaceRemoveStaticShape((cpSpace *)(mSimulator->getCPSpace()), (cpShape *)mCPShape);
        cpShapeFree((cpShape *)mCPShape);
        mCPShape = NULL;
    } else {
        cpSpaceRemoveShape((cpSpace *)(mSimulator->getCPSpace()), (cpShape *)mCPShape);
        cpSpaceRemoveBody((cpSpace *)(mSimulator->getCPSpace()), (cpBody *)mCPBody);
        cpShapeFree((cpShape *)mCPShape);
        cpBodyFree((cpBody *)mCPBody);
        mCPShape = NULL;
        mCPBody = NULL;
    }
    
    mSimulator = NULL;
    mIsRemovedFromSpace = true;
}

void *KRShape2D::getCPBody() const KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
{
    return mCPBody;
}

std::string KRShape2D::to_s() const
{
    return "<shape2d>()";
}


#pragma mark -
#pragma mark Line Shape

KRShape2DLine::KRShape2DLine(const KRVector2D& p1, const KRVector2D& p2, bool isStatic)
    : mP1(p1), mP2(p2), mLineWidth(0.0f)
{
    setStatic(isStatic);
}

KRVector2D KRShape2DLine::getP1() const
{
    if (mIsStatic) {
        return mP1;
    }
    cpVect a = cpvadd(((cpBody *)mCPBody)->p, cpvrotate(((cpSegmentShape *)mCPShape)->a, ((cpBody *)mCPBody)->rot));

    return KRVector2D(a.x, a.y);
}

KRVector2D KRShape2DLine::getP2() const
{
    if (mIsStatic) {
        return mP2;
    }
	cpVect b = cpvadd(((cpBody *)mCPBody)->p, cpvrotate(((cpSegmentShape *)mCPShape)->b, ((cpBody *)mCPBody)->rot));
    return KRVector2D(b.x, b.y);
}

void KRShape2DLine::setLineWidth(float width)
{
    mLineWidth = width;
}

void KRShape2DLine::addToSimulator(KRSimulator2D *simulator) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
{
    mSimulator = simulator;
    mIsRemovedFromSpace = false;

    if (mIsStatic) {
        mCPShape = cpSegmentShapeNew((cpBody *)(simulator->getCPStaticBody()), cpv(mP1.x, mP1.y), cpv(mP2.x, mP2.y), mLineWidth);
        ((cpShape *)mCPShape)->e = mElasticity;
        ((cpShape *)mCPShape)->u = mFriction;
        ((cpShape *)mCPShape)->layers = NOT_GRABABLE_MASK;
        ((cpShape *)mCPShape)->collision_type = mCollisionID;
        cpSpaceAddStaticShape((cpSpace *)(simulator->getCPSpace()), (cpShape *)mCPShape);
    } else {
        mCPBody = cpBodyNew(mMass, cpMomentForSegment(mMass, cpv(mP1.x, mP1.y), cpv(mP2.x, mP2.y)));
        ((cpBody *)mCPBody)->p = cpv(mP1.x, mP1.y);
        cpSpaceAddBody((cpSpace *)(simulator->getCPSpace()), (cpBody *)mCPBody);

        mCPShape = cpSegmentShapeNew(((cpBody *)mCPBody), cpv(mP1.x, mP1.y), cpv(mP2.x, mP2.y), mLineWidth);
        ((cpShape *)mCPShape)->e = mElasticity;
        ((cpShape *)mCPShape)->u = mFriction;
        ((cpShape *)mCPShape)->collision_type = mCollisionID;
        cpSpaceAddShape((cpSpace *)(simulator->getCPSpace()), (cpShape *)mCPShape);
    }
    ((cpShape *)mCPShape)->data = this;
}

std::string KRShape2DLine::to_s() const
{
    return "<shape2d_line>()";
}


#pragma mark -
#pragma mark Poly Shape

KRShape2DPoly::KRShape2DPoly(int vertexCount, KRVector2D *verts, const KRVector2D& pos, bool isStatic)
    : mVertexCount(vertexCount)
{
    mCenterPos = pos;
    
    setStatic(isStatic);
    
    mVertices = new KRVector2D[vertexCount];
    for (int i = 0; i < vertexCount; i++) {
        mVertices[i] = verts[i];
    }
}

KRShape2DPoly::KRShape2DPoly()
{
    // Nothing to do.
}

KRShape2DPoly::~KRShape2DPoly()
{
    delete[] mVertices;
}

int KRShape2DPoly::getVertexCount() const
{
    return mVertexCount;
}

void KRShape2DPoly::getVertices(KRVector2D *vertices) const
{
    cpPolyShape *poly = (cpPolyShape *)mCPShape;
    int count = poly->numVerts;
	cpVect *verts = poly->verts;
	for (int i = 0; i < count; i++) {
		cpVect v = cpvadd(((cpBody *)mCPBody)->p, cpvrotate(verts[i], ((cpBody *)mCPBody)->rot));
        vertices[i].x = v.x;
        vertices[i].y = v.y;
    }
}

void KRShape2DPoly::addToSimulator(KRSimulator2D *simulator) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
{
    mSimulator = simulator;
    mIsRemovedFromSpace = false;

    cpVect cpVerts[mVertexCount];
    
    for (int i = 0; i < mVertexCount; i++) {
        cpVerts[i].x = mVertices[i].x;
        cpVerts[i].y = mVertices[i].y;
    }
    
    if (mIsStatic) {
        mCPShape = cpPolyShapeNew((cpBody *)(simulator->getCPStaticBody()), mVertexCount, cpVerts, cpvzero);
        ((cpShape *)mCPShape)->e = mElasticity;
        ((cpShape *)mCPShape)->u = mFriction;
        ((cpShape *)mCPShape)->layers = NOT_GRABABLE_MASK;
        ((cpShape *)mCPShape)->collision_type = mCollisionID;
        cpSpaceAddStaticShape((cpSpace *)(simulator->getCPSpace()), (cpShape *)mCPShape);
    } else {
        mCPBody = cpBodyNew(mMass, cpMomentForPoly(1.0, mVertexCount, cpVerts, cpvzero));
        ((cpBody *)mCPBody)->p = cpv(mCenterPos.x, mCenterPos.y);
        cpSpaceAddBody((cpSpace *)(simulator->getCPSpace()), (cpBody *)mCPBody);

        mCPShape = cpPolyShapeNew(((cpBody *)mCPBody), mVertexCount, cpVerts, cpvzero);
        ((cpShape *)mCPShape)->e = mElasticity;
        ((cpShape *)mCPShape)->u = mFriction;
        ((cpShape *)mCPShape)->collision_type = mCollisionID;
        cpSpaceAddShape((cpSpace *)(simulator->getCPSpace()), (cpShape *)mCPShape);
    }
    ((cpShape *)mCPShape)->data = this;
}

std::string KRShape2DPoly::to_s() const
{
    return "<shape2d_poly>()";
}


#pragma mark -
#pragma mark Box Shape

KRShape2DBox::KRShape2DBox(const KRRect2D& rect, bool isStatic)
{
    setStatic(isStatic);
    
    mVertexCount = 4;
    mCenterPos = rect.getCenterPos();
    
    KRVector2D halfSize = rect.getSize() / 2;
    
    mVertices = new KRVector2D[4];
    mVertices[0].x = -halfSize.x;
    mVertices[0].y = -halfSize.y;
    mVertices[1].x = -halfSize.x;
    mVertices[1].y = halfSize.y;
    mVertices[2].x = halfSize.x;
    mVertices[2].y = halfSize.y;
    mVertices[3].x = halfSize.x;
    mVertices[3].y = -halfSize.y;
}

std::string KRShape2DBox::to_s() const
{
    return "<shape2d_box>()";
}


#pragma mark -
#pragma mark Circle Shape

KRShape2DCircle::KRShape2DCircle(const KRVector2D& centerPos, float radius, bool isStatic)
    : mRadius(radius)
{
    setStatic(isStatic);
    
    mCenterPos = centerPos;
}

void KRShape2DCircle::addToSimulator(KRSimulator2D *simulator) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
{
    mSimulator = simulator;
    mIsRemovedFromSpace = false;

    if (mIsStatic) {
        mCPShape = cpCircleShapeNew((cpBody *)(simulator->getCPStaticBody()), mRadius, cpv(mCenterPos.x, mCenterPos.y));
        ((cpShape *)mCPShape)->e = mElasticity;
        ((cpShape *)mCPShape)->u = mFriction;
        ((cpShape *)mCPShape)->layers = NOT_GRABABLE_MASK;
        ((cpShape *)mCPShape)->collision_type = mCollisionID;
        cpSpaceAddStaticShape((cpSpace *)(simulator->getCPSpace()), (cpShape *)mCPShape);
    } else {
        mCPBody = cpBodyNew(mMass, cpMomentForCircle(mMass, 0.0, mRadius, cpvzero));
        ((cpBody *)mCPBody)->p = cpv(mCenterPos.x, mCenterPos.y);
        cpSpaceAddBody((cpSpace *)(simulator->getCPSpace()), (cpBody *)mCPBody);
        
        mCPShape = cpCircleShapeNew(((cpBody *)mCPBody), mRadius, cpvzero);
        ((cpShape *)mCPShape)->e = mElasticity;
        ((cpShape *)mCPShape)->u = mFriction;
        ((cpShape *)mCPShape)->collision_type = mCollisionID;
        cpSpaceAddShape((cpSpace *)(simulator->getCPSpace()), ((cpShape *)mCPShape));        
    }
    ((cpShape *)mCPShape)->data = this;
}

std::string KRShape2DCircle::to_s() const
{
    return "<shape2d_circle>()";
}






