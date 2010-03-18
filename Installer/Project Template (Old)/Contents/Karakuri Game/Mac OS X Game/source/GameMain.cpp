/*!
    @file   GameMain.cpp
    @author ___FULLUSERNAME___
    @date   ___DATE___
 */

#include "GameMain.h"

#include "LogoWorld.h"
#include "PlayWorld.h"


GameMain::GameMain()
{
    // Set up the game title, which will be shown at the title bar of the main window on Mac OS X.
    // Please edit "Target" setting to change the bundle name, which will be shown in Finder or iPhone Desktop.
    // This setting will be ignored on iPhone.
    setTitle("My Karakuri Game");

    // Set up the screen size.
    // System assumes that iPhone will be used horizontally if the screen width is wider than the screen height.
    // System assumes that iPhone will be used vertically otherwise.
    setScreenSize(480, 320);

    // Set up the refresh rate.
    setFrameRate(60.0);
    
    // Set up whether mouse cursor should be shown
    setShowsMouseCursor(true);

    // Set up how audio sounds are mixed.
    setAudioMixType(KRAudioMixTypeAmbientSolo);

    // Set up whether shows real time FPS information (works at debug build only)
    setShowsFPS(true);
}

std::string GameMain::setupWorlds()
{
    // Add world instances with name
    addWorld("logo", new LogoWorld());
    addWorld("play", new PlayWorld());
    
    // Return name of the world selected at first
    return "logo";
}


