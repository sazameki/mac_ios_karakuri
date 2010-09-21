/*
 *  KarakuriDefines.h
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/18.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include <TargetConditionals.h>


#define KARAKURI_FRAMEWORK_VERSION  "1.5.0"


#if TARGET_OS_IPHONE
    /*!
        @define KR_IPHONE
        @group  Game System
        @abstract iPhone 用のビルドであることを示すマクロです。
        実機用のビルドの場合もシミュレータ用のビルドの場合もこのマクロが定義されます。
     */
    #define KR_IPHONE           1
#endif

#if TARGET_IPHONE_SIMULATOR
    /*!
        @define KR_IPHONE_SIMULATOR
        @group  Game System
        @abstract iPhone シミュレータ用のビルドであることを示すマクロです。
        実機用のビルドの場合にはこのマクロは定義されません。
        このマクロが定義されるときには、KR_IPHONE マクロも同時に定義されます。
     */
    #define KR_IPHONE_SIMULATOR 1
#endif

#if KR_IPHONE && !defined(KR_IPHONE_SIMULATOR)
    /*!
        @define KR_IPHONE_DEVICE
        @group  Game System
        @abstract iPhone 実機用のビルドであることを示すマクロです。
        シミュレータ用のビルドの場合にはこのマクロは定義されません。
        このマクロが定義されるときには、KR_IPHONE マクロも同時に定義されます。
     */
    #define KR_IPHONE_DEVICE    1
#endif

#if KR_MACPHONE_EMU
    #define KR_IPHONE               1
    #define KR_IPHONE_SIMULATOR     1

    /*!
        @define KR_IPHONE_MACOSX_EMU
        @group  Game System
        @abstract Mac OS X 用の iPhone エミュレータ用のビルドであることを示すマクロです。
        このマクロが定義されるときには、KR_IPHONE マクロおよび KR_IPHONE_SIMULATOR マクロも同時に定義されます。
     */
    #define KR_IPHONE_MACOSX_EMU    1
#endif

#ifndef KR_IPHONE
    /*!
        @define KR_MACOSX
        @group  Game Types
        @abstract Mac OS X 用のビルドであることを示すマクロです。
     */
    #define KR_MACOSX           1
#endif


#define KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY 


/*!
    @enum KRDeviceType
    @group Game System
    @constant KRDeviceTypeMac       Mac OS X の実行環境を表す定数です。
    @constant KRDeviceTypeIPhone    iPhone の実行環境を表す定数です。
    @constant KRDeviceTypeIPad      iPad の実行環境を表す定数です。
    現在ゲームを実行している環境を特定するための enum 定数です。KRCheckDeviceType() 関数の引数として使ってください。
 */
typedef enum KRDeviceType {
    KRDeviceTypeMac,
    KRDeviceTypeIPhone,
    KRDeviceTypeIPad,
} KRDeviceType;


