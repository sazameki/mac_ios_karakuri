//
//  KRSaveBox.h
//  Karakuri Prototype
//
//  Created by numata on 09/07/25.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#pragma once

#import <Karakuri/KarakuriLibrary.h>

void KRSetupSaveBox();
void KRCleanUpSaveBox();


#pragma mark -
#pragma mark SaveBox Class Declaration

class KRSaveBox : KRObject {

#pragma mark -
#pragma mark Friend Function Declaration

    friend void KRSetupSaveBox() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    friend void KRCleanUpSaveBox() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;


#pragma mark -
#pragma mark Constructor / Destructor

private:
    KRSaveBox() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    ~KRSaveBox() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;


#pragma mark -
#pragma mark 値が設定されていることの確認と、保存の実行

public:
    bool    hasValue(const std::string &key) const;
    void    save();
    
public:
#pragma mark -
#pragma mark 値の取得
    bool        getBoolValue(const std::string &key) const;
    float       getFloatValue(const std::string &key) const;
    int         getIntValue(const std::string &key) const;
    std::string getStringValue(const std::string &key) const;
    
public:
#pragma mark -
#pragma mark 値の設定
    void        setBoolValue(const std::string &key, bool boolValue);
    void        setFloatValue(const std::string &key, float floatValue);
    void        setIntValue(const std::string &key, int intValue);
    void        setStringValue(const std::string &key, const std::string &strValue);

    
#pragma mark -
#pragma mark Debug Support

public:
    std::string to_s() const;

};

extern KRSaveBox    *KRSaveBoxInst;

