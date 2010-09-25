/*!
    @file   KRSimulator2DJoint.cpp
    @author numata
    @date   09/08/12
 */

#include "KRSimulator2DJoint.h"

#include "KRSimulator2D.h"
#include "KRSimulator2DShape.h"

#include <Karakuri/chipmunk/chipmunk.h>


KRJoint2D::KRJoint2D(KRShape2D* shape, const KRVector2D& anchor, const KRVector2D& staticAnchor)
    : mConstraint(NULL), mRepresentedObject(NULL), mIsStatic(true), mShape1(shape), mShape2(NULL),
      mAnchor1(anchor), mAnchor2(staticAnchor), mIsRemovedFromSpace(true), mTag(0)
{
    // Do nothing
}

KRJoint2D::KRJoint2D(KRShape2D* shape1, const KRVector2D& anchor1,  KRShape2D* shape2, const KRVector2D& anchor2)
    : mConstraint(NULL), mRepresentedObject(NULL), mIsStatic(false), mShape1(shape1),
      mAnchor1(anchor1), mShape2(shape2), mAnchor2(anchor2), mIsRemovedFromSpace(true), mTag(0)
{
    // Do nothing
}

KRJoint2D::~KRJoint2D()
{
    removeFromSimulator();
}

KRShape2D* KRJoint2D::getShape1() const
{
    return mShape1;
}

KRVector2D KRJoint2D::getAnchor1() const
{
    return mAnchor1;
}

KRShape2D* KRJoint2D::getShape2() const
{
    return mShape2;
}

KRVector2D KRJoint2D::getAnchor2() const
{
    return mAnchor2;
}

bool KRJoint2D::isStatic() const
{
    return mIsStatic;
}

void* KRJoint2D::getRepresentedObject() const
{
    return mRepresentedObject;
}

void KRJoint2D::setRepresentedObject(void* anObj)
{
    mRepresentedObject = anObj;
}

int KRJoint2D::getTag() const
{
    return mTag;
}

void KRJoint2D::setTag(int tag)
{
    mTag = tag;
}

KRSimulator2D* KRJoint2D::getSimulator() const
{
    return mSimulator;
}

void KRJoint2D::removeFromSimulator() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
{
    if (mIsRemovedFromSpace) {
        return;
    }
    
    cpSpaceRemoveConstraint((cpSpace*)(mSimulator->getCPSpace()), (cpConstraint*)mConstraint);
    cpConstraintFree((cpConstraint*)mConstraint);
    mConstraint = NULL;
    
    mIsRemovedFromSpace = true;
}

std::string KRJoint2D::to_s() const
{
    return "<joint2d>()";
}


#pragma mark -
#pragma mark Pivot Joint

KRJoint2DPivot::KRJoint2DPivot(KRShape2D* shape, const KRVector2D& anchor, const KRVector2D& staticAnchor)
    : KRJoint2D(shape, anchor, staticAnchor)
{
    // Do nothing
}

KRJoint2DPivot::KRJoint2DPivot(KRShape2D* shape1, const KRVector2D& anchor1,  KRShape2D* shape2, const KRVector2D& anchor2)
    : KRJoint2D(shape1, anchor1, shape2, anchor2)
{
    // Do nothing
}

void KRJoint2DPivot::addToSimulator(KRSimulator2D* simulator) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
{
    mSimulator = simulator;
    mIsRemovedFromSpace = false;

    if (mIsStatic) {
        mConstraint = cpPivotJointNew2((cpBody*)(simulator->getCPStaticBody()), (cpBody*)(mShape1->getCPBody()),
                                       cpv(mAnchor2.x, mAnchor2.y), cpv(mAnchor1.x, mAnchor1.y));
    } else {
        mConstraint = cpPivotJointNew2((cpBody*)(mShape1->getCPBody()), (cpBody*)(mShape2->getCPBody()),
                                       cpv(mAnchor1.x, mAnchor1.y), cpv(mAnchor2.x, mAnchor2.y));
    }
    cpSpaceAddConstraint((cpSpace*)(simulator->getCPSpace()), (cpConstraint*)mConstraint);
}

std::string KRJoint2DPivot::to_s() const
{
    return "<joint2d_pivot>()";
}


#pragma mark -
#pragma mark Spring Joint

KRJoint2DSpring::KRJoint2DSpring(KRShape2D* shape, const KRVector2D& anchor, const KRVector2D& staticAnchor)
    : KRJoint2D(shape, anchor, staticAnchor), mDamping(1.0), mRestLength(0.0), mStiffness(100.0)
{
    // Do nothing
}

/*!
    @method KRJoint2DSpring
    Constructor
 */
KRJoint2DSpring::KRJoint2DSpring(KRShape2D* shape1, const KRVector2D& anchor1,  KRShape2D* shape2, const KRVector2D& anchor2)
    : KRJoint2D(shape1, anchor1, shape2, anchor2), mDamping(1.0), mRestLength(0.0), mStiffness(100.0)
{
    // Do nothing
}

/*!
    @method ~KRJoint2DSpring
    Destructor
 */
KRJoint2DSpring::~KRJoint2DSpring()
{
    // Do nothing
}

double KRJoint2DSpring::getDamping() const
{
    if (mConstraint != NULL) {
        return (double)(((cpDampedSpring*)mConstraint)->damping);
    }
    return mDamping;
}

double KRJoint2DSpring::getRestLength() const
{
    if (mConstraint != NULL) {
        return (double)(((cpDampedSpring*)mConstraint)->restLength);
    }
    return mRestLength;
}

double KRJoint2DSpring::getStiffness() const
{
    if (mConstraint != NULL) {
        return (double)(((cpDampedSpring*)mConstraint)->stiffness);
    }
    return mStiffness;
}

void KRJoint2DSpring::setDamping(double value)
{
    mDamping = value;
    if (mConstraint != NULL) {
        ((cpDampedSpring*)mConstraint)->damping = value;
    }
}

void KRJoint2DSpring::setRestLength(double value)
{
    mRestLength = value;
    if (mConstraint != NULL) {
        ((cpDampedSpring*)mConstraint)->restLength = value;
    }
}

void KRJoint2DSpring::setStiffness(double value)
{
    mStiffness = value;
    if (mConstraint != NULL) {
        ((cpDampedSpring*)mConstraint)->stiffness = value;
    }
}

static cpFloat springForce(cpConstraint* spring, cpFloat dist)
{
	cpFloat clamp = 20.0;
	return cpfclamp(cpDampedSpringGetRestLength(spring) - dist, -clamp, clamp)*cpDampedSpringGetStiffness(spring);
}

void KRJoint2DSpring::addToSimulator(KRSimulator2D* simulator) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
{
    mSimulator = simulator;
    mIsRemovedFromSpace = false;

    if (mIsStatic) {
        mConstraint = cpDampedSpringNew((cpBody*)(simulator->getCPStaticBody()), (cpBody*)(mShape1->getCPBody()),
                                        cpv(mAnchor2.x, mAnchor2.y), cpv(mAnchor1.x, mAnchor1.y),
                                        mRestLength, mStiffness, mDamping);
    } else {
        mConstraint = cpDampedSpringNew((cpBody*)(mShape1->getCPBody()), (cpBody*)(mShape2->getCPBody()),
                                        cpv(mAnchor1.x, mAnchor1.y), cpv(mAnchor2.x, mAnchor2.y),
                                        mRestLength, mStiffness, mDamping);
    }
    cpDampedSpringSetSpringForceFunc((cpConstraint*)mConstraint, springForce);
    cpSpaceAddConstraint((cpSpace*)(simulator->getCPSpace()), (cpConstraint*)mConstraint);
}

std::string KRJoint2DSpring::to_s() const
{
    return "<joint2d_spring>()";
}


