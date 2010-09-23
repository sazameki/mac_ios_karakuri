/*!
    @file   GameMain.cpp
    @author ___FULLUSERNAME___
    @date   ___DATE___
 */

#include "GameMain.h"
#include "Globals.h"

#include "LogoWorld.h"
#include "LoadingWorld.h"
#include "TitleWorld.h"
#include "PlayWorld.h"

#include "Player.h"
#include "Enemy1.h"
#include "Enemy2.h"


GameMain::GameMain()
{
    ///// Title Setting (Game title for the Mac OS X window's title bar. iOS will ignore this setting)

    setTitle("My Karakuri Game");

    
    ///// Size Setting
    
    // iPhone Size (Horizontal use)
    setScreenSize(480, 320);

    // iPhone Size (Vertical use. Don't forget to remove Default.png and rename Default_V.png to Default.png.)
    //setScreenSize(320, 480);

    // iPad size (Horizontal use. Use this size when you want to support both iPhone and iPad. Don't forget to remove Default-Portrait.png.)
    //setScreenSize(1024, 768);
    
    // iPad size (Vertical use. Use this size when you want to support both iPhone and iPad. Don't forget to remove Default-Landscape.png.)
    //setScreenSize(768, 1024);


    ///// Misc Game Settings

    // Refresh rate
    setFrameRate(60.0);

    // Audio mixing (KRAudioMixTypeAmbient or KRAudioMixTypeAmbientSolo)
    //   KRAudioMixTypeAmbient:     iPod music and game sound will be mixed.
    //   KRAudioMixTypeAmbientSolo: Game sound only mode. iPod music will be stopped.
    setAudioMixType(KRAudioMixTypeAmbient);

    // Mouse cursor should be shown (iOS will ignore this setting)
    setShowsMouseCursor(true);

    // Realtime FPS information (Debug build only)
    setShowsFPS(true);

    
    ///// Animation Character Setting

    // Set max animation character count
    setMaxChara2DCount(1024);
    
    // Update max animation character class size
    updateMaxChara2DSize(sizeof(Player));
    updateMaxChara2DSize(sizeof(Enemy1));
    updateMaxChara2DSize(sizeof(Enemy2));
    
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

    // Load integrated resource file.
    addResources("resource.krrs");

    // Logo and Loading Worlds
    if (KRCheckDeviceType(KRDeviceTypeIPad)) {
        gKRTex2DMan->addTexture(GroupID::LogoAndLoading,
                                MyTexID::Logo,
                                (gKRScreenSize.x > gKRScreenSize.y)? "Default-Landscape.png": "Default-Portrait.png");
    } else {
        gKRTex2DMan->addTexture(GroupID::LogoAndLoading, MyTexID::Logo, "Default.png");
    }

    gKRTex2DMan->addTexture(GroupID::LogoAndLoading, MyTexID::LoadingText, "loading_text.png");
    gKRTex2DMan->addTexture(GroupID::LogoAndLoading, MyTexID::LoadingChara, "loading_chara.png");
    gKRTex2DMan->addTexture(GroupID::LogoAndLoading, MyTexID::LoadingOff, "loading_off.png");
    gKRTex2DMan->addTexture(GroupID::LogoAndLoading, MyTexID::LoadingOn, "loading_on.png");
    gKRAudioMan->addBGM(GroupID::LogoAndLoading, BGM_ID::Loading, "bgm_loading.caf");

    // Title World
    gKRTex2DMan->addTexture(GroupID::Title, MyTexID::Title, "title.png");
    gKRAudioMan->addBGM(GroupID::Title, BGM_ID::Title, "bgm_title.caf");

    // Play World
    gKRAudioMan->addBGM(GroupID::Play, BGM_ID::Play, "bgm_play.caf");
    gKRAudioMan->addSE(GroupID::Play, SE_ID::Burn, "se_burn.caf");
    
    // Load logo and loading worlds resources
    loadResourceGroup(GroupID::LogoAndLoading);
}

std::string GameMain::setupWorlds()
{
    // Add world instances with name
    addWorld("logo", new LogoWorld());
    addWorld("load", new LoadingWorld());
    addWorld("title", new TitleWorld());
    addWorld("play", new PlayWorld());
    
    // Return the first world name
    return "logo";
}


