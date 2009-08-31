/*------------------------------------------------------------------------*/
/**
 * @file	smsutils.h
 * @brief   Sudden Motion Sensor
 *
 * @author  M.Nukui
 * @date	2006-05-03
 *
 * Copyright (C) 2006 M.Nukui All rights reserved.
 */

/**
 * @page LICENSE ライセンス
 * 
 * ===== LICENSE =====
 * 
 * Copyright 2006 Makoto Nukui. All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, are permitted
 * provided that the following conditions are met:
 * 
 *   1. Redistributions of source code must retain the above copyright notice, this list of conditions
 *   and the following disclaimer.
 * 
 *   2. Redistributions in binary form must reproduce the above copyright notice, this list of
 *   conditions and the following disclaimer in the documentation and/or other materials provided
 *   with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 * 
 */

/**
 * @mainpage smsutils
 * 
 *	SMS（Sudden Motion Sensor Utilties:緊急モーションセンサ）を搭載している MacBook, MacBook Pro, iBook G4, PowerBook G4
 *	のためのユーティリティ
 *
 * @section FUNCTIONS 関数
 *
 * - @ref smsOpen		SMS の IOService をオープンする
 * - @ref smsClose		SMS の IOService をクローズする
 * - @ref smsGetData	SMS のデータを取得
 *
 * @section STRUCTURES 構造体
 *
 * - @ref sms_t			SMS構造体
 * - @ref sms_data_t	SMSデータ構造体
 *
 * @section USAGE 使い方
 *
 * - ヘッダファイル	smsutils.h
 * - 要リンク			IOKit.framework
 *
 * @code
 *
 *	sms_data_t	data;
 *	sms_t		sms;
 *
 *	// SMSサービスのオープン
 *	if (smsOpen(&sms))
 *	{	// エラー
 *		return -1;
 *	}
 *
 *	// データの取得
 *	if (! smsGetData(&sms, &data))
 *	{	// sms.unit を乗ずることにより単位を度に変換していることに注意（機種別の違いを吸収しています）
 *		printf("x = %f, y = %f, z = %f¥n", data.x * sms.unit, data.z * sms.unit, data.z * sms.unit);
 *	}
 *
 *	// SMSサービスのクローズ
 *	smsClose(&sms);
 *
 * @endcode
 *
 * @section LEGAL
 *
 * - @subpage LICENSE
 *
 * @note
 *
 * http://pallit.lhi.is/palli/dashlevel/ の motion.c を参考にさせていただきました。
 * ただし MacBook Pro版 motion.c のデータ構造は間違っているので注意（正しくは x, y, z 各2byte）
 *
 * また SMS の概要は http://osxbook.com/book/bonus/chapter10/ams/ が参考になります。
 */


#ifndef	SMSUTILS_H
#define	SMSUTILS_H


/* ヘッダファイル */
#include <IOKit/IOKitLib.h>
#include <stdint.h>


/* 構造体 */

/// SMSサービスの情報（機種毎）
typedef struct {
	const char *	name;			///< クラス名
	unsigned int	kernFunc;		///< メソッドのインデックス番号
	IOItemCount		inputSize;		///< Input 構造体のサイズ
	IOByteCount		outputSize;		///< Output 構造体のサイズ
	int				type;			///< 構造体の種類
	int				maxValue;		///< データの最大値
} sms_service_t;


/// SMS構造体
typedef struct {
	io_connect_t	connect;		///< 接続しているIOサービス
	sms_service_t *	service;		///< SMSサービスの情報
	float			unit;			///< 単位（乗じると度に変換）
} sms_t;


/// SMSデータ構造体
typedef struct {
	int		x;						///< X軸の傾き
	int		y;						///< Y軸の傾き
	int		z;						///< Z軸の傾き
} sms_data_t;


/* 関数プロトタイプ */

#ifdef __cplusplus
extern "C" {
#endif


kern_return_t smsOpen(sms_t * sms);
kern_return_t smsClose(sms_t * sms);
kern_return_t smsGetData(sms_t * sms, sms_data_t * data);


#ifdef __cplusplus
}
#endif


#endif /* SMSUTILS_H */
