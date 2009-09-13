/*
 *  KRInput.h
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/19.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>


#pragma mark Mask Type for Mouse Input (Mac OS X)

#if KR_MACOSX
typedef unsigned int        KRMouseState;
#endif


#pragma mark Mask Type for Keyboard Input (Mac OS X)

#if KR_MACOSX
typedef unsigned long long  KRKeyState;
#endif


#pragma mark -
#pragma mark Mask Type for Touch Input (iPhone)

#if KR_IPHONE
typedef int             KRTouchState;

typedef struct KRTouchInfo {
    unsigned    touch_id;
    KRVector2D  pos;
} KRTouchInfo;
#endif


#pragma mark -
#pragma mark Input Class Declaration

/*!
    @class  KRInput
    @group  Game Foundation
 */
class KRInput : public KRObject {


#pragma mark -
#pragma mark Masks for Mouse Input (Mac OS X)
    
#if KR_MACOSX
public:
    static const KRMouseState   MouseButtonLeft         = 0x01;
    static const KRMouseState   MouseButtonRight        = 0x02;
    static const KRMouseState   MouseButtonAny          = 0x03;
#endif
    
    
#pragma mark -
#pragma mark Masks for Keyboard Input (Mac OS X)
    
#if KR_MACOSX
public:
    static const KRKeyState     Key0           = 0x1LL;
    static const KRKeyState     Key1           = (0x1LL << 1);
    static const KRKeyState     Key2           = (0x1LL << 2);
    static const KRKeyState     Key3           = (0x1LL << 3);
    static const KRKeyState     Key4           = (0x1LL << 4);
    static const KRKeyState     Key5           = (0x1LL << 5);
    static const KRKeyState     Key6           = (0x1LL << 6);
    static const KRKeyState     Key7           = (0x1LL << 7);
    static const KRKeyState     Key8           = (0x1LL << 8);
    static const KRKeyState     Key9           = (0x1LL << 9);
    static const KRKeyState     KeyA           = (0x1LL << 10);
    static const KRKeyState     KeyB           = (0x1LL << 11);
    static const KRKeyState     KeyC           = (0x1LL << 12);
    static const KRKeyState     KeyD           = (0x1LL << 13);
    static const KRKeyState     KeyE           = (0x1LL << 14);
    static const KRKeyState     KeyF           = (0x1LL << 15);
    static const KRKeyState     KeyG           = (0x1LL << 16);
    static const KRKeyState     KeyH           = (0x1LL << 17);
    static const KRKeyState     KeyI           = (0x1LL << 18);
    static const KRKeyState     KeyJ           = (0x1LL << 19);
    static const KRKeyState     KeyK           = (0x1LL << 20);
    static const KRKeyState     KeyL           = (0x1LL << 21);
    static const KRKeyState     KeyM           = (0x1LL << 22);
    static const KRKeyState     KeyN           = (0x1LL << 23);
    static const KRKeyState     KeyO           = (0x1LL << 24);
    static const KRKeyState     KeyP           = (0x1LL << 25);
    static const KRKeyState     KeyQ           = (0x1LL << 26);
    static const KRKeyState     KeyR           = (0x1LL << 27);
    static const KRKeyState     KeyS           = (0x1LL << 28);
    static const KRKeyState     KeyT           = (0x1LL << 29);
    static const KRKeyState     KeyU           = (0x1LL << 30);
    static const KRKeyState     KeyV           = (0x1LL << 31);
    static const KRKeyState     KeyW           = (0x1LL << 32);
    static const KRKeyState     KeyX           = (0x1LL << 33);
    static const KRKeyState     KeyY           = (0x1LL << 34);
    static const KRKeyState     KeyZ           = (0x1LL << 35);
    static const KRKeyState     KeyUp          = (0x1LL << 36);
    static const KRKeyState     KeyDown        = (0x1LL << 37);
    static const KRKeyState     KeyLeft        = (0x1LL << 38);
    static const KRKeyState     KeyRight       = (0x1LL << 39);
    static const KRKeyState     KeyReturn      = (0x1LL << 40);
    static const KRKeyState     KeySpace       = (0x1LL << 41);
    static const KRKeyState     KeyBackspace   = (0x1LL << 42);
    static const KRKeyState     KeyDelete      = (0x1LL << 43);
    static const KRKeyState     KeyTab         = (0x1LL << 44);
    static const KRKeyState     KeyEscape      = (0x1LL << 45);
#endif


#pragma mark -
#pragma mark Masks for Touch Input (iPhone)

#if KR_IPHONE
public:
    static const KRTouchState   TouchMask   = 0x1;
#endif
    
    
#pragma mark -
#pragma mark Variables to Support Mouse Input (Mac OS X)

#if KR_MACOSX
private:
    KRMouseState    mMouseState;
    KRMouseState    mOldMouseState;
    //bool            mIsFullScreen;
#endif


#pragma mark -
#pragma mark Variables to Support Keyboard Input (Mac OS X)

#if KR_MACOSX
private:
    KRKeyState      mKeyState;
    KRKeyState      mOldKeyState;
#endif


#pragma mark -
#pragma mark Variables to Support Touch Input (iPhone)

#if KR_IPHONE
private:
    KRTouchState                mTouchState;
    KRTouchState                mTouchStateOld;
    std::vector<KRTouchInfo>    mTouchInfos;

    unsigned                    mTouchArrow_touchID;
    KRVector2D                  mTouchArrowCenterPos;
    KRVector2D                  mTouchArrowOldPos;
    
    unsigned                    mTouchButton1_touchID;
    KRTouchState                mTouchButton1State;
    KRTouchState                mTouchButton1StateOld;

    unsigned                    mTouchButton2_touchID;
    KRTouchState                mTouchButton2State;
    KRTouchState                mTouchButton2StateOld;
#endif
    
    
#pragma mark -
#pragma mark Variables to Support Accelerometer (iPhone)
    
#if KR_IPHONE
private:
    KRVector3D      mAcceleration;
    bool            mIsAccelerometerEnabled;
#endif
    
    
#pragma mark -
#pragma mark Constructor

public:
    KRInput();

    
#pragma mark -
#pragma mark Support for Mouse Input (Mac OS X)

#if KR_MACOSX
public:
    KRMouseState    getMouseState();
    KRMouseState    getMouseStateOnce();
    KRVector2D      getMouseLocation();
#endif


#pragma mark -
#pragma mark Support for Keyboard Input (Mac OS X)

#if KR_MACOSX
public:
    KRKeyState      getKeyState();
    KRKeyState      getKeyStateOnce();
#endif

    
#pragma mark -
#pragma mark Support for Touch Input (iPhone)

#if KR_IPHONE
public:
    bool            getTouch();
    bool            getTouchOnce();
    KRVector2D      getTouchLocation();

    int             getTouchCount();
    const std::vector<KRTouchInfo> getTouchInfos() const;
    
    KRVector2D      getTouchArrowMotion();
    bool            getTouchButton1();
    bool            getTouchButton1Once();
    bool            getTouchButton2();
    bool            getTouchButton2Once();
#endif
    

#pragma mark -
#pragma mark Support for Accelerometer (iPhone)

#if KR_IPHONE
public:
    KRVector3D  getAcceleration() const;
    bool        getAccelerometerEnabled() const;
    void        enableAccelerometer(bool flag);
#endif

    
#pragma mark -
#pragma mark Support for Full Screen Mode (Mac OS X) <Framework Internal>
    
#if KR_MACOSX
public:
    //void            setFullScreenMode(bool isFullScreen) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
#endif
    
#pragma mark -
#pragma mark Support for Mouse Input (Mac OS X) <Framework Internal>

#if KR_MACOSX
public:
    // These methods are intended to be used with KarakuriGLView class.
    void    processMouseDown(KRMouseState mouseMask) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    processMouseUp(KRMouseState mouseMask) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
#endif

    
#pragma mark -
#pragma mark Support for Keyboard Input (Mac OS X) <Framework Internal>

#if KR_MACOSX
public:
    void    processKeyDown(KRKeyState keyMask) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    processKeyUp(KRKeyState keyMask) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    processKeyDownCode(unsigned short keyCode) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    processKeyUpCode(unsigned short keyCode) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
#endif
    

#pragma mark -
#pragma mark Support for Touch Input (iPhone) <Framework Internal>

#if KR_IPHONE
public:
    void    startTouch(unsigned touchID, float x, float y) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    moveTouch(unsigned touchID, float x, float y, float dx, float dy) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    endTouch(unsigned touchID, float x, float y, float dx, float dy) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
#endif
    
    
#pragma mark -
#pragma mark Support for Accelerometer (iPhone) <Framework Internal>

#if KR_IPHONE
public:
    // These methods are intended to be used with KarakuriGLView class.
    void    setAcceleration(float x, float y, float z) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
#endif


#pragma mark -
#pragma mark Debug Support

public:
    std::string to_s() const;

};


extern KRInput *KRInputInst;


