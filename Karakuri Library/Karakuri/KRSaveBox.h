//
//  KRSaveBox.h
//  Karakuri Prototype
//
//  Created by numata on 09/07/25.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#pragma once

#import <Karakuri/KarakuriLibrary.h>

void _KRSetupSaveBox();
void _KRCleanUpSaveBox();


#pragma mark -
#pragma mark SaveBox Class Declaration

/*!
    @class  KRSaveBox
    @group  Game System
    @abstract ゲームの実行状態を保存し、読み込み直すためのクラスです。
    このクラスのインスタンスには、gKRSaveBoxInst 変数を利用してアクセスしてください。
 */
class KRSaveBox : public KRObject {

#pragma mark -
#pragma mark Friend Function Declaration

    friend void _KRSetupSaveBox() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    friend void _KRCleanUpSaveBox() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;


#pragma mark -
#pragma mark Constructor / Destructor

private:
    KRSaveBox() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    ~KRSaveBox() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;


#pragma mark -
#pragma mark 値が設定されていることの確認と、保存の実行

public:
    /*!
        @task 値が設定されていることの確認と、保存の実行
     */

    /*!
        @method hasValue
        指定したキーに対応する値が存在することを確認します。
     */
    bool    hasValue(const std::string &key) const;
    
    /*!
        @method save
        @abstract 保存を実行します。
        <p>値を設定したあと、この関数を呼び出すまでは、確実に設定された値が保存されることは保証されません。
        また、この関数が呼び出されなくても、設定された値が保存されることはあります。</p>
     */
    void    save();
    
public:
#pragma mark -
#pragma mark 値の取得
    /*!
        @task 値の取得
     */
    
    /*!
        @method getBoolValue
        名前を指定して bool 値を取得します。
     */
    bool        getBoolValue(const std::string &key) const;

    /*!
        @method getDoubleValue
        名前を指定して double 値を取得します。
     */
    double      getDoubleValue(const std::string &key) const;
    
    /*!
        @method getFloatValue
        名前を指定して float 値を取得します。
     */
    float       getFloatValue(const std::string &key) const;

    /*!
        @method getIntValue
        名前を指定して int 値を取得します。
     */
    int         getIntValue(const std::string &key) const;
    
    /*!
        @method getStringValue
        名前を指定して文字列を取得します。
     */
    std::string getStringValue(const std::string &key) const;
    
public:
#pragma mark -
#pragma mark 値の設定
    /*!
        @task 値の設定
     */
    
    /*!
        @method setBoolValue
        名前を指定して bool 値を保存します。
     */
    void        setBoolValue(const std::string &key, bool boolValue);

    /*!
        @method setDoubleValue
        名前を指定して double 値を保存します。
     */
    void        setDoubleValue(const std::string &key, double doubleValue);
    
    /*!
        @method setFloatValue
        名前を指定して float 値を保存します。
     */
    void        setFloatValue(const std::string &key, float floatValue);

    /*!
        @method setIntValue
        名前を指定して int 値を保存します。
     */
    void        setIntValue(const std::string &key, int intValue);

    /*!
        @method setStringValue
        名前を指定して文字列を保存します。
     */
    void        setStringValue(const std::string &key, const std::string &strValue);

    
#pragma mark -
#pragma mark Debug Support

public:
    std::string to_s() const;

};

/*!
    @var gKRSaveBoxInst
    @group Game System
    @abstract ゲーム状態保存クラスのインスタンスを指す変数です。
 */
extern KRSaveBox    *gKRSaveBoxInst;

