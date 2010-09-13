/*
 *  KRMusic.h
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/23.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>


/*!
    @class  KRMusic
    @group  Game Audio
    @abstract <strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRAudioManager を使用してください。</strong>
    <p>10秒以上の長さのサウンドファイルを、ゲームの BGM として再生するためのクラスです。</p>
    <p>このクラスを利用して再生するファイルの形式については、<a href="../../../../guide/index.html">開発ガイド</a>の「<a href="../../../../guide/sound_format.html">サウンド形式について</a>」を参照してください。</p>
    <p>基本的な使い方としては、<a href="../../../Game Foundation/Classes/KRWorld/index.html#//apple_ref/cpp/cl/KRWorld">KRWorld</a> クラスの becameActive() 関数の最後で play() 関数を呼び出して BGM の再生を開始します。</p>
 */
class KRMusic : public KRObject {
    
private:
    std::string mFileName;
    void*       mImpl;
    bool        mDoLoop;
    bool        mIsPausing;
    int         mBGMID;
    
public:
    static int  getResourceSize(const std::string& filename);
    
public:
    /*!
        @task コンストラクタ
     */
    
    /*!
        @method KRMusic
        @abstract ファイル名（拡張子含む）を指定して、BGM再生用のインスタンスを作成します。
        デフォルトではループ再生しますが、第2引数に false を指定するとループ再生しないようになります。
     */
    KRMusic(const std::string& filename, bool loop=true);
    ~KRMusic();
    
public:
    void    prepareToPlay() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
        
    /*!
        @task 基本の操作
     */

    /*!
        @method play
        @abstract   BGM の再生を開始します。
     */
    void    play();

    /*!
        @method pause
        @abstract   BGM の再生を一時停止します。
     */
    void    pause();

    /*!
        @method stop
        @abstract   BGM の再生を中断します。
        このメソッドの呼び出し後、BGM の再生位置は先頭に戻ります。
     */
    void    stop();

    /*!
        @method isPlaying
        @abstract   BGM が再生中かどうかを取得します。
        @return     BGM が再生中であれば true、そうでなければ false
     */    
    bool    isPlaying() const;

    /*!
        @method getVolume
        @abstract   BGM の現在の音量を取得します。
        @return BGM の現在の音量
     */    
    double  getVolume() const;

    /*!
        @method setVolume
        @abstract   BGM の音量を設定します。
     */    
    void    setVolume(double value);
    
    int     _getBGMID() const;
    void    _setBGMID(int bgmID);

    
#pragma mark -
#pragma mark Debug Support

public:
    std::string to_s() const;

};

