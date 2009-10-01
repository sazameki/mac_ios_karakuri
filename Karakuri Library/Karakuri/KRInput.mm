/*
 *  KRInput.cpp
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/19.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#include <Karakuri/KRInput.h>

#include <karakuri/KarakuriGame.h>

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
#import <Karakuri/macosx/KarakuriWindow.h>
#endif

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
#import <Karakuri/iphone/KarakuriGLView.h>
#endif


KRInput *gKRInputInst = NULL;


#if KR_IPHONE
static NSLock   *sTouchLock = nil;

static double TouchPadButtonThresholdY = 130.0;
#endif


#pragma mark Constructor

KRInput::KRInput()
{
    gKRInputInst = this;

    // Full Screen Support
#if KR_MACOSX
    //mIsFullScreen = false;
#endif

    // Mouse Input Support
#if KR_MACOSX
    mMouseState = 0;
    mOldMouseState = 0;
#endif

    // Keyboard Input Support
#if KR_MACOSX
    mKeyState = 0;
    mOldKeyState = 0;
#endif
    
    // Touch Input Support
#if KR_IPHONE
    sTouchLock = [NSLock new];

    mTouchState = 0;
    mTouchStateOld = 0;

    mTouchArrow_touchID = 99999;
    
    mTouchButton1_touchID = 99999;
    mTouchButton1State = 0;
    mTouchButton1StateOld = 0;

    mTouchButton2_touchID = 99999;
    mTouchButton2State = 0;
    mTouchButton2StateOld = 0;
#endif

    // Accelerometer Support
#if KR_IPHONE
    mIsAccelerometerEnabled = false;
#endif
}



#pragma mark -
#pragma mark Support for Mouse Input (Mac OS X)

#if KR_MACOSX

KRMouseState KRInput::getMouseState()
{
    return mMouseState;
}

KRMouseState KRInput::getMouseStateOnce()
{
	KRMouseState ret = (mMouseState ^ mOldMouseState) & mMouseState;
	mOldMouseState = mMouseState;
	return ret;
}

KRVector2D KRInput::getMouseLocation()
{
    KRVector2D ret;
    
    if (_KRIsFullScreen) {
        NSPoint location = [NSEvent mouseLocation];
        NSSize screenSize = [[NSScreen mainScreen] frame].size;
        ret.x = (location.x / screenSize.width) * gKRGameInst->getScreenWidth();
        ret.y = (location.y / screenSize.height) * gKRGameInst->getScreenHeight();
    } else {
        NSPoint location = [KRWindowInst convertScreenToBase:[NSEvent mouseLocation]];
        ret.x = location.x;
        ret.y = location.y;
    }
    return ret;
}

#endif


#pragma mark -
#pragma mark Support for Keyboard Input (Mac OS X)

#if KR_MACOSX
KRKeyState KRInput::getKeyState()
{
    return mKeyState;
}

KRKeyState KRInput::getKeyStateOnce()
{
	KRKeyState ret = (mKeyState ^ mOldKeyState) & mKeyState;
	mOldKeyState = mKeyState;
	return ret;
}
#endif


#pragma mark -
#pragma mark Support for Touch Input (iPhone)

#if KR_IPHONE
bool KRInput::getTouch()
{
    return (mTouchInfos.size() > 0);
}

bool KRInput::getTouchOnce()
{
    KRTouchState theState = (mTouchState ^ mTouchStateOld) & mTouchState;
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
    [sTouchLock lock];

    int ret = mTouchInfos.size();
    
    [sTouchLock unlock];

    return ret;
}

const std::vector<KRTouchInfo> KRInput::getTouchInfos() const
{
    [sTouchLock lock];

    std::vector<KRTouchInfo> ret(mTouchInfos);

    [sTouchLock unlock];

    return ret;
}

KRVector2D KRInput::getTouchArrowMotion()
{
    if (mTouchArrow_touchID > 1000) {
        return KRVector2DZero;
    }
    return KRVector2D(mTouchArrowOldPos.x - mTouchArrowCenterPos.x, mTouchArrowOldPos.y - mTouchArrowCenterPos.y);
}

bool KRInput::getTouchButton1()
{
    return (mTouchButton1_touchID <= 1000);
}

bool KRInput::getTouchButton1Once()
{
    KRTouchState theState = (mTouchButton1State ^ mTouchButton1StateOld) & mTouchButton1State;
	mTouchButton1StateOld = mTouchButton1State;
    return (theState & TouchMask)? true: false;
}

bool KRInput::getTouchButton2()
{
    return (mTouchButton2_touchID <= 1000);
}

bool KRInput::getTouchButton2Once()
{
    KRTouchState theState = (mTouchButton2State ^ mTouchButton2StateOld) & mTouchButton2State;
	mTouchButton2StateOld = mTouchButton2State;
    return (theState & TouchMask)? true: false;
}

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
        [KRGLViewInst enableAccelerometer];
    }
    // Disable accelerometer
    else {
        [KRGLViewInst disableAccelerometer];
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

void KRInput::processMouseDown(KRMouseState mouseMask)
{
    mMouseState |= mouseMask;
}

void KRInput::processMouseUp(KRMouseState mouseMask)
{
    mMouseState &= ~mouseMask;
    mOldMouseState = 0;
}

#endif


#pragma mark -
#pragma mark Support for Keyboard Input (Mac OS X) <Framework Internal>

#if KR_MACOSX

void KRInput::processKeyDown(KRKeyState keyMask)
{
    mKeyState |= keyMask;
}

void KRInput::processKeyUp(KRKeyState keyMask)
{
    mKeyState &= ~keyMask;
    mOldKeyState = 0;
}

void KRInput::processKeyDownCode(unsigned short keyCode)
{
    if (keyCode == 0x1d || keyCode == 0x52) {
        processKeyDown(KRInput::Key0);
    }
    else if (keyCode == 0x12 || keyCode == 0x53) {
        processKeyDown(KRInput::Key1);
    }
    else if (keyCode == 0x13 || keyCode == 0x54) {
        processKeyDown(KRInput::Key2);
    }
    else if (keyCode == 0x14 || keyCode == 0x55) {
        processKeyDown(KRInput::Key3);
    }
    else if (keyCode == 0x15 || keyCode == 0x56) {
        processKeyDown(KRInput::Key4);
    }
    else if (keyCode == 0x17 || keyCode == 0x57) {
        processKeyDown(KRInput::Key5);
    }
    else if (keyCode == 0x16 || keyCode == 0x58) {
        processKeyDown(KRInput::Key6);
    }
    else if (keyCode == 0x1a || keyCode == 0x59) {
        processKeyDown(KRInput::Key7);
    }
    else if (keyCode == 0x1c || keyCode == 0x5b) {
        processKeyDown(KRInput::Key8);
    }
    else if (keyCode == 0x19 || keyCode == 0x5c) {
        processKeyDown(KRInput::Key9);
    }
    else if (keyCode == 0x00) {
        processKeyDown(KRInput::KeyA);
    }
    else if (keyCode == 0x0b) {
        processKeyDown(KRInput::KeyB);
    }
    else if (keyCode == 0x08) {
        processKeyDown(KRInput::KeyC);
    }
    else if (keyCode == 0x02) {
        processKeyDown(KRInput::KeyD);
    }
    else if (keyCode == 0x0e) {
        processKeyDown(KRInput::KeyE);
    }
    else if (keyCode == 0x03) {
        processKeyDown(KRInput::KeyF);
    }
    else if (keyCode == 0x05) {
        processKeyDown(KRInput::KeyG);
    }
    else if (keyCode == 0x04) {
        processKeyDown(KRInput::KeyH);
    }
    else if (keyCode == 0x22) {
        processKeyDown(KRInput::KeyI);
    }
    else if (keyCode == 0x26) {
        processKeyDown(KRInput::KeyJ);
    }
    else if (keyCode == 0x28) {
        processKeyDown(KRInput::KeyK);
    }
    else if (keyCode == 0x25) {
        processKeyDown(KRInput::KeyL);
    }
    else if (keyCode == 0x2e) {
        processKeyDown(KRInput::KeyM);
    }
    else if (keyCode == 0x2d) {
        processKeyDown(KRInput::KeyN);
    }
    else if (keyCode == 0x1f) {
        processKeyDown(KRInput::KeyO);
    }
    else if (keyCode == 0x23) {
        processKeyDown(KRInput::KeyP);
    }
    else if (keyCode == 0x0c) {
        processKeyDown(KRInput::KeyQ);
    }
    else if (keyCode == 0x0f) {
        processKeyDown(KRInput::KeyR);
    }
    else if (keyCode == 0x01) {
        processKeyDown(KRInput::KeyS);
    }
    else if (keyCode == 0x11) {
        processKeyDown(KRInput::KeyT);
    }
    else if (keyCode == 0x20) {
        processKeyDown(KRInput::KeyU);
    }
    else if (keyCode == 0x09) {
        processKeyDown(KRInput::KeyV);
    }
    else if (keyCode == 0x0d) {
        processKeyDown(KRInput::KeyW);
    }
    else if (keyCode == 0x07) {
        processKeyDown(KRInput::KeyX);
    }
    else if (keyCode == 0x10) {
        processKeyDown(KRInput::KeyY);
    }
    else if (keyCode == 0x06) {
        processKeyDown(KRInput::KeyZ);
    }
    else if (keyCode == 0x7e) {
        processKeyDown(KRInput::KeyUp);
    }
    else if (keyCode == 0x7d) {
        processKeyDown(KRInput::KeyDown);
    }
    else if (keyCode == 0x7b) {
        processKeyDown(KRInput::KeyLeft);
    }
    else if (keyCode == 0x7c) {
        processKeyDown(KRInput::KeyRight);
    }
    else if (keyCode == 0x24 || keyCode == 0x4c) {
        processKeyDown(KRInput::KeyReturn);
    }
    else if (keyCode == 0x30) {
        processKeyDown(KRInput::KeyTab);
    }
    else if (keyCode == 0x31) {
        processKeyDown(KRInput::KeySpace);
    }
    else if (keyCode == 0x33) {
        processKeyDown(KRInput::KeyBackspace);
    }
    else if (keyCode == 0x75) {
        processKeyDown(KRInput::KeyDelete);
    }
    else if (keyCode == 0x35) {
        processKeyDown(KRInput::KeyEscape);
    }
}

void KRInput::processKeyUpCode(unsigned short keyCode)
{
    if (keyCode == 0x1d || keyCode == 0x52) {
        processKeyUp(KRInput::Key0);
    }
    else if (keyCode == 0x12 || keyCode == 0x53) {
        processKeyUp(KRInput::Key1);
    }
    else if (keyCode == 0x13 || keyCode == 0x54) {
        processKeyUp(KRInput::Key2);
    }
    else if (keyCode == 0x14 || keyCode == 0x55) {
        processKeyUp(KRInput::Key3);
    }
    else if (keyCode == 0x15 || keyCode == 0x56) {
        processKeyUp(KRInput::Key4);
    }
    else if (keyCode == 0x17 || keyCode == 0x57) {
        processKeyUp(KRInput::Key5);
    }
    else if (keyCode == 0x16 || keyCode == 0x58) {
        processKeyUp(KRInput::Key6);
    }
    else if (keyCode == 0x1a || keyCode == 0x59) {
        processKeyUp(KRInput::Key7);
    }
    else if (keyCode == 0x1c || keyCode == 0x5b) {
        processKeyUp(KRInput::Key8);
    }
    else if (keyCode == 0x19 || keyCode == 0x5c) {
        processKeyUp(KRInput::Key9);
    }
    else if (keyCode == 0x00) {
        processKeyUp(KRInput::KeyA);
    }
    else if (keyCode == 0x0b) {
        processKeyUp(KRInput::KeyB);
    }
    else if (keyCode == 0x08) {
        processKeyUp(KRInput::KeyC);
    }
    else if (keyCode == 0x02) {
        processKeyUp(KRInput::KeyD);
    }
    else if (keyCode == 0x0e) {
        processKeyUp(KRInput::KeyE);
    }
    else if (keyCode == 0x03) {
        processKeyUp(KRInput::KeyF);
    }
    else if (keyCode == 0x05) {
        processKeyUp(KRInput::KeyG);
    }
    else if (keyCode == 0x04) {
        processKeyUp(KRInput::KeyH);
    }
    else if (keyCode == 0x22) {
        processKeyUp(KRInput::KeyI);
    }
    else if (keyCode == 0x26) {
        processKeyUp(KRInput::KeyJ);
    }
    else if (keyCode == 0x28) {
        processKeyUp(KRInput::KeyK);
    }
    else if (keyCode == 0x25) {
        processKeyUp(KRInput::KeyL);
    }
    else if (keyCode == 0x2e) {
        processKeyUp(KRInput::KeyM);
    }
    else if (keyCode == 0x2d) {
        processKeyUp(KRInput::KeyN);
    }
    else if (keyCode == 0x1f) {
        processKeyUp(KRInput::KeyO);
    }
    else if (keyCode == 0x23) {
        processKeyUp(KRInput::KeyP);
    }
    else if (keyCode == 0x0c) {
        processKeyUp(KRInput::KeyQ);
    }
    else if (keyCode == 0x0f) {
        processKeyUp(KRInput::KeyR);
    }
    else if (keyCode == 0x01) {
        processKeyUp(KRInput::KeyS);
    }
    else if (keyCode == 0x11) {
        processKeyUp(KRInput::KeyT);
    }
    else if (keyCode == 0x20) {
        processKeyUp(KRInput::KeyU);
    }
    else if (keyCode == 0x09) {
        processKeyUp(KRInput::KeyV);
    }
    else if (keyCode == 0x0d) {
        processKeyUp(KRInput::KeyW);
    }
    else if (keyCode == 0x07) {
        processKeyUp(KRInput::KeyX);
    }
    else if (keyCode == 0x10) {
        processKeyUp(KRInput::KeyY);
    }
    else if (keyCode == 0x06) {
        processKeyUp(KRInput::KeyZ);
    }
    else if (keyCode == 0x7e) {
        processKeyUp(KRInput::KeyUp);
    }
    else if (keyCode == 0x7d) {
        processKeyUp(KRInput::KeyDown);
    }
    else if (keyCode == 0x7b) {
        processKeyUp(KRInput::KeyLeft);
    }
    else if (keyCode == 0x7c) {
        processKeyUp(KRInput::KeyRight);
    }
    else if (keyCode == 0x24 || keyCode == 0x4c) {
        processKeyUp(KRInput::KeyReturn);
    }
    else if (keyCode == 0x30) {
        processKeyUp(KRInput::KeyTab);
    }
    else if (keyCode == 0x31) {
        processKeyUp(KRInput::KeySpace);
    }
    else if (keyCode == 0x33) {
        processKeyUp(KRInput::KeyBackspace);
    }
    else if (keyCode == 0x75) {
        processKeyUp(KRInput::KeyDelete);
    }
    else if (keyCode == 0x35) {
        processKeyUp(KRInput::KeyEscape);
    }    
}

#endif


#pragma mark -
#pragma mark Support for Touch Input (iPhone) <Framework Internal>

#if KR_IPHONE

void KRInput::startTouch(unsigned touchID, double x, double y)
{
    KRTouchInfo newInfo;
    
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

void KRInput::moveTouch(unsigned touchID, double x, double y, double dx, double dy)
{
    [sTouchLock lock];

    for (std::vector<KRTouchInfo>::iterator it = mTouchInfos.begin(); it != mTouchInfos.end(); it++) {
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

void KRInput::endTouch(unsigned touchID, double x, double y, double dx, double dy)
{
    [sTouchLock lock];

    for (std::vector<KRTouchInfo>::iterator it = mTouchInfos.begin(); it != mTouchInfos.end(); it++) {
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

#endif



#pragma mark -
#pragma mark Support for Accelerometer (iPhone) <Framework Internal>

#if KR_IPHONE

void KRInput::setAcceleration(double x, double y, double z)
{
    mAcceleration.x = x;
    mAcceleration.y = y;
    mAcceleration.z = z;
}

#endif

std::string KRInput::to_s() const
{
    return "<input>()";
}



