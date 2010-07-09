/*!
    @file   KarakuriDebug.h
    @author Satoshi Numata
    @date   10/01/10
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/Karakuri.h>


/*!
    @function KRDebug
    @group Game Foundation
    @abstract 指定された書式で、デバッグ文字列を出力します。書式は printf() 関数と同じ書式を使用します。
    Debug ビルドでのみ有効になります。Release ビルドでは、何も行いません。
 */
void    KRDebug(const char *format, ...);

/*!
    @function KRDebugScreen
    @group Game Foundation
    @abstract 指定された書式で、画面上にデバッグ文字列を出力します。書式は printf() 関数と同じ書式を使用します。
    Debug ビルドでのみ有効になります。Release ビルドでは、何も行いません。
 */
void    KRDebugScreen(const char *format, ...);

/*!
    @function KRDebugScreenClear
    @group Game Foundation
    画面上に表示されたデバッグ文字列を取り除きます。
 */
void    KRDebugScreenClear();


