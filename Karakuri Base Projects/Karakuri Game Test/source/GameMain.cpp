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
    ///// Add all required resources at this point.

    // Load integrated resource file (* Use Karakuri Box to make it *)
    //addResources("resource.krrs");
    
    // Logo and Loading Worlds
    gTex_Logo   = gKRTex2DMan->addTexture(0, checkDeviceType(KRDeviceTypeIPad)? "Default-Portrait.png": "Default.png");
    gTex_LoadingChara = gKRTex2DMan->addTexture(0, "chara.png");

    // Title World
    gTex_Title = gKRTex2DMan->addTexture(1, "title.png");
    //gBGM_Title = gKRAudioMan->addBGM(1, "title_bgm.caf");

    // Play World
    gKRAnime2DMan->addCharaSpecs(2, "chara2d.spec");
    //gBGM_Play = gKRAudioMan->addBGM(2, "play_bgm.caf");
    //gSE_Hit = gKRAudioMan->addSE(2, "hit.caf");
    
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


