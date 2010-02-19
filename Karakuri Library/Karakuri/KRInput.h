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


struct KRInputSourceData;


#pragma mark Mask Type for Mouse Input (Mac OS X)

#if KR_MACOSX
/*!
    @typedef KRMouseState
    @group Game Foundation
    @abstract マウスの状態をビットフラグで管理するための型です。
 */
typedef unsigned int        KRMouseState;
#endif


#pragma mark Mask Type for Keyboard Input (Mac OS X)

#if KR_MACOSX
/*!
    @typedef KRKeyInfo
    @group Game Foundation
    @abstract キーボードの状態をビットフラグで管理するための型です。
 */
typedef unsigned long long  KRKeyInfo;
typedef KRKeyInfo           KRKeyState;
#endif


#pragma mark -
#pragma mark Mask Type for Touch Input (iPhone)

#if KR_IPHONE
/*!
    @typedef KRTouchState
    @group Game Foundation
    @abstract iPhone のタッチの状態をビットフラグで管理するための型です。
 */
typedef int             KRTouchState;

/*!
    @struct KRTouchInfo
    @group Game Foundation
    @abstract iPhone のタッチ情報を表すための構造体です。
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
    @abstract 入力関係全般をサポートするためのクラスです。
    <p>Mac OS X 環境ではキーボードとマウスによる入力を、iPhone 環境ではマルチタッチと加速度センサによる入力をサポートします。</p>
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
    static const KRKeyInfo      Key0           = 0x1LL;
    static const KRKeyInfo      Key1           = (0x1LL << 1);
    static const KRKeyInfo      Key2           = (0x1LL << 2);
    static const KRKeyInfo      Key3           = (0x1LL << 3);
    static const KRKeyInfo      Key4           = (0x1LL << 4);
    static const KRKeyInfo      Key5           = (0x1LL << 5);
    static const KRKeyInfo      Key6           = (0x1LL << 6);
    static const KRKeyInfo      Key7           = (0x1LL << 7);
    static const KRKeyInfo      Key8           = (0x1LL << 8);
    static const KRKeyInfo      Key9           = (0x1LL << 9);
    
    /*!
        @constant KeyA-KeyZ
        A〜Zの英字キーの押下に対応したビットマスクです。
     */
    static const KRKeyInfo      KeyA           = (0x1LL << 10);
    static const KRKeyInfo      KeyB           = (0x1LL << 11);
    static const KRKeyInfo      KeyC           = (0x1LL << 12);
    static const KRKeyInfo      KeyD           = (0x1LL << 13);
    static const KRKeyInfo      KeyE           = (0x1LL << 14);
    static const KRKeyInfo      KeyF           = (0x1LL << 15);
    static const KRKeyInfo      KeyG           = (0x1LL << 16);
    static const KRKeyInfo      KeyH           = (0x1LL << 17);
    static const KRKeyInfo      KeyI           = (0x1LL << 18);
    static const KRKeyInfo      KeyJ           = (0x1LL << 19);
    static const KRKeyInfo      KeyK           = (0x1LL << 20);
    static const KRKeyInfo      KeyL           = (0x1LL << 21);
    static const KRKeyInfo      KeyM           = (0x1LL << 22);
    static const KRKeyInfo      KeyN           = (0x1LL << 23);
    static const KRKeyInfo      KeyO           = (0x1LL << 24);
    static const KRKeyInfo      KeyP           = (0x1LL << 25);
    static const KRKeyInfo      KeyQ           = (0x1LL << 26);
    static const KRKeyInfo      KeyR           = (0x1LL << 27);
    static const KRKeyInfo      KeyS           = (0x1LL << 28);
    static const KRKeyInfo      KeyT           = (0x1LL << 29);
    static const KRKeyInfo      KeyU           = (0x1LL << 30);
    static const KRKeyInfo      KeyV           = (0x1LL << 31);
    static const KRKeyInfo      KeyW           = (0x1LL << 32);
    static const KRKeyInfo      KeyX           = (0x1LL << 33);
    static const KRKeyInfo      KeyY           = (0x1LL << 34);
    static const KRKeyInfo      KeyZ           = (0x1LL << 35);
    
    /*!
        @constant KeyUp, KeyDown, KeyLeft, KeyRight
        矢印キーの押下に対応したビットマスクです。
     */
    static const KRKeyInfo      KeyUp          = (0x1LL << 36);
    static const KRKeyInfo      KeyDown        = (0x1LL << 37);
    static const KRKeyInfo      KeyLeft        = (0x1LL << 38);
    static const KRKeyInfo      KeyRight       = (0x1LL << 39);
    
    /*!
        @constant KeyReturn, KeySpace
        @abstract スペースキーとリターンキーの押下に対応したビットマスクです。
        リターンキーとエンターキーは同一のキーとして判定されます。
     */
    static const KRKeyInfo      KeyReturn      = (0x1LL << 40);
    static const KRKeyInfo      KeySpace       = (0x1LL << 41);

    /*!
        @constant KeyBackspace, KeyDelete
        バックスペースキーとデリートキーの押下に対応したビットマスクです。
     */
    static const KRKeyInfo      KeyBackspace   = (0x1LL << 42);
    static const KRKeyInfo      KeyDelete      = (0x1LL << 43);
    
    /*!
        @constant KeyTab, KeyEscape
        エスケープキーとタブキーの押下に対応したビットマスクです。
     */
    static const KRKeyInfo      KeyTab         = (0x1LL << 44);
    static const KRKeyInfo      KeyEscape      = (0x1LL << 45);
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
    bool            mIsMouseDown;
    bool            mIsMouseDownOld;
    bool            mIsMouseDownOnce;
    KRVector2DInt   mOldMouseLocationForInputLog;
    KRMouseState    mMouseState;
    KRMouseState    mMouseStateOld;
    KRMouseState    mMouseStateAgainstDummy;
    KRVector2D      mMouseLocationForDummy;
    //bool            mIsFullScreen;
#endif


#pragma mark -
#pragma mark Variables to Support Keyboard Input (Mac OS X)

#if KR_MACOSX
private:
    KRKeyInfo       mKeyState;
    KRKeyInfo       mKeyStateOld;
    KRKeyInfo       mKeyStateOnce;
    KRKeyInfo       mKeyStateAgainstDummy;
#endif


#pragma mark -
#pragma mark Variables to Support Touch Input (iPhone)

#if KR_IPHONE
private:
    KRTouchState                mTouchState;
    bool                        mIsTouchedOnce;
    KRTouchState                mTouchStateOld;
    int                         mTouchCountAgainstDummy;
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
#pragma Dummy Input Support
private:
    bool            mHasDummySource;

    
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
        @method isMouseDown
        @abstract   マウスが押されている状態かどうかを判定します。
        この関数は、左ボタンと右ボタンを区別しません。
     */
    bool            isMouseDown() const;

    /*!
        @method isMouseDownOnce
        @abstract   マウスが押されている状態かどうかを判定します。
        <p>あるフレームでマウスが押されていると判定されると、それ以降のフレームでマウスが離されて押し直されるまで、この関数が true を返すことはありません。</p>
        <p>この関数は、左ボタンと右ボタンを区別しません。</p>
     */
    bool            isMouseDownOnce() const;
    
    /*!
        @method getMouseState
        @abstract 現在のマウス押下状態を取得します。
        左ボタン、右ボタンのすべての情報がビット単位で含まれた整数がリターンされるので、論理積 (AND) 演算を行ってマウス状態を判定してください。
     */
    KRMouseState    getMouseState();

    /*!
        @method getMouseStateAgainstDummy
        @abstract ダミー入力が設定されている際に、ユーザからの現在のマウス押下状態を取得します。
        左ボタン、右ボタンのすべての情報がビット単位で含まれた整数がリターンされるので、論理積 (AND) 演算を行ってマウス状態を判定してください。
     */
    KRMouseState    getMouseStateAgainstDummy();
    
    /*!
        @method getMouseStateOnce
        @abstract 現在のマウス押下状態を取得します。
        この関数を一度呼び出すと、その時点で押されていたボタンは、いったん指が離されてもう一度押されるまで対応するビットが立つことはありません。
        左ボタン、右ボタンのすべての情報がビット単位で含まれた整数がリターンされるので、論理積 (AND) 演算を行ってマウス状態を判定してください。
     */
    KRMouseState    getMouseStateOnce();

    /*!
        @method getMouseLocation
        @abstract 現在のマウスのカーソル位置を取得します。
     */
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
        @method isKeyDown
        @abstract   キーが押されている状態かどうかを判定します。
     */
    bool        isKeyDown(KRKeyInfo key) const;

    /*!
        @method isKeyDownOnce
        @abstract   キーが押されている状態かどうかを判定します。
        あるフレームで押されていると判定されたキーに対しては、それ以降のフレームでキーが離されて押し直されるまで、この関数が true を返すことはありません。
     */
    bool        isKeyDownOnce(KRKeyInfo key) const;
    
    /*!
        @method getKeyState
        @abstract 現在のキー入力状態を取得します。
        すべてのキー入力情報がビット単位で含まれた整数がリターンされるので、論理積 (AND) 演算を行ってキー状態を判定してください。
     */
    KRKeyState      getKeyState();

    /*!
        @method getKeyStateAgainstDummy
        @abstract ダミー入力が設定されている際に、ユーザからの現在のキー入力状態を取得します。
        すべてのキー入力情報がビット単位で含まれた整数がリターンされるので、論理積 (AND) 演算を行ってキー状態を判定してください。
     */
    KRKeyState      getKeyStateAgainstDummy();

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
        @method getTouchAgainstDummy
        @abstract ダミー入力が設定されている際に、現在画面がタッチされているかどうかを取得します。
     */
    bool            getTouchAgainstDummy();

    /*!
        @method getTouchOnce
        @abstract 現在画面がタッチされているかどうかを取得します。
        <p>あるフレームでタッチされていると判定されると、それ以降のフレームで指が離されてタッチし直されるまで、この関数が true を返すことはありません。</p>
        <p>この関数は、複数のタッチを識別しません。</p>
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
    void    processMouseDrag() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    processMouseUp(KRMouseState mouseMask) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    
private:
    void    processMouseDownImpl(KRMouseState mouseMask) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    processMouseDragImpl(const KRVector2D& pos=KRVector2DZero) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    processMouseUpImpl(KRMouseState mouseMask) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    processMouseDownImplAgainstDummy(KRMouseState mouseMask) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    processMouseUpImplAgainstDummy(KRMouseState mouseMask) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
#endif

    
#pragma mark -
#pragma mark Support for Keyboard Input (Mac OS X) <Framework Internal>

#if KR_MACOSX
public:
    void    processKeyDownCode(unsigned short keyCode) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    processKeyUpCode(unsigned short keyCode) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    
private:
    void    processKeyDown(KRKeyState keyMask) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    processKeyUp(KRKeyState keyMask) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    processKeyDownAgainstDummy(KRKeyState keyMask) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    processKeyUpAgainstDummy(KRKeyState keyMask) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
#endif
    

#pragma mark -
#pragma mark Support for Touch Input (iPhone) <Framework Internal>

#if KR_IPHONE
public:
    void    startTouch(unsigned touchID, double x, double y) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    moveTouch(unsigned touchID, double x, double y, double dx, double dy) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    endTouch(unsigned touchID, double x, double y, double dx, double dy) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

private:
    void    startTouchImpl(unsigned touchID, double x, double y) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    moveTouchImpl(unsigned touchID, double x, double y, double dx, double dy) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    endTouchImpl(unsigned touchID, double x, double y, double dx, double dy) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;    
    void    startTouchImplAgainstDummy(unsigned touchID, double x, double y) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    endTouchImplAgainstDummy(unsigned touchID, double x, double y, double dx, double dy) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;    
#endif
    
    
#pragma mark -
#pragma mark Support for Accelerometer (iPhone) <Framework Internal>

#if KR_IPHONE
public:
    // These methods are intended to be used with KarakuriGLView class.
    void    setAcceleration(double x, double y, double z) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

private:
    void    setAccelerationImpl(double x, double y, double z) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
#endif

    
#pragma mark -
#pragma mark Dummy Input Support
    
public:
    void    plugDummySourceIn() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    pullDummySourceOut() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void    processDummyData(KRInputSourceData& data) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

    
#pragma mark -
#pragma mark "Once" Support
public:
    void    _updateOnceInfo() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

    
#pragma mark -
#pragma mark Debug Support

public:
    void    resetAllInputs() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

#pragma mark -
#pragma mark Debug Support

public:
    std::string to_s() const;

};


/*!
    @var gKRInputInst
    @group Game Foundation
    @abstract 入力クラスのインスタンスを指す変数です。
    この変数が指し示すオブジェクトは、ゲーム実行の最初から最後まで絶対に変わりません。
 */
extern KRInput *gKRInputInst;


