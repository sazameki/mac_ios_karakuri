/*
 *  KRAudioManager.cpp
 *  Karakuri Library
 *
 *  Created by numata on 10/02/13.
 *  Copyright 2010 Apple Inc. All rights reserved.
 *
 */

#include "KRAudioManager.h"
#include "KRWorld.h"


KRAudioManager*     gKRAudioMan = NULL;


KRAudioManager::KRAudioManager()
{
    gKRAudioMan = this;
    
    mCurrentBGM = NULL;
}

KRAudioManager::~KRAudioManager()
{
    // Do nothing
}


#pragma mark -
#pragma mark オーディオファイルの管理

void KRAudioManager::addBGM(int groupID, int bgmID, const std::string& audioFileName)
{
    // TODO: bgmID が登録済みかどうかを、DEBUG 時にチェックする。
    
    std::vector<int>& theBGMIDList = mBGM_GroupID_BGMIDList_Map[groupID];
    theBGMIDList.push_back(bgmID);
    
    mBGM_BGMID_AudioFileName_Map[bgmID] = audioFileName;
}

void KRAudioManager::addSE(int groupID, int seID, const std::string& audioFileName)
{
    // TODO: seID が登録済みかどうかを、DEBUG 時にチェックする。

    std::vector<int>& theSEIDList = mSE_GroupID_SEIDList_Map[groupID];
    theSEIDList.push_back(seID);
    
    mSE_SEID_AudioFileName_Map[seID] = audioFileName;
}


#pragma mark -
#pragma mark リソースの管理

int KRAudioManager::_getResourceSizeInGroup(int groupID)
{
    int ret = 0;
    
    std::vector<int>& theBGMIDList = mBGM_GroupID_BGMIDList_Map[groupID];
    std::vector<int>& theSEIDList = mSE_GroupID_SEIDList_Map[groupID];

    for (std::vector<int>::const_iterator it = theBGMIDList.begin(); it != theBGMIDList.end(); it++) {
        int bgmID = *it;
        std::string filename = mBGM_BGMID_AudioFileName_Map[bgmID];
        int resourceSize = KRMusic::getResourceSize(filename);
        ret += resourceSize;
    }
    
    for (std::vector<int>::const_iterator it = theSEIDList.begin(); it != theSEIDList.end(); it++) {
        int seID = *it;
        std::string filename = mSE_SEID_AudioFileName_Map[seID];
        int resourceSize = KRSound::getResourceSize(filename);
        ret += resourceSize;
    }

    return ret;
}

void KRAudioManager::_loadAudioFilesInGroup(int groupID, KRWorld* loaderWorld, double minDuration)
{
    std::vector<int>& theBGMIDList = mBGM_GroupID_BGMIDList_Map[groupID];
    std::vector<int>& theSEIDList = mSE_GroupID_SEIDList_Map[groupID];
    
    int allResourceSize = 0;
    NSTimeInterval sleepTime = 0.2;

    for (std::vector<int>::const_iterator it = theBGMIDList.begin(); it != theBGMIDList.end(); it++) {
        int bgmID = *it;
        std::string filename = mBGM_BGMID_AudioFileName_Map[bgmID];
        int resourceSize = KRMusic::getResourceSize(filename);
        allResourceSize += resourceSize;
    }

    for (std::vector<int>::const_iterator it = theSEIDList.begin(); it != theSEIDList.end(); it++) {
        int seID = *it;
        std::string filename = mSE_SEID_AudioFileName_Map[seID];
        int resourceSize = KRSound::getResourceSize(filename);
        allResourceSize += resourceSize;
    }
        
    for (std::vector<int>::const_iterator it = theBGMIDList.begin(); it != theBGMIDList.end(); it++) {
        int bgmID = *it;
        std::string filename = mBGM_BGMID_AudioFileName_Map[bgmID];
        int resourceSize = KRMusic::getResourceSize(filename);
        double theMinDuration = ((double)resourceSize / allResourceSize) * minDuration;
        
        int baseFinishedSize = 0;
        if (loaderWorld != NULL) {
            baseFinishedSize = loaderWorld->_getFinishedSize();
        }

        NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
        if (mBGMMap[bgmID] == NULL) {
            mBGMMap[bgmID] = new KRMusic(filename, true);
        }
        NSTimeInterval loadTime = [NSDate timeIntervalSinceReferenceDate] - startTime;

        double progress = loadTime / theMinDuration;
        if (loaderWorld != NULL) {
            if (progress < 1.0) {
                while (progress < 1.0) {
                    loaderWorld->_setFinishedSize(baseFinishedSize + progress * resourceSize);
                    [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:sleepTime]];
                    loadTime += sleepTime;
                    progress = loadTime / theMinDuration;
                }
            }
            int resourceSize = KRMusic::getResourceSize(filename);
            loaderWorld->_setFinishedSize(baseFinishedSize + resourceSize);
        }
    }

    for (std::vector<int>::const_iterator it = theSEIDList.begin(); it != theSEIDList.end(); it++) {
        int seID = *it;
        std::string filename = mSE_SEID_AudioFileName_Map[seID];
        int resourceSize = KRMusic::getResourceSize(filename);
        double theMinDuration = ((double)resourceSize / allResourceSize) * minDuration;

        int baseFinishedSize = 0;
        if (loaderWorld != NULL) {
            baseFinishedSize = loaderWorld->_getFinishedSize();
        }
        
        NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
        if (mSEMap[seID] == NULL) {
            mSEMap[seID] = new KRSound(filename, false);
        }
        NSTimeInterval loadTime = [NSDate timeIntervalSinceReferenceDate] - startTime;

        double progress = loadTime / theMinDuration;
        if (loaderWorld != NULL) {
            if (progress < 1.0) {
                while (progress < 1.0) {
                    loaderWorld->_setFinishedSize(baseFinishedSize + progress * resourceSize);
                    [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:sleepTime]];
                    loadTime += sleepTime;
                    progress = loadTime / theMinDuration;
                }
            }
            int resourceSize = KRMusic::getResourceSize(filename);
            loaderWorld->_setFinishedSize(baseFinishedSize + resourceSize);
        }
    }
}

void KRAudioManager::_unloadAudioFilesInGroup(int groupID)
{
}

double KRAudioManager::getBGMVolume() const
{
    if (mCurrentBGM == NULL) {
        return 0.0;
    }

    return mCurrentBGM->getVolume();
}

int KRAudioManager::getPlayingBGM() const
{
    if (mCurrentBGM == NULL) {
        return -1;
    }
    return mCurrentBGM->_getBGMID();
}

bool KRAudioManager::isPlayingBGM() const
{
    if (mCurrentBGM == NULL) {
        return false;
    }
    
    return mCurrentBGM->isPlaying();
}

void KRAudioManager::playBGM(int bgmID, double volume)
{
    if (mCurrentBGM != NULL) {
        stopBGM();
    }
    
    // IDからBGMを引っ張ってくる。
    mCurrentBGM = mBGMMap[bgmID];
    
    // BGMが読み込まれていない場合はエラーを表示
    if (mCurrentBGM == NULL) {
        const char *errorFormat = "BGM with ID %d is not loaded.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "ID が %d の BGM は読み込まれていません。";
        }
        throw KRRuntimeError(errorFormat, bgmID);
    }    

    setBGMVolume(volume);
    mCurrentBGM->play();
}

void KRAudioManager::pauseBGM()
{
    if (mCurrentBGM == NULL || !mCurrentBGM->isPlaying()) {
        return;
    }
    
    mCurrentBGM->pause();
}

void KRAudioManager::resumeBGM()
{
    if (mCurrentBGM == NULL || mCurrentBGM->isPlaying()) {
        return;
    }

    mCurrentBGM->play();
}

void KRAudioManager::setBGMVolume(double volume)
{
    if (mCurrentBGM == NULL) {
        return;
    }
    
    mCurrentBGM->setVolume(volume);
}

void KRAudioManager::stopBGM()
{
    if (mCurrentBGM == NULL) {
        return;
    }

    mCurrentBGM->stop();
}

void KRAudioManager::playSE(int seID, double volume, const KRVector3D& sourcePos)
{
    // IDからSEを引っ張ってくる。
    KRSound* theSound = mSEMap[seID];

    // SEが見つからなかったときはエラー
    if (theSound == NULL) {
        const char *errorFormat = "SE with ID %d is not loaded.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "ID が %d の SE は読み込まれていません。";
        }
        throw KRRuntimeError(errorFormat, seID);
    }
    
    // ボリュームの設定
    theSound->setVolume(volume);
    
    // 3次元音場の設定
    theSound->setSourcePos(sourcePos);
    
    // 再生
    theSound->play();    
}

KRVector3D KRAudioManager::getSEListenerPos() const
{
    return KRSound::getListenerPos();
}

void KRAudioManager::setSEListenerPos(const KRVector3D& listenerPos)
{
    KRSound::setListenerPos(listenerPos);
}


