/*
 *  KarakuriException.h
 *  Karakuri Prototype
 *
 *  Created by numata on 07/08/08.
 *  Copyright 2007 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>

#include <stdexcept>


class KRGameExitError : public std::runtime_error {
public:
    KRGameExitError();
    virtual ~KRGameExitError() throw();
};

/*!
    @class KRRuntimeError
    @group Game System
    <p>Karakuri Framework 内で起きるすべてのエラーを表すための例外クラスです。</p>
    <p>このクラスは直接使用せず、サブクラスの KRGameError クラスを利用してください。</p>
 */
class KRRuntimeError : public std::runtime_error {
    
protected:
    std::string mMessage;
    
public:
    KRRuntimeError(const std::string &message);
    KRRuntimeError(const char *format, ...);
    virtual ~KRRuntimeError() throw();

public:
    virtual const char *what() const throw();

};

/*!
    @class KRGameError
    @group Game System
    <p>ゲーム実行中のエラーを表すための例外クラスです。</p>
    <p>ゲーム制作者は、実行時のエラー処理を行うために、この例外クラスあるいはこのクラスから継承した例外クラスをスローしてください。</p>
 */
class KRGameError : public KRRuntimeError {
    
public:
    /*!
        @task コンストラクタ
     */

    /*!
        @method KRGameError
        @abstract エラーメッセージを指定して、エラーを生成します。
     */
    KRGameError(const std::string &message);
    
    /*!
        @method KRGameError
        @abstract エラーメッセージの書式と引数を指定して、エラーを生成します。
     */
    KRGameError(const char *format, ...);

    virtual ~KRGameError() throw();
    
};

/*!
    @-class KRNetworkError
    @group Game Network
    <p>KRNetwork クラスでピアとの通信時に起きたエラーを表すための例外クラスです。</p>
 */
class KRNetworkError : public KRRuntimeError {

public:
    /*!
        @task コンストラクタ
     */

    /*!
        @method KRNetworkError
        @abstract エラーメッセージを指定して、エラーを生成します。
     */
    KRNetworkError(const std::string &message);

    /*!
        @method KRNetworkError
        @abstract エラーメッセージの書式と引数を指定して、エラーを生成します。
     */
    KRNetworkError(const char *format, ...);
    virtual ~KRNetworkError() throw();

};


