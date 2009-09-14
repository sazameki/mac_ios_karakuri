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
/*!
    @typedef KRMouseState
    @group Game Foundation
    マウスの状態をビットフラグで管理するための型です。
 */
typedef unsigned int        KRMouseState;
#endif


#pragma mark Mask Type for Keyboard Input (Mac OS X)

#if KR_MACOSX
/*!
    @typedef KRKeyState
    @group Game Foundation
    キーボードの状態をビットフラグで管理するための型です。
 */
typedef unsigned long long  KRKeyState;
#endif


#pragma mark -
#pragma mark Mask Type for Touch Input (iPhone)

#if KR_IPHONE
/*!
    @typedef KRTouchState
    @group Game Foundation
    iPhone のタッチの状態をビットフラグで管理するための型です。
 */
typedef int             KRTouchState;

/*!
    @struct KRTouchInfo
    @group Game Foundation
    iPhone のタッチ情報を表すために使われます。
 */
typedef struct KRTouchInfo {
    /*!
        @var touch_id
        @abstract 複数のタッチ情報を識別するためのIDです。
        指1本のタッチごとに、異なるIDが生成されます。
     */
    unsigned    touch_id;
    
    /*!
        @var pos
        @abstract このタッチが最後に移動した位置を示します。
     */
    KRVector2D  pos;

} KRTouchInfo;
#endif


#pragma mark -
#pragma mark Input Class Declaration

/*!
    @class  KRInput
    @group  Game Foundation
    <p>Mac OS X 環境ではキーボードとマウスによる入力を、iPhone 環境ではマルチタッチと加速度センサによる入力をサポートするためのクラスです。</p>
 */
class KRInput : public KRObject {


#pragma mark -
#pragma mark Masks for Mouse Input (Mac OS X)
    
#if KR_MACOSX
public:
    /*!
        @constant MouseButtonLeft
        マウスの左ボタンが押されていることを表すビットマスクです。
     */
    static const KRMouseState   MouseButtonLeft         = 0x01;

    /*!
        @constant MouseButtonRight
        マウスの右ボタンが押されていることを表すビットマスクです。
     */
    static const KRMouseState   MouseButtonRight        = 0x02;

    /*!
        @constant MouseButtonAny
        マウスの左ボタンまたは右ボタンが押されていることを表すビットマスクです。
     */
    static const KRMouseState   MouseButtonAny          = 0x03;
#endif
    
    
#pragma mark -
#pragma mark Masks for Keyboard Input (Mac OS X)
    
#if KR_MACOSX
public:
    /*!
        @constant Key0-Key9
        0〜9の数字キーの押下に対応したビットマスクです。このマスクは、テンキーを区別しません。
     */
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
    
    /*!
        @constant KeyA-KeyZ
        A〜Zの英字キーの押下に対応したビットマスクです。
     */
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
    
    /*!
        @constant KeyUp, KeyDown, KeyLeft, KeyRight
        矢印キーの押下に対応したビットマスクです。
     */
    static const KRKeyState     KeyUp          = (0x1LL << 36);
    static const KRKeyState     KeyDown        = (0x1LL << 37);
    static const KRKeyState     KeyLeft        = (0x1LL << 38);
    static const KRKeyState     KeyRight       = (0x1LL << 39);
    
    /*!
        @constant KeyReturn, KeySpace
        @abstract スペースキーとリターンキーの押下に対応したビットマスクです。
        リターンキーとエンターキーは同一のキーとして判定されます。
     */
    static const KRKeyState     KeyReturn      = (0x1LL << 40);
    static const KRKeyState     KeySpace       = (0x1LL << 41);

    /*!
        @constant KeyBackspace, KeyDelete
        バックスペースキーとデリートキーの押下に対応したビットマスクです。
     */
    static const KRKeyState     KeyBackspace   = (0x1LL << 42);
    static const KRKeyState     KeyDelete      = (0x1LL << 43);
    
    /*!
        @constant KeyTab, KeyEscape
        エスケープキーとタブキーの押下に対応したビットマスクです。
     */
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
    /*!
        @task マウス入力のサポート (Mac OS X)
     */
    
    /*!
        @method getMouseState
        @abstract 現在のマウス押下状態を取得します。
        左ボタン、右ボタンのすべての情報がビット単位で含まれた整数がリターンされるので、論理積 (AND) 演算を行ってマウス状態を判定してください。
     */
    KRMouseState    getMouseState();
    
    /*!
        @method getMouseStateOnce
        @abstract 現在のマウス押下状態を取得します。
        この関数を一度呼び出すと、その時点で押されていたボタンは、いったん指が離されてもう一度押されるまで対応するビットが立つことはありません。
        左ボタン、右ボタンのすべての情報がビット単位で含まれた整数がリターンされるので、論理積 (AND) 演算を行ってマウス状態を判定してください。
     */
    KRMouseState    getMouseStateOnce();
    KRVector2D      getMouseLocation();
#endif


#pragma mark -
#pragma mark Support for Keyboard Input (Mac OS X)

#if KR_MACOSX
public:
    /*!
        @task キー入力のサポート (Mac OS X)
     */
    
    /*!
        @method getKeyState
        @abstract 現在のキー入力状態を取得します。
        すべてのキー入力情報がビット単位で含まれた整数がリターンされるので、論理積 (AND) 演算を行ってキー状態を判定してください。
     */
    KRKeyState      getKeyState();
    
    /*!
        @method getKeyStateOnce
        @abstract 現在のキー入力状態を取得します。
        この関数を一度呼び出すと、その時点で押されていたキーは、いったん指が離されてもう一度押されるまで対応するビットが立つことはありません。
        すべてのキー入力情報がビット単位で含まれた整数がリターンされるので、論理積 (AND) 演算を行ってキー状態を判定してください。
     */
    KRKeyState      getKeyStateOnce();
#endif

    
#pragma mark -
#pragma mark Support for Touch Input (iPhone)

#if KR_IPHONE
public:
    /*!
        @task タッチ入力のサポート (iPhone)
     */

    /*!
        @method getTouch
        @abstract 現在画面がタッチされているかどうかを取得します。
     */
    bool            getTouch();
    
    /*!
        @method getTouchOnce
        @abstract 現在画面がタッチされているかどうかを取得します。
        この関数を一度呼び出すと、指が画面から離されてもう一度タッチされるまで、この関数が true を返すことはありません。
     */
    bool            getTouchOnce();
    
    /*!
        @method getTouchLocation
        @abstract 現在タッチされている画面上の位置を取得します。
        マルチタッチが行われている場合には、いずれか1つのタッチの情報が使用されます。
     */
    KRVector2D      getTouchLocation();

    /*!
        @method getTouchCount
        @abstract 現在のマルチタッチの個数を取得します。
     */
    int             getTouchCount();
    
    /*!
        @method getTouchInfos
        @abstract 現在のすべてのマルチタッチの情報を取得します。
     */
    const std::vector<KRTouchInfo> getTouchInfos() const;
    
    /*!
        @task 仮想ゲームパッドのサポート (iPhone)
     */
    
    /*!
        @method getTouchArrowMotion
        @abstract iPhone の画面左側をタッチしてドラッグすることで、仮想的に操作された十字キーの移動量を取得します。
     */
    KRVector2D      getTouchArrowMotion();

    /*!
        @method getTouchButton1
        @abstract 仮想的に操作されたボタン1（iPhone の画面右下のタッチ）の状態を取得します。
     */
    bool            getTouchButton1();
    
    /*!
        @method getTouchButton1Once
        @abstract 仮想的に操作されたボタン1（iPhone の画面右下のタッチ）の状態を取得します。
        この関数を一度呼び出すと、もう一度タッチし直すまでこの関数が true をリターンすることはありません。
     */
    bool            getTouchButton1Once();
    
    /*!
        @method getTouchButton2
        @abstract 仮想的に操作されたボタン2（iPhone の画面右下のタッチ）の状態を取得します。
     */
    bool            getTouchButton2();

    /*!
        @method getTouchButton2Once
        @abstract 仮想的に操作されたボタン2（iPhone の画面右下のタッチ）の状態を取得します。
        この関数を一度呼び出すと、もう一度タッチし直すまでこの関数が true をリターンすることはありません。
     */
    bool            getTouchButton2Once();
#endif
    

#pragma mark -
#pragma mark Support for Accelerometer (iPhone)

#if KR_IPHONE
public:
    /*!
        @task 加速度センサのサポート (iPhone)
     */
    
    /*!
        @method getAcceleration
        加速度センサの3軸の加速度情報を取得します。
     */
    KRVector3D  getAcceleration() const;

    /*!
        @method getAccelerometerEnabled
        @abstract 加速度センサが利用可能な状態になっているかどうかを取得します。
        加速度センサは、デフォルトでは利用しない状態に設定されています。
     */
    bool        getAccelerometerEnabled() const;
    
    /*!
        @method enableAccelerometer
        @abstract 引数に true を指定することで、加速度センサを利用可能な状態に設定します。引数に false を指定した場合には、加速度センサを利用しない状態に設定します。
        加速度センサは、デフォルトでは利用しない状態に設定されています。
     */
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


/*!
    @var KRInputInst
    @group Game Foundation
    @abstract 入力クラスのインスタンスを指す変数です。
    この変数が指し示すオブジェクトは、ゲーム実行の最初から最後まで絶対に変わりません。
 */
extern KRInput *KRInputInst;


