/*
 *  KRAudioManager.h
 *  Karakuri Library
 *
 *  Created by numata on 10/02/13.
 *  Copyright 2010 Apple Inc. All rights reserved.
 *
 */

#pragma once

#include <Karakuri/KRMusic.h>
#include <Karakuri/KRSound.h>


class KRWorld;


/*!
    @class  KRAudioManager
    @group  Game Audio
    <p>ゲームの BGM と SE を管理するためのクラスです。</p>
    <p>このクラスを利用して再生するファイルの形式については、<a href="../../../../guide/index.html">開発ガイド</a>の「<a href="../../../../guide/sound_format.html">サウンド形式について</a>」を参照してください。</p>
 */
class KRAudioManager {
    
    KRMusic*    mCurrentBGM;
    
    std::map<int, std::vector<int> >    mBGM_GroupID_BGMIDList_Map;
    std::map<int, std::string>          mBGM_BGMID_AudioFileName_Map;

    std::map<int, std::vector<int> >    mSE_GroupID_SEIDList_Map;
    std::map<int, std::string>          mSE_SEID_AudioFileName_Map;

    std::map<int, KRMusic*>  mBGMMap;
    std::map<int, KRSound*>  mSEMap;
    
    int         mNextNewBGMID;
    int         mNextNewSEID;
    
public:
	KRAudioManager();
	virtual ~KRAudioManager();
    
#pragma mark ---- オーディオファイルの管理 ----
public:
    int     addBGM(int groupID, const std::string& audioFileName);
    int     addSE(int groupID, const std::string& audioFileName);
    
#pragma mark ---- リソース管理 ----
public:
    /*!
        @task リソースの管理
     */

    int     getResourceSize(int groupID);
    void    loadAudioFiles(int groupID, KRWorld* loaderWorld, double minDuration);
    void    unloadAudioFiles(int groupID);
    
    
#pragma mark ---- BGM 管理 ----
public:
    double  getBGMVolume() const;
    int     getPlayingBGM() const;
    bool    isPlayingBGM() const;
    void    playBGM(int bgmID, double volume=1.0);
    void    pauseBGM();
    void    resumeBGM();
    void    setBGMVolume(double volume);
    void    stopBGM();
    
#pragma mark ---- SE 管理 ----
public:
    KRVector3D  getSEListenerPos() const;
    void        playSE(int seID, double volume=1.0, const KRVector3D& sourcePos=KRVector3DZero);
    void        setSEListenerPos(const KRVector3D& listenerPos);
    
};


/*!
    @var    gKRAudioMan
    @group  Game Audio
    @abstract オーディオ管理機構のインスタンスを指す変数です。
    この変数が指し示すオブジェクトは、ゲーム実行の最初から最後まで絶対に変わりません。
 */
extern KRAudioManager*    gKRAudioMan;

