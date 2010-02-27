/*!
    @file   GameMain.cpp
    @author numata
    @date   10/02/13
 */

#include "GameMain.h"
#include "Globals.h"

#include "LogoWorld.h"
#include "LoadingWorld.h"
#include "TitleWorld.h"
#include "PlayWorld.h"


GameMain::GameMain()
{
    ///// Main Settings

    setTitle("My Karakuri Game");           // Game title (Mac only)

    setScreenSize(480, 320);                // iPhone Size (Horizontal use)
    //setScreenSize(320, 480);                // iPhone Size (Vertical use)
    //setScreenSize(1024, 768);               // iPad size (Horizontal use)
    //setScreenSize(768, 1024);               // iPad size (Vertical use)

    setFrameRate(60.0);                     // Refresh rate
    setMaxChara2DCount(1024);               // Max Animation Character Count
    setAudioMixType(KRAudioMixTypeAmbient); // Audio mixing

    setShowsMouseCursor(true);              // Mouse cursor should be shown (Mac only)
    setShowsFPS(true);                      // Realtime FPS information (debug build only)

    // TODO: Edit "Target" setting to change the bundle name, which will be shown in Finder or iPhone Desktop.

    ///// Add any code here for creating your objects
}

GameMain::~GameMain()
{
    // Add any code here for cleaning up your objects
}

void GameMain::setupResources()
{
    // Logo and Loading Worlds
    gTex_Logo   = gKRTex2DMan->addTexture(0, checkDeviceType(KRDeviceTypeIPad)? "Default-Portrait.png": "Default.png");
    gTex_Test   = gKRTex2DMan->addTexture(0, "test.png", KRTexture2DScaleModeLinear);
    gTex_LoadingChara = gKRTex2DMan->addTexture(0, "chara.png");

    // Title World
    gBGM_Op     = gKRAudioMan->addBGM(1, "OMT004_31B003.m4a");   // Title world
    //gBGM_Play   = gKRAudioMan->addBGM(1, "bgm2.caf");   // Play world
    //gBGM_Danger = gKRAudioMan->addBGM(1, "bgm3.caf");   // Play world
    
    gParticle1  = gKRAnime2DMan->addParticleSystem(1, "chara.png", -1);
    gKRAnime2DMan->setParticleLife(gParticle1, 260);

    // Play World
    gKRAnime2DMan->addCharaSpecs(2, "chara2d.spec");
    gSE_Hit     = gKRAudioMan->addSE(2, "A5_02035.AIF");  // Play world
    
    gSimulator1 = gKRAnime2DMan->addSimulator(KRVector2D(0, 100));
    
    // Load logo and loading worlds resources
    loadResourceGroup(0);
}

std::string GameMain::setupWorlds()
{
    // Add world instances with name
    addWorld("logo", new LogoWorld());
    addWorld("load", new LoadingWorld());
    addWorld("title", new TitleWorld());
    addWorld("play", new PlayWorld());
    
    // Return name of the world selected at first
    return "logo";
}


