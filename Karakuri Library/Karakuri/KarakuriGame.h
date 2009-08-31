//
//  KarakuriGame.h
//  Karakuri Prototype
//
//  Created by numata on 09/07/17.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#pragma once

#include <Karakuri/KarakuriLibrary.h>

#include <Karakuri/KRGraphics.h>
#include <Karakuri/KRInput.h>
#include <Karakuri/KarakuriWorldManager.h>


typedef enum KRAudioMixType {
    KRAudioMixTypeAmbient,         //!< Mix iPod audio playback and own sound effects
    KRAudioMixTypeAmbientSolo,     //!< Play own background music and own sound effects
} KRAudioMixType;


#pragma mark -
#pragma mark Game Class Declaration

class KarakuriGame : public KRObject {
    std::string     mTitle;
    float           mFrameRate;
    int             mScreenWidth;
    int             mScreenHeight;
    bool            mWasChangingWorld;
    KRAudioMixType  mAudioMixType;
    bool            mShowsMouseCursor;
    bool            mShowsFPS;
    
    std::string     mGameIDForNetwork;
    std::string     mNetworkStartWorldName;
    
    KarakuriWorldManager    *mWorldManager;

    
#pragma mark -
#pragma mark Constructor

public:
    KarakuriGame();
    
public:
    virtual std::string setupWorlds() = 0;
    void    cleanUpGame();
    void    updateModel(KRInput *input);
    void    drawView(KRGraphics *g);
    
public:
    std::string     getTitle() const;
    float           getFrameRate() const;
    int             getScreenWidth() const;
    int             getScreenHeight() const;
    KRVector2D      getScreenSize() const;
    bool            getShowsMouseCursor() const;
    KRAudioMixType  getAudioMixType() const;
    bool            getShowsFPS() const;
    
    std::string     getGameIDForNetwork() const;
    std::string     getNetworkStartWorldName() const;

protected:
    void            setTitle(const std::string& str);
    void            setFrameRate(float value);
    void            setScreenSize(int width, int height);    
    void            setShowsMouseCursor(bool flag);
    void            setAudioMixType(KRAudioMixType type);
    void            setShowsFPS(bool flag);

    void            setNetworkGameID(const std::string& gameID, const std::string& startWorldName);
    
    
#pragma mark -
#pragma mark World Management

protected:
    void            addWorld(const std::string& name, KarakuriWorld *aWorld);
    
public:
    KarakuriWorld   *getWorld(const std::string& name) const;
    KarakuriWorld   *getCurrentWorld() const;
    void            changeWorld(const std::string& name);
    void            exitGame();
    
public:
    void            changeWorldImpl(const std::string& name, bool useLoadingThread = true, bool isFirstInitialization = false) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    void            startWorldChanging() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    
public:
    void            saveForEmergency() KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;
    
#pragma mark -
#pragma mark Debug Support

public:
    std::string     to_s() const;

};

extern KarakuriGame *KRGame;
extern KRVector2D   KRScreenSize;

