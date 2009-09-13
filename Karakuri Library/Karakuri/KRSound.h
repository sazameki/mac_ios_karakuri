/*
 *  KRSound.h
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/23.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>


/*!
    @class  KRSound
    @group  Game Audio
    <p>10秒以下の長さのサウンドファイルを、ゲームの効果音として再生するためのクラスです。</p>
    <p>このクラスを利用して再生するファイルの形式については、サウンド形式についてを参照してください。</p>
 */
class KRSound : public KRObject {
    
private:
    std::string mFileName;
    void        *mSoundImpl;
    KRVector3D  mSourcePos;
    bool        mDoLoop;

public:
    /*!
        @method getListenerHorizontalOrientation
     */
    static  float       getListenerHorizontalOrientation();

    /*!
        @method setListenerHorizontalOrientation
     */
    static  void        setListenerHorizontalOrientation(float radAngle);
    static  KRVector3D  getListenerPos();
    static  void        setListenerPos(float x, float y, float z);
    static  void        setListenerPos(const KRVector3D &vec3);

public:
    KRSound(const std::string& filename, bool doLoop = false);
    ~KRSound();
    
public:
    /*!
        @method play
        @abstract サウンドの再生を開始します。
        このサウンドがすでに再生済みであった場合には、その再生が中断され、頭から再生が再開されます。
     */
    void        play();

    /*!
        @method stop
        @abstract サウンドの再生を中断します。
     */
    void        stop();

    bool        isPlaying() const;
    
    KRVector3D  getSourcePos() const;
    void        setSourcePos(const KRVector3D &vec3);

    float       getPitch() const;
    void        setPitch(float value);

    float       getVolume() const;
    void        setVolume(float value);
    
#pragma mark -
#pragma mark Debug Support

public:
    std::string to_s() const;

};


