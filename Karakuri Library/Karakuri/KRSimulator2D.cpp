/*!
    @file   KRSimulator2D.cpp
    @author numata
    @date   09/08/12
 */

#include "KRSimulator2D.h"

#include <Karakuri/KarakuriGame.h>
#include "KRSimulator2DCollision.h"

#include <Karakuri/chipmunk/chipmunk.h>


void KRSimulator2D::initSimulatorSystem()
{
    cpInitChipmunk();
}

/*!
    @method KRSimulator2D
    Constructor
 */
KRSimulator2D::KRSimulator2D(const KRVector2D& gravity)
    : mHasChangedAngle(false)
{
    mCPSpace = cpSpaceNew();
    mCPStaticBody = cpBodyNew(INFINITY, INFINITY);
    
    ((cpSpace *)mCPSpace)->iterations = 20;

	cpSpaceResizeActiveHash((cpSpace *)mCPSpace, 40.0, 1000);
    cpSpaceResizeStaticHash((cpSpace *)mCPSpace, 200.0, 1000);

    setGravity(gravity);
}

/*!
    @method ~KRSimulator2D
    Destructor
 */
KRSimulator2D::~KRSimulator2D()
{
    cpBodyFree((cpBody *)mCPStaticBody);
	cpSpaceFreeChildren((cpSpace *)mCPSpace);
    cpSpaceFree((cpSpace *)mCPSpace);
}

void KRSimulator2D::addShape(KRShape2D *aShape)
{
    aShape->addToSimulator(this);
    mShapes.push_back(aShape);
}

void KRSimulator2D::removeShape(KRShape2D *aShape)
{
    aShape->removeFromSimulator();
    mShapes.remove(aShape);
}

std::list<KRShape2D *> *KRSimulator2D::getAllShapes()
{
    return &mShapes;
}

void KRSimulator2D::addJoint(KRJoint2D *aJoint)
{
    aJoint->addToSimulator(this);
    mJoints.push_back(aJoint);
}

void KRSimulator2D::removeJoint(KRJoint2D *aJoint)
{
    aJoint->removeFromSimulator();
    mJoints.remove(aJoint);
}

std::list<KRJoint2D *> *KRSimulator2D::getAllJoints()
{
    return &mJoints;
}

float KRSimulator2D::getBodyAngle() const
{
    return ((cpBody *)mCPStaticBody)->a;
}

void KRSimulator2D::setBodyAngle(float angle)
{
    mNextAngle = angle;
    mHasChangedAngle = true;
}

KRVector2D KRSimulator2D::getGravity() const
{
    return mGravity;
}

void KRSimulator2D::setGravity(const KRVector2D& gravity)
{
    mGravity = gravity;
    ((cpSpace *)mCPSpace)->gravity = cpv(gravity.x, gravity.y);
}

KRShape2D *KRSimulator2D::getShape(const KRVector2D& pos) const
{
    cpShape *shape = cpSpacePointQueryFirst((cpSpace *)mCPSpace, cpv(pos.x, pos.y), GRABABLE_MASK_BIT, 0);
    if (shape != NULL) {
        return (KRShape2D *)shape->data;
    }
    return NULL;
}

static int KRCollisionFunc(cpShape *a, cpShape *b, cpContact *contacts, int numContacts, cpFloat normal_coef, void *data)
{
    KRSimulator2D *simulator = (KRSimulator2D *)data;
    
    KRCollisionInfo2D collisionInfo;
    collisionInfo.shape1 = (KRShape2D *)(a->data);
    collisionInfo.shape2 = (KRShape2D *)(b->data);

    simulator->addCollisionInfo(collisionInfo);

    return 1;
}

void KRSimulator2D::addCollisionPair(unsigned colID1, unsigned colID2)
{
    cpSpaceAddCollisionPairFunc((cpSpace *)mCPSpace, colID1, colID2, KRCollisionFunc, this);
}

void KRSimulator2D::removeCollisionPair(unsigned colID1, unsigned colID2)
{
    cpSpaceRemoveCollisionPairFunc((cpSpace *)mCPSpace, colID1, colID2);
}

void KRSimulator2D::addCollisionInfo(const KRCollisionInfo2D& anInfo) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
{
    mCollisions.push_back(anInfo);
}

std::list<KRCollisionInfo2D> *KRSimulator2D::getCollisions()
{
    return &mCollisions;
}

void KRSimulator2D::step()
{
    step(1.0f / KRGame->getFrameRate());    
}

void KRSimulator2D::step(float time)
{
    mCollisions.clear();

    cpSpaceStep((cpSpace *)mCPSpace, time);
    
    if (mHasChangedAngle) {
        cpBodySetAngle((cpBody *)mCPStaticBody, mNextAngle);
        cpSpaceRehashStatic((cpSpace *)mCPSpace);
        mHasChangedAngle = false;
    }
}

void *KRSimulator2D::getCPSpace() const KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
{
    return mCPSpace;
}

void *KRSimulator2D::getCPStaticBody() const KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
{
    return mCPStaticBody;
}

std::string KRSimulator2D::to_s() const
{
    return "<simulator2d>()";
}


