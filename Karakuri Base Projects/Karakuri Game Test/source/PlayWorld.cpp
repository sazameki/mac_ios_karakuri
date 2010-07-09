/*!
    @file   PlayWorld.cpp
    @author numata
    @date   10/02/13
 */

#include "PlayWorld.h"
#include "Globals.h"
#include "Enemy1.h"


void PlayWorld::becameActive()
{
    if (!hasLoadedResourceGroup(GroupID::Play)) {
        startLoadingWorld("load", 2.0);
        loadResourceGroup(GroupID::Play);
        finishLoadingWorld();
    }

    mDraggingPlayer = NULL;

    Player* p1 = new Player();
    p1->setCenterPos(KRVector2D(100, 100));
    gKRAnime2DMan->addChara2D(p1);
    
    Player* p2 = new Player();
    p2->setCenterPos(gKRScreenSize - KRVector2D(100, 100));
    gKRAnime2DMan->addChara2D(p2);
    
    for (int i = 0; i < 200; i++) {
        Enemy* enemy = new Enemy1();
        enemy->setCenterPos(KRVector2D(KRRandInt(480), KRRandInt(320)));
        mEnemies.push_back(enemy);
        gKRAnime2DMan->addChara2D(enemy);
    }

#if KR_IPHONE
    ///// To enable accelerometer, remove the comment out below.
    ///// (Don't forget to disable it afterwards)
    //gKRInputInst->enableAccelerometer(true);
#endif
}

void PlayWorld::resignedActive()
{
    // Remove all characters.
    gKRAnime2DMan->removeAllCharas();
    
#if KR_IPHONE
    ///// Disabling accelerometer
    ///// (Required if it was enabled)
    //gKRInputInst->enableAccelerometer(false);
#endif
}

void PlayWorld::updateModel(KRInput* input)
{
    bool isTouched = false;
    KRVector2D touchPos;
    
#if KR_MACOSX
    if (input->isMouseDown()) {
        isTouched = true;
        touchPos = input->getMouseLocation();
    }
#endif
    
#if KR_IPHONE
    if (input->getTouch()) {
        isTouched = true;
        touchPos = input->getTouchLocation();
    }
#endif

    for (std::list<Enemy*>::iterator it = mEnemies.begin(); it != mEnemies.end();) {
        (*it)->move();
        KRChara2D* hitPlayer = gKRAnime2DMan->hitChara2D(CharaType::Player, HitType::Block, *it, HitType::Attack);
        if (hitPlayer != NULL) {
            gKRAnime2DMan->playChara2DCenter(CharaID::Explosion, 0, (*it)->getCenterPos(), 10);
            
            Enemy* enemy = *it;
            it = mEnemies.erase(it);
            gKRAnime2DMan->removeChara2D(enemy);
        } else {
            it++;
        }
    }
    
    if (isTouched) {        
        if (mDraggingPlayer == NULL) {
            // Get an animating character at the touch position
            KRChara2D* theChara = gKRAnime2DMan->getChara2D(CharaType::Player, touchPos);
            
            // Check the model type mapped for the character
            if (theChara != NULL) {
                // Get the model object.
                mDraggingPlayer = (Player*)theChara;
            }

            // Scale up when grabbed
            if (mDraggingPlayer != NULL) {
                mDraggingPlayer->grab(true);
            }
        }
        
        // Move the position
        if (mDraggingPlayer != NULL) {
            mDraggingPlayer->setCenterPos(touchPos);
        }
    } else if (mDraggingPlayer != NULL) {
        mDraggingPlayer->grab(false);
        mDraggingPlayer = NULL;
    }
}

void PlayWorld::drawView(KRGraphics* g)
{
    g->clear(KRColor::CornflowerBlue);
    
    gKRAnime2DMan->draw();
}


