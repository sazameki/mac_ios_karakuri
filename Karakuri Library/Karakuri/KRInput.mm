/*
 *  KRInput.cpp
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/19.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#include <Karakuri/KRInput.h>

#include <karakuri/KRGameManager.h>
#include <Karakuri/KRWorld.h>

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
#import <Karakuri/macosx/KarakuriWindow.h>
#endif

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
#import <Karakuri/iphone/KarakuriGLView.h>
#endif


KRInput*    gKRInputInst = NULL;


#if KR_IPHONE
static NSLock*  sTouchLock = nil;

static double   TouchPadButtonThresholdY = 130.0;
#endif


#pragma mark Constructor

KRInput::KRInput()
{
    gKRInputInst = this;

    // Full Screen Support
#if KR_MACOSX
    //mIsFullScreen = false;
#endif

    _resetAllInputs();

    // Touch Input Support
#if KR_IPHONE
    sTouchLock = [NSLock new];
#endif
    
    // Accelerometer Support
#if KR_IPHONE
    mIsAccelerometerEnabled = false;
#endif    
}



#pragma mark -
#pragma mark Support for Mouse Input (Mac OS X)

#if KR_MACOSX

bool KRInput::isMouseDown() const
{
    return mIsMouseDown;
}

bool KRInput::isMouseDownOnce() const
{
    return mIsMouseDownOnce;
}

_KRMouseState KRInput::_getMouseState()
{
    return mMouseState;
}

_KRMouseState KRInput::_getMouseStateAgainstDummy()
{
    return mMouseStateAgainstDummy;
}

_KRMouseState KRInput::_getMouseStateOnce()
{
	_KRMouseState ret = (mMouseState ^ mMouseStateOld) & mMouseState;
	mMouseStateOld |= mMouseState;
	return ret;
}

KRVector2D KRInput::getMouseLocation()
{
    if (mHasDummySource) {
        return mMouseLocationForDummy;
    }
    
    KRVector2D ret;
    
    if (_KRIsFullScreen) {
        NSPoint location = [NSEvent mouseLocation];
        NSSize screenSize = [[NSScreen mainScreen] frame].size;
        ret.x = (location.x / screenSize.width) * gKRGameMan->getScreenWidth();
        ret.y = (location.y / screenSize.height) * gKRGameMan->getScreenHeight();
    } else {
        NSPoint location = [gKRWindowInst convertScreenToBase:[NSEvent mouseLocation]];
        ret.x = location.x;
        ret.y = location.y;
    }
    return ret;
}

#endif


#pragma mark -
#pragma mark Support for Keyboard Input (Mac OS X)

#if KR_MACOSX

bool KRInput::isKeyDown(KRKeyInfo key) const
{
    return (mKeyState & key)? true: false;
}

bool KRInput::isKeyDownOnce(KRKeyInfo key) const
{
    return (mKeyStateOnce & key)? true: false;
}

bool KRInput::isKeyDownAgainstDummy(KRKeyInfo key) const
{
    return (mKeyStateAgainstDummy & key)? true: false;
}

KRKeyInfo KRInput::_getKeyState()
{
    return mKeyState;
}

KRKeyInfo KRInput::getKeyState()
{
    return _getKeyState();
}

KRKeyInfo KRInput::_getKeyStateOnce()
{
	KRKeyInfo ret = (mKeyState ^ mKeyStateOld) & mKeyState;
	mKeyStateOld |= mKeyState;
	return ret;
}

KRKeyInfo KRInput::getKeyStateOnce()
{
    return _getKeyStateOnce();
}

KRKeyInfo KRInput::_getKeyStateAgainstDummy()
{
    return mKeyStateAgainstDummy;
}

KRKeyInfo KRInput::getKeyStateAgainstDummy()
{
    return _getKeyStateAgainstDummy();
}
#endif


#pragma mark -
#pragma mark Support for Touch Input (iPhone)

#if KR_IPHONE
bool KRInput::getTouch()
{
    return (mTouchInfos.size() > 0);
}

bool KRInput::getTouchAgainstDummy()
{
    return (mTouchCountAgainstDummy > 0);
}

bool KRInput::getTouchOnce() const
{
    return mIsTouchedOnce;
}

bool KRInput::_getTouchOnceImpl()
{
    _KRTouchState theState = (mTouchState ^ mTouchStateOld) & mTouchState;
	mTouchStateOld = mTouchState;
    return (theState & TouchMask)? true: false;
}

KRVector2D KRInput::getTouchLocation()
{
    KRVector2D ret = KRVector2DZero;

    [sTouchLock lock];

    if (mTouchInfos.size() > 0) {
        ret = mTouchInfos.begin()->pos;
    }

    [sTouchLock unlock];

    return ret;
}

int KRInput::getTouchCount()
{
    int ret;
    
    [sTouchLock lock];

    ret = mTouchInfos.size();
    
    [sTouchLock unlock];

    return ret;
}

std::vector<int> KRInput::getTouchIDs() const
{
    std::vector<int> ret;

    [sTouchLock lock];
    
    for (std::vector<_KRTouchInfo>::const_iterator it = mTouchInfos.begin(); it != mTouchInfos.end(); it++) {
        ret.push_back(it->touch_id);
    }
    
    [sTouchLock unlock];
    
    return ret;
}

KRVector2D KRInput::getTouchLocation(int touchID) const
{
    for (std::vector<_KRTouchInfo>::const_iterator it = mTouchInfos.begin(); it != mTouchInfos.end(); it++) {
        if (it->touch_id == touchID) {
            return it->pos;
        }
    }
    
    return KRVector2D(-1.0, -1.0);
}

const std::vector<_KRTouchInfo> KRInput::getTouchInfos() const
{
    [sTouchLock lock];

    std::vector<_KRTouchInfo> ret(mTouchInfos);

    [sTouchLock unlock];

    return ret;
}

/*KRVector2D KRInput::getTouchArrowMotion()
{
    if (mTouchArrow_touchID > 1000) {
        return KRVector2DZero;
    }
    return KRVector2D(mTouchArrowOldPos.x - mTouchArrowCenterPos.x, mTouchArrowOldPos.y - mTouchArrowCenterPos.y);
}*/

/*bool KRInput::getTouchButton1()
{
    return (mTouchButton1_touchID <= 1000);
}*/

/*bool KRInput::getTouchButton1Once()
{
    KRTouchState theState = (mTouchButton1State ^ mTouchButton1StateOld) & mTouchButton1State;
	mTouchButton1StateOld = mTouchButton1State;
    return (theState & TouchMask)? true: false;
}*/

/*bool KRInput::getTouchButton2()
{
    return (mTouchButton2_touchID <= 1000);
}*/

/*bool KRInput::getTouchButton2Once()
{
    KRTouchState theState = (mTouchButton2State ^ mTouchButton2StateOld) & mTouchButton2State;
	mTouchButton2StateOld = mTouchButton2State;
    return (theState & TouchMask)? true: false;
}*/

#endif


#pragma mark -
#pragma mark Support for Accelerometer (iPhone)

#if KR_IPHONE
KRVector3D KRInput::getAcceleration() const
{
    return mAcceleration;
}

bool KRInput::getAccelerometerEnabled() const
{
    return mIsAccelerometerEnabled;
}

void KRInput::enableAccelerometer(bool flag)
{
    if (!((mIsAccelerometerEnabled? 1: 0) ^ (flag? 1: 0))) {
        return;
    }
    
    // Enable accelerometer
    if (flag) {
        mAcceleration = KRVector3DZero;
        [gKRGLViewInst enableAccelerometer];
    }
    // Disable accelerometer
    else {
        [gKRGLViewInst disableAccelerometer];
    }

    mIsAccelerometerEnabled = flag;
}
#endif


#pragma mark -
#pragma mark Support for Full Screen Mode (Mac OS X) <Framework Internal>

#if KR_MACOSX

/*void KRInput::setFullScreenMode(bool isFullScreen)
{
    mIsFullScreen = isFullScreen;
}*/

#endif


#pragma mark -
#pragma mark Support for Mouse Input (Mac OS X) <Framework Internal>

#if KR_MACOSX

void KRInput::_processMouseDownImpl(_KRMouseState mouseMask)
{
    mMouseState |= mouseMask;

    if ((NSFileHandle *)gInputLogHandle != nil) {
        KRVector2D locationDouble = getMouseLocation();
        KRVector2DInt location((int)locationDouble.x, (int)locationDouble.y);
        mOldMouseLocationForInputLog = location;
        NSString *dataStr = [NSString stringWithFormat:@"%u:MD%X(%d,%d)\n", gInputLogFrameCounter, mouseMask, mOldMouseLocationForInputLog.x, mOldMouseLocationForInputLog.y];
        [(NSFileHandle *)gInputLogHandle writeData:[dataStr dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

void KRInput::_processMouseDragImpl(const KRVector2D& pos)
{
    if (mHasDummySource) {
        mMouseLocationForDummy = pos;
    }
    
    if ((NSFileHandle *)gInputLogHandle != nil) {
        KRVector2D locationDouble = getMouseLocation();
        KRVector2DInt location((int)locationDouble.x, (int)locationDouble.y);
        if (location != mOldMouseLocationForInputLog) {
            NSString *dataStr = [NSString stringWithFormat:@"%u:MM(%d,%d)\n", gInputLogFrameCounter, location.x, location.y];
            [(NSFileHandle *)gInputLogHandle writeData:[dataStr dataUsingEncoding:NSUTF8StringEncoding]];
            mOldMouseLocationForInputLog = location;
        }
    }
}

void KRInput::_processMouseUpImpl(_KRMouseState mouseMask)
{
    mMouseState &= ~mouseMask;
    mMouseStateOld &= ~mouseMask;
    
	mIsMouseDownOld = mIsMouseDownOld && ((mouseMask & (_MouseButtonLeft | _MouseButtonRight))? false: true);

    if ((NSFileHandle *)gInputLogHandle != nil) {
        KRVector2D locationDouble = getMouseLocation();
        KRVector2DInt location((int)locationDouble.x, (int)locationDouble.y);
        NSString *dataStr = [NSString stringWithFormat:@"%u:MU%X(%d,%d)\n", gInputLogFrameCounter, mouseMask, location.x, location.y];
        [(NSFileHandle *)gInputLogHandle writeData:[dataStr dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

void KRInput::_processMouseDownImplAgainstDummy(_KRMouseState mouseMask)
{
    mMouseStateAgainstDummy |= mouseMask;
}

void KRInput::_processMouseUpImplAgainstDummy(_KRMouseState mouseMask)
{
    mMouseStateAgainstDummy &= ~mouseMask;
}

void KRInput::_processMouseDown(_KRMouseState mouseMask)
{
    if (mHasDummySource) {
        _processMouseDownImplAgainstDummy(mouseMask);
    } else {
        _processMouseDownImpl(mouseMask);
    }
}

void KRInput::_processMouseDrag()
{
    if (mHasDummySource) {
        // Do nothing
    } else {
        _processMouseDragImpl();
    }
}

void KRInput::_processMouseUp(_KRMouseState mouseMask)
{
    if (mHasDummySource) {
        _processMouseUpImplAgainstDummy(mouseMask);
    } else {
        _processMouseUpImpl(mouseMask);
    }
}

#endif


#pragma mark -
#pragma mark Support for Keyboard Input (Mac OS X) <Framework Internal>

#if KR_MACOSX

void KRInput::_processKeyDown(KRKeyInfo keyMask)
{
    mKeyState |= keyMask;
    
    if ((NSFileHandle *)gInputLogHandle != nil) {
        NSString *dataStr = [NSString stringWithFormat:@"%u:KD%qX\n", gInputLogFrameCounter, keyMask];
        [(NSFileHandle *)gInputLogHandle writeData:[dataStr dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

void KRInput::_processKeyDownAgainstDummy(KRKeyInfo keyMask)
{
    mKeyStateAgainstDummy |= keyMask;
}

void KRInput::_processKeyUp(KRKeyInfo keyMask)
{
    mKeyState &= ~keyMask;
    mKeyStateOld &= ~keyMask;

    if ((NSFileHandle *)gInputLogHandle != nil) {
        NSString *dataStr = [NSString stringWithFormat:@"%u:KU%qX\n", gInputLogFrameCounter, keyMask];
        [(NSFileHandle *)gInputLogHandle writeData:[dataStr dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

void KRInput::_processKeyUpAgainstDummy(KRKeyInfo keyMask)
{
    mKeyStateAgainstDummy &= ~keyMask;
}

void KRInput::_processKeyDownCode(unsigned short keyCode)
{
    void (KRInput::*processFunc)(KRKeyInfo) = &KRInput::_processKeyDown;

    if (mHasDummySource) {
        processFunc = &KRInput::_processKeyDownAgainstDummy;
    }

    if (keyCode == 0x1d || keyCode == 0x52) {
        (this->*processFunc)(KRInput::Key0);
    }
    else if (keyCode == 0x12 || keyCode == 0x53) {
        (this->*processFunc)(KRInput::Key1);
    }
    else if (keyCode == 0x13 || keyCode == 0x54) {
        (this->*processFunc)(KRInput::Key2);
    }
    else if (keyCode == 0x14 || keyCode == 0x55) {
        (this->*processFunc)(KRInput::Key3);
    }
    else if (keyCode == 0x15 || keyCode == 0x56) {
        (this->*processFunc)(KRInput::Key4);
    }
    else if (keyCode == 0x17 || keyCode == 0x57) {
        (this->*processFunc)(KRInput::Key5);
    }
    else if (keyCode == 0x16 || keyCode == 0x58) {
        (this->*processFunc)(KRInput::Key6);
    }
    else if (keyCode == 0x1a || keyCode == 0x59) {
        (this->*processFunc)(KRInput::Key7);
    }
    else if (keyCode == 0x1c || keyCode == 0x5b) {
        (this->*processFunc)(KRInput::Key8);
    }
    else if (keyCode == 0x19 || keyCode == 0x5c) {
        (this->*processFunc)(KRInput::Key9);
    }
    else if (keyCode == 0x00) {
        (this->*processFunc)(KRInput::KeyA);
    }
    else if (keyCode == 0x0b) {
        (this->*processFunc)(KRInput::KeyB);
    }
    else if (keyCode == 0x08) {
        (this->*processFunc)(KRInput::KeyC);
    }
    else if (keyCode == 0x02) {
        (this->*processFunc)(KRInput::KeyD);
    }
    else if (keyCode == 0x0e) {
        (this->*processFunc)(KRInput::KeyE);
    }
    else if (keyCode == 0x03) {
        (this->*processFunc)(KRInput::KeyF);
    }
    else if (keyCode == 0x05) {
        (this->*processFunc)(KRInput::KeyG);
    }
    else if (keyCode == 0x04) {
        (this->*processFunc)(KRInput::KeyH);
    }
    else if (keyCode == 0x22) {
        (this->*processFunc)(KRInput::KeyI);
    }
    else if (keyCode == 0x26) {
        (this->*processFunc)(KRInput::KeyJ);
    }
    else if (keyCode == 0x28) {
        (this->*processFunc)(KRInput::KeyK);
    }
    else if (keyCode == 0x25) {
        (this->*processFunc)(KRInput::KeyL);
    }
    else if (keyCode == 0x2e) {
        (this->*processFunc)(KRInput::KeyM);
    }
    else if (keyCode == 0x2d) {
        (this->*processFunc)(KRInput::KeyN);
    }
    else if (keyCode == 0x1f) {
        (this->*processFunc)(KRInput::KeyO);
    }
    else if (keyCode == 0x23) {
        (this->*processFunc)(KRInput::KeyP);
    }
    else if (keyCode == 0x0c) {
        (this->*processFunc)(KRInput::KeyQ);
    }
    else if (keyCode == 0x0f) {
        (this->*processFunc)(KRInput::KeyR);
    }
    else if (keyCode == 0x01) {
        (this->*processFunc)(KRInput::KeyS);
    }
    else if (keyCode == 0x11) {
        (this->*processFunc)(KRInput::KeyT);
    }
    else if (keyCode == 0x20) {
        (this->*processFunc)(KRInput::KeyU);
    }
    else if (keyCode == 0x09) {
        (this->*processFunc)(KRInput::KeyV);
    }
    else if (keyCode == 0x0d) {
        (this->*processFunc)(KRInput::KeyW);
    }
    else if (keyCode == 0x07) {
        (this->*processFunc)(KRInput::KeyX);
    }
    else if (keyCode == 0x10) {
        (this->*processFunc)(KRInput::KeyY);
    }
    else if (keyCode == 0x06) {
        (this->*processFunc)(KRInput::KeyZ);
    }
    else if (keyCode == 0x7e) {
        (this->*processFunc)(KRInput::KeyUp);
    }
    else if (keyCode == 0x7d) {
        (this->*processFunc)(KRInput::KeyDown);
    }
    else if (keyCode == 0x7b) {
        (this->*processFunc)(KRInput::KeyLeft);
    }
    else if (keyCode == 0x7c) {
        (this->*processFunc)(KRInput::KeyRight);
    }
    else if (keyCode == 0x24 || keyCode == 0x4c) {
        (this->*processFunc)(KRInput::KeyReturn);
    }
    else if (keyCode == 0x30) {
        (this->*processFunc)(KRInput::KeyTab);
    }
    else if (keyCode == 0x31) {
        (this->*processFunc)(KRInput::KeySpace);
    }
    else if (keyCode == 0x33) {
        (this->*processFunc)(KRInput::KeyBackspace);
    }
    else if (keyCode == 0x75) {
        (this->*processFunc)(KRInput::KeyDelete);
    }
    else if (keyCode == 0x35) {
        (this->*processFunc)(KRInput::KeyEscape);
    }
}

void KRInput::_processKeyUpCode(unsigned short keyCode)
{
    void (KRInput::*processFunc)(KRKeyInfo) = &KRInput::_processKeyUp;
    
    if (mHasDummySource) {
        processFunc = &KRInput::_processKeyUpAgainstDummy;
    }
    
    if (keyCode == 0x1d || keyCode == 0x52) {
        (this->*processFunc)(KRInput::Key0);
    }
    else if (keyCode == 0x12 || keyCode == 0x53) {
        (this->*processFunc)(KRInput::Key1);
    }
    else if (keyCode == 0x13 || keyCode == 0x54) {
        (this->*processFunc)(KRInput::Key2);
    }
    else if (keyCode == 0x14 || keyCode == 0x55) {
        (this->*processFunc)(KRInput::Key3);
    }
    else if (keyCode == 0x15 || keyCode == 0x56) {
        (this->*processFunc)(KRInput::Key4);
    }
    else if (keyCode == 0x17 || keyCode == 0x57) {
        (this->*processFunc)(KRInput::Key5);
    }
    else if (keyCode == 0x16 || keyCode == 0x58) {
        (this->*processFunc)(KRInput::Key6);
    }
    else if (keyCode == 0x1a || keyCode == 0x59) {
        (this->*processFunc)(KRInput::Key7);
    }
    else if (keyCode == 0x1c || keyCode == 0x5b) {
        (this->*processFunc)(KRInput::Key8);
    }
    else if (keyCode == 0x19 || keyCode == 0x5c) {
        (this->*processFunc)(KRInput::Key9);
    }
    else if (keyCode == 0x00) {
        (this->*processFunc)(KRInput::KeyA);
    }
    else if (keyCode == 0x0b) {
        (this->*processFunc)(KRInput::KeyB);
    }
    else if (keyCode == 0x08) {
        (this->*processFunc)(KRInput::KeyC);
    }
    else if (keyCode == 0x02) {
        (this->*processFunc)(KRInput::KeyD);
    }
    else if (keyCode == 0x0e) {
        (this->*processFunc)(KRInput::KeyE);
    }
    else if (keyCode == 0x03) {
        (this->*processFunc)(KRInput::KeyF);
    }
    else if (keyCode == 0x05) {
        (this->*processFunc)(KRInput::KeyG);
    }
    else if (keyCode == 0x04) {
        (this->*processFunc)(KRInput::KeyH);
    }
    else if (keyCode == 0x22) {
        (this->*processFunc)(KRInput::KeyI);
    }
    else if (keyCode == 0x26) {
        (this->*processFunc)(KRInput::KeyJ);
    }
    else if (keyCode == 0x28) {
        (this->*processFunc)(KRInput::KeyK);
    }
    else if (keyCode == 0x25) {
        (this->*processFunc)(KRInput::KeyL);
    }
    else if (keyCode == 0x2e) {
        (this->*processFunc)(KRInput::KeyM);
    }
    else if (keyCode == 0x2d) {
        (this->*processFunc)(KRInput::KeyN);
    }
    else if (keyCode == 0x1f) {
        (this->*processFunc)(KRInput::KeyO);
    }
    else if (keyCode == 0x23) {
        (this->*processFunc)(KRInput::KeyP);
    }
    else if (keyCode == 0x0c) {
        (this->*processFunc)(KRInput::KeyQ);
    }
    else if (keyCode == 0x0f) {
        (this->*processFunc)(KRInput::KeyR);
    }
    else if (keyCode == 0x01) {
        (this->*processFunc)(KRInput::KeyS);
    }
    else if (keyCode == 0x11) {
        (this->*processFunc)(KRInput::KeyT);
    }
    else if (keyCode == 0x20) {
        (this->*processFunc)(KRInput::KeyU);
    }
    else if (keyCode == 0x09) {
        (this->*processFunc)(KRInput::KeyV);
    }
    else if (keyCode == 0x0d) {
        (this->*processFunc)(KRInput::KeyW);
    }
    else if (keyCode == 0x07) {
        (this->*processFunc)(KRInput::KeyX);
    }
    else if (keyCode == 0x10) {
        (this->*processFunc)(KRInput::KeyY);
    }
    else if (keyCode == 0x06) {
        (this->*processFunc)(KRInput::KeyZ);
    }
    else if (keyCode == 0x7e) {
        (this->*processFunc)(KRInput::KeyUp);
    }
    else if (keyCode == 0x7d) {
        (this->*processFunc)(KRInput::KeyDown);
    }
    else if (keyCode == 0x7b) {
        (this->*processFunc)(KRInput::KeyLeft);
    }
    else if (keyCode == 0x7c) {
        (this->*processFunc)(KRInput::KeyRight);
    }
    else if (keyCode == 0x24 || keyCode == 0x4c) {
        (this->*processFunc)(KRInput::KeyReturn);
    }
    else if (keyCode == 0x30) {
        (this->*processFunc)(KRInput::KeyTab);
    }
    else if (keyCode == 0x31) {
        (this->*processFunc)(KRInput::KeySpace);
    }
    else if (keyCode == 0x33) {
        (this->*processFunc)(KRInput::KeyBackspace);
    }
    else if (keyCode == 0x75) {
        (this->*processFunc)(KRInput::KeyDelete);
    }
    else if (keyCode == 0x35) {
        (this->*processFunc)(KRInput::KeyEscape);
    }
}

#endif


#pragma mark -
#pragma mark Support for Touch Input (iPhone) <Framework Internal>

#if KR_IPHONE

void KRInput::_startTouchImpl(unsigned touchID, double x, double y)
{
    _KRTouchInfo newInfo;
    
    newInfo.touch_id = touchID;
    newInfo.pos.x = x;
    newInfo.pos.y = y;
    
    [sTouchLock lock];

    mTouchInfos.push_back(newInfo);
    mTouchState |= TouchMask;
    
    // Game Pad Support (Supported only under the horizontal environment)
    if (gKRScreenSize.x > gKRScreenSize.y) {
        // Arrow Support
        if (x <= gKRScreenSize.x / 2) {
            mTouchArrow_touchID = touchID;
            mTouchArrowCenterPos = newInfo.pos;
            mTouchArrowOldPos = mTouchArrowCenterPos;
        }
        // Button Support 1
        else if (y < TouchPadButtonThresholdY) {
            mTouchButton1_touchID = touchID;
            mTouchButton1State |= TouchMask;
        }
        // Button Support 2
        else {
            mTouchButton2_touchID = touchID;
            mTouchButton2State |= TouchMask;
        }
    }
    
    // Finish
    [sTouchLock unlock];
}

void KRInput::_moveTouchImpl(unsigned touchID, double x, double y, double dx, double dy)
{
    [sTouchLock lock];

    for (std::vector<_KRTouchInfo>::iterator it = mTouchInfos.begin(); it != mTouchInfos.end(); it++) {
        if (it->touch_id == touchID) {
            it->pos.x = x;
            it->pos.y = y;
            break;
        }
    }
    
    // Game Pad Support (Arrow)
    if (mTouchArrow_touchID == touchID) {
        mTouchArrowOldPos.x = x;
        mTouchArrowOldPos.y = y;
    }

    [sTouchLock unlock];
}

void KRInput::_endTouchImpl(unsigned touchID, double x, double y, double dx, double dy)
{
    [sTouchLock lock];

    for (std::vector<_KRTouchInfo>::iterator it = mTouchInfos.begin(); it != mTouchInfos.end(); it++) {
        if (it->touch_id == touchID) {
            mTouchInfos.erase(it);
            break;
        }
    }
    
    // 基本の処理
    mTouchState &= ~TouchMask;
    mTouchStateOld = 0;
    
    // Game Pad Support (Arrow)
    if (mTouchArrow_touchID == touchID) {
        mTouchArrow_touchID = 99999;
    }
    // Game Pad Support (Button 1)
    else if (mTouchButton1_touchID == touchID) {
        mTouchButton1State &= ~TouchMask;
        mTouchButton1StateOld = 0;
        mTouchButton1_touchID = 99999;
    }
    // Game Pad Support (Button 2)
    else if (mTouchButton2_touchID == touchID) {
        mTouchButton2State &= ~TouchMask;
        mTouchButton2StateOld = 0;
        mTouchButton2_touchID = 99999;
    }

    // Finish
    [sTouchLock unlock];
}

void KRInput::_startTouchImplAgainstDummy(unsigned touchID, double x, double y)
{
    mTouchCountAgainstDummy++;
}

void KRInput::_endTouchImplAgainstDummy(unsigned touchID, double x, double y, double dx, double dy)
{
    mTouchCountAgainstDummy--;
}

void KRInput::_startTouch(unsigned touchID, double x, double y)
{
    if (mHasDummySource) {
        _startTouchImplAgainstDummy(touchID, x, y);
    } else {
        _startTouchImpl(touchID, x, y);
    }
    
    if ((NSFileHandle *)gInputLogHandle != nil) {
        NSString *dataStr = [NSString stringWithFormat:@"%u:TD%X(%f,%f)\n", gInputLogFrameCounter, touchID, x, y];
        [(NSFileHandle *)gInputLogHandle writeData:[dataStr dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

void KRInput::_moveTouch(unsigned touchID, double x, double y, double dx, double dy)
{
    if (mHasDummySource) {
        // Do nothing
    } else {
        _moveTouchImpl(touchID, x, y, dx, dy);
    }
    
    if ((NSFileHandle *)gInputLogHandle != nil) {
        NSString *dataStr = [NSString stringWithFormat:@"%u:TM%X(%f,%f)\n", gInputLogFrameCounter, touchID, x, y];
        [(NSFileHandle *)gInputLogHandle writeData:[dataStr dataUsingEncoding:NSUTF8StringEncoding]];
    }    
}

void KRInput::_endTouch(unsigned touchID, double x, double y, double dx, double dy)
{
    if (mHasDummySource) {
        _endTouchImplAgainstDummy(touchID, x, y, dx, dy);
    } else {
        _endTouchImpl(touchID, x, y, dx, dy);
    }
    
    if ((NSFileHandle *)gInputLogHandle != nil) {
        NSString *dataStr = [NSString stringWithFormat:@"%u:TU%X(%f,%f)\n", gInputLogFrameCounter, touchID, x, y];
        [(NSFileHandle *)gInputLogHandle writeData:[dataStr dataUsingEncoding:NSUTF8StringEncoding]];
    }    
}

#endif



#pragma mark -
#pragma mark Support for Accelerometer (iPhone) <Framework Internal>

#if KR_IPHONE

void KRInput::_setAccelerationImpl(double x, double y, double z)
{
    mAcceleration.x = x;
    mAcceleration.y = y;
    mAcceleration.z = z;
}

void KRInput::_setAcceleration(double x, double y, double z)
{
    if (mHasDummySource) {
        // Do nothing
    } else {
        _setAccelerationImpl(x, y, z);
    }

    if ((NSFileHandle *)gInputLogHandle != nil) {
        NSString *dataStr = [NSString stringWithFormat:@"%u:AC(%f,%f,%f)\n", gInputLogFrameCounter, x, y, z];
        [(NSFileHandle *)gInputLogHandle writeData:[dataStr dataUsingEncoding:NSUTF8StringEncoding]];
    }    
}

#endif


#pragma mark -
#pragma mark "Once" Support

void KRInput::_updateOnceInfo()
{
#if KR_MACOSX
    mKeyStateOnce = _getKeyStateOnce();

    mIsMouseDown = (_getMouseState() & (_MouseButtonLeft | _MouseButtonRight))? true: false;
    mIsMouseDownOnce = (mIsMouseDown ^ mIsMouseDownOld) && mIsMouseDown;
	mIsMouseDownOld = mIsMouseDownOld || mIsMouseDown;
#endif

#if KR_IPHONE
    mIsTouchedOnce = _getTouchOnceImpl();
#endif
}


#pragma mark -
#pragma mark Dummy Input Support

void KRInput::_plugDummySourceIn()
{
    mHasDummySource = true;
}

void KRInput::_pullDummySourceOut()
{
    mHasDummySource = false;
}

void KRInput::_processDummyData(KRInputSourceData& data)
{
#if KR_MACOSX
    // Keyboard
    if (data.command[0] == 'K') {
        // Key Down
        if (data.command[1] == 'D') {
            _processKeyDown(data.data_mask);
        }
        // Key Up
        else if (data.command[1] == 'U') {
            _processKeyUp(data.data_mask);
        }
    }
    // Mouse
    else if (data.command[0] == 'M') {
        // Mouse Down
        if (data.command[1] == 'D') {
            mMouseLocationForDummy = data.location;
            _processMouseDownImpl((_KRMouseState)data.data_mask);
        }
        // Mouse Drag
        else if (data.command[1] == 'M') {
            _processMouseDragImpl(data.location);
        }
        // Mouse Up
        else if (data.command[1] == 'U') {
            mMouseLocationForDummy = data.location;
            _processMouseUpImpl((_KRMouseState)data.data_mask);
        }
    }
#endif
    
#if KR_IPHONE
    // Touch
    if (data.command[0] == 'T') {
        // Touch Start
        if (data.command[1] == 'D') {
            _startTouchImpl((unsigned)data.data_mask, data.location.x, data.location.y);
        }
        // Touch Move
        else if (data.command[1] == 'M') {
            _moveTouchImpl((unsigned)data.data_mask, data.location.x, data.location.y, 0.0, 0.0);
        }
        // Touch End
        else if (data.command[1] == 'U') {
            _endTouchImpl((unsigned)data.data_mask, data.location.x, data.location.y, 0.0, 0.0);
        }
    }
    // Acceleration
    else if (data.command[0] == 'A') {
        _setAccelerationImpl(data.location.x, data.location.y, data.location.z);
    }
#endif
}


#pragma mark -
#pragma mark Debug Support

void KRInput::_resetAllInputs()
{
    mHasDummySource = NO;
    
    // Mouse Input Support
#if KR_MACOSX
    mIsMouseDown = false;
    mIsMouseDownOld = false;
    mIsMouseDownOnce = false;
    mMouseState = 0;
    mMouseStateOld = 0;
    mMouseStateAgainstDummy = 0;
    mMouseLocationForDummy = KRVector2DZero;
#endif
    
    // Keyboard Input Support
#if KR_MACOSX
    mKeyState = 0;
    mKeyStateOld = 0;
    mKeyStateOnce = 0;
    mKeyStateAgainstDummy = 0;
#endif
    
    // Touch Input Support
#if KR_IPHONE
    mTouchState = 0;
    mIsTouchedOnce = false;
    mTouchStateOld = 0;
    mTouchCountAgainstDummy = 0;
    
    mTouchArrow_touchID = 99999;
    
    mTouchButton1_touchID = 99999;
    mTouchButton1State = 0;
    mTouchButton1StateOld = 0;
    
    mTouchButton2_touchID = 99999;
    mTouchButton2State = 0;
    mTouchButton2StateOld = 0;
#endif
}


#pragma mark -
#pragma mark Debug Support

std::string KRInput::to_s() const
{
    return "<input>()";
}



