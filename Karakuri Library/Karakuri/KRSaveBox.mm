//
//  KRSaveBox.mm
//  Karakuri Prototype
//
//  Created by numata on 09/07/25.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "KRSaveBox.h"

#import <Foundation/Foundation.h>


KRSaveBox *KRSaveBoxInst = NULL;


#pragma mark Save Box のセットアップ

void KRSetupSaveBox()
{
    if (KRSaveBoxInst == NULL) {
        KRSaveBoxInst = new KRSaveBox();
    }
}

void KRCleanUpSaveBox()
{
    if (KRSaveBoxInst != NULL) {
        delete KRSaveBoxInst;
        KRSaveBoxInst = NULL;
    }
}


#pragma mark -
#pragma mark コンストラクタ、デストラクタ

KRSaveBox::KRSaveBox()
{
    // Do nothing
}

KRSaveBox::~KRSaveBox()
{
    // Do nothing
}


#pragma mark -
#pragma mark 値が設定されていることの確認と、保存の実行
bool KRSaveBox::hasValue(const std::string &key) const
{
	NSData *keyStrData = [[NSData alloc] initWithBytes:key.data() length:key.length()];
    NSString *keyStr = [[NSString alloc] initWithData:keyStrData encoding:NSUTF8StringEncoding];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bool ret = ([defaults objectForKey:keyStr] != nil)? true: false;
    
    [keyStr release];
    [keyStrData release];
    
    return ret;
}

void KRSaveBox::save()
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
}


#pragma mark -
#pragma mark 値の取得

bool KRSaveBox::getBoolValue(const std::string &key) const
{
	NSData *keyStrData = [[NSData alloc] initWithBytes:key.data() length:key.length()];
    NSString *keyStr = [[NSString alloc] initWithData:keyStrData encoding:NSUTF8StringEncoding];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bool ret = [defaults boolForKey:keyStr];
    
    [keyStr release];
    [keyStrData release];
    
    return ret;
}

float KRSaveBox::getFloatValue(const std::string &key) const
{
	NSData *keyStrData = [[NSData alloc] initWithBytes:key.data() length:key.length()];
    NSString *keyStr = [[NSString alloc] initWithData:keyStrData encoding:NSUTF8StringEncoding];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float ret = [defaults floatForKey:keyStr];
    
    [keyStr release];
    [keyStrData release];
    
    return ret;
}

int KRSaveBox::getIntValue(const std::string &key) const
{
	NSData *keyStrData = [[NSData alloc] initWithBytes:key.data() length:key.length()];
    NSString *keyStr = [[NSString alloc] initWithData:keyStrData encoding:NSUTF8StringEncoding];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int ret = [defaults integerForKey:keyStr];
    
    [keyStr release];
    [keyStrData release];
    
    return ret;
}

std::string KRSaveBox::getStringValue(const std::string &key) const
{
	NSData *keyStrData = [[NSData alloc] initWithBytes:key.data() length:key.length()];
    NSString *keyStr = [[NSString alloc] initWithData:keyStrData encoding:NSUTF8StringEncoding];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *retObj = [defaults stringForKey:keyStr];
    
    [keyStr release];
    [keyStrData release];
    
    if (!retObj) {
        return "";
    }
    
    return std::string([retObj cStringUsingEncoding:NSUTF8StringEncoding]);
}


#pragma mark -
#pragma mark 値の設定

void KRSaveBox::setBoolValue(const std::string &key, bool boolValue)
{
	NSData *keyStrData = [[NSData alloc] initWithBytes:key.data() length:key.length()];
    NSString *keyStr = [[NSString alloc] initWithData:keyStrData encoding:NSUTF8StringEncoding];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:boolValue forKey:keyStr];
    
    [keyStr release];
    [keyStrData release];
}

void KRSaveBox::setFloatValue(const std::string &key, float floatValue)
{
	NSData *keyStrData = [[NSData alloc] initWithBytes:key.data() length:key.length()];
    NSString *keyStr = [[NSString alloc] initWithData:keyStrData encoding:NSUTF8StringEncoding];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:floatValue forKey:keyStr];
    
    [keyStr release];
    [keyStrData release];
}

void KRSaveBox::setIntValue(const std::string &key, int intValue)
{
	NSData *keyStrData = [[NSData alloc] initWithBytes:key.data() length:key.length()];
    NSString *keyStr = [[NSString alloc] initWithData:keyStrData encoding:NSUTF8StringEncoding];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:intValue forKey:keyStr];
    
    [keyStr release];
    [keyStrData release];
}

void KRSaveBox::setStringValue(const std::string &key, const std::string &strValue)
{
	NSData *keyStrData = [[NSData alloc] initWithBytes:key.data() length:key.length()];
    NSString *keyStr = [[NSString alloc] initWithData:keyStrData encoding:NSUTF8StringEncoding];
    
	NSData *valueStrData = [[NSData alloc] initWithBytes:strValue.data() length:strValue.length()];
    NSString *valueStr = [[NSString alloc] initWithData:valueStrData encoding:NSUTF8StringEncoding];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:valueStr forKey:keyStr];
    
    [valueStr release];
    [valueStrData release];
    
    [keyStr release];
    [keyStrData release];
}


#pragma mark -
#pragma mark デバッグ文字列の作成

std::string KRSaveBox::to_s() const
{
    return "<savebox>()";
}


