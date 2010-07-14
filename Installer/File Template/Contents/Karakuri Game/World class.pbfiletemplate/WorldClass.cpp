/*!
    @file   «FILENAME»
    @author «FULLUSERNAME»
    @date   «DATE»
 */

/*
    TODO 1: Put this one line at the top of GameMain.cpp.
    #include "«FILEBASENAMEASIDENTIFIER».h"

    TODO 2: Insert this one line at the end of GameMain::setupWorlds() function in GameMain.cpp.
    addWorld("«FILEBASENAMEASIDENTIFIER»", new «FILEBASENAMEASIDENTIFIER»());
 */

#include "«FILEBASENAMEASIDENTIFIER».h"
#include "Globals.h"


void «FILEBASENAMEASIDENTIFIER»::becameActive()
{
    /*if (!hasLoadedResourceGroup(GroupID::Foo)) {
        startLoadingWorld("load", 2.0);
        loadResourceGroup(GroupID::Foo);
        finishLoadingWorld();
    }*/
}

void «FILEBASENAMEASIDENTIFIER»::resignedActive()
{
    //unloadResourceGroup(GroupID::Foo);
}

void «FILEBASENAMEASIDENTIFIER»::updateModel(KRInput* input)
{
    // TODO: Write your own game world logic.
}

void «FILEBASENAMEASIDENTIFIER»::drawView(KRGraphics* g)
{
    g->clear(KRColor::CornflowerBlue);
    
    gKRAnime2DMan->draw();
}

/*void «FILEBASENAMEASIDENTIFIER»::buttonPressed(KRButton* aButton)
 {
 }*/

/*void «FILEBASENAMEASIDENTIFIER»::sliderValueChanged(KRSlider* slider)
 {
 }*/

/*void «FILEBASENAMEASIDENTIFIER»::switchStateChanged(KRSwitch* switcher)
 {
 }*/


