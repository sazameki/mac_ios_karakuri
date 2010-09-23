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
    <p>ゲームの BGM と SE を管理するためのクラスです。このクラスのインスタンスには、グローバル変数 gKRAudioMan を使ってアクセスしてください。</p>
    <p>このクラスを利用して再生するファイルの形式については、<a href="../../../../guide/index.html">開発ガイド</a>の「<a href="../../../../guide/sound_format.html">サウンド形式について</a>」を参照してください。</p>
 */
class KRAudioManager : public KRObject {
    
    KRMusic*    mCurrentBGM;
    
    std::map<int, std::vector<int> >    mBGM_GroupID_BGMIDList_Map;
    std::map<int, std::string>          mBGM_BGMID_AudioFileName_Map;

    std::map<int, std::vector<int> >    mSE_GroupID_SEIDList_Map;
    std::map<int, std::string>          mSE_SEID_AudioFileName_Map;

    std::map<int, KRMusic*> mBGMMap;
    std::map<int, KRSound*>  mSEMap;
    
public:
	KRAudioManager();
	virtual ~KRAudioManager();
    
#pragma mark ---- リソースの追加 ----
public:
    /*!
        @task リソースの追加
     */
    
    /*!
        @method addBGM
        グループID、BGM ID を指定して、BGM として利用するオーディオファイルをゲーム・リソースとして追加します。
     */
    void    addBGM(int groupID, int bgmID, const std::string& audioFileName);

    /*!
        @method addSE
        グループID、SE ID を指定して、SE として利用するオーディオファイルをゲーム・リソースとして追加します。
     */
    void    addSE(int groupID, int seID, const std::string& audioFileName);
    
#pragma mark ---- リソースの読み込み ----
public:
    int     _getResourceSizeInGroup(int groupID);
    void    _loadAudioFilesInGroup(int groupID, KRWorld* loaderWorld, double minDuration);
    void    _unloadAudioFilesInGroup(int groupID);
    
    
#pragma mark ---- BGM 管理 ----
public:
    /*!
        @task BGM の管理
     */
    
    /*!
        @method getBGMVolume
        BGM の再生音量を取得します。
     */
    double  getBGMVolume() const;

    /*!
        @method getPlayingBGM
        現在再生している BGM の ID をリターンします。BGM を再生していない場合には、-1 をリターンします。
     */
    int     getPlayingBGM() const;

    /*!
        @method isPlayingBGM
        現在 BGM を再生しているかどうかをリターンします。
     */
    bool    isPlayingBGM() const;

    /*!
        @method playBGM
        ID を指定して、BGM を再生します。オプションで音量を指定できます。
     */
    void    playBGM(int bgmID, double volume=1.0);

    /*!
        @method pauseBGM
        BGM の再生を一時停止します。
     */
    void    pauseBGM();
    
    /*!
        @method resumeBGM
        一時停止していた BGM の再生を再開します。
     */
    void    resumeBGM();

    /*!
        @method setBGMVolume
        現在再生している BGM の音量を設定します。
     */
    void    setBGMVolume(double volume);

    /*!
        @method stopBGM
        BGM の再生を中断します。このメソッドの呼び出し後、BGM の再生位置は先頭に戻ります。
     */
    void    stopBGM();
    
#pragma mark ---- SE 管理 ----
public:
    /*!
        @task SEの管理
     */
    
    /*!
        @method getSEListenerPos
        SE の再生を聞く仮想リスナの3次元位置を取得します。
     */
    KRVector3D  getSEListenerPos() const;
    
    /*!
        @method playSE
        @abstract ID を指定して、SE を再生します。オプションで音量と SE の再生位置を設定できます。
        同じ SE が既に再生されている場合は、その SE の再生が中断され、新しい再生が開始されます。
     */
    void        playSE(int seID, double volume=1.0, const KRVector3D& sourcePos=KRVector3DZero);

    /*!
        @method setSEListenerPos
        SE の再生を聞く仮想リスナの3次元位置を設定します。
     */
    void        setSEListenerPos(const KRVector3D& listenerPos);
    
};


/*!
    @var    gKRAudioMan
    @group  Game Audio
    @abstract オーディオ管理機構のインスタンスを指す変数です。
    この変数が指し示すオブジェクトは、ゲーム実行の最初から最後まで絶対に変わりません。
 */
extern KRAudioManager*    gKRAudioMan;

