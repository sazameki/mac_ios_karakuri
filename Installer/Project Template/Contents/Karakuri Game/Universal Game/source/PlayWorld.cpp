/*!
    @file   PlayWorld.cpp
    @author ___FULLUSERNAME___
    @date   ___DATE___
 */

#include "PlayWorld.h"
#include "Globals.h"
#include "Enemy1.h"
#include "Enemy2.h"


void PlayWorld::becameActive()
{
    // Use the loading screen for pretty heavy resource loadings.
    if (!hasLoadedResourceGroup(GroupID::Play)) {
        startLoadingWorld("load", 2.0);     // Pass loading screen name and mininum duration for the screen.
        loadResourceGroup(GroupID::Play);
        finishLoadingWorld();
    }
    
    // Play BGM
    gKRAudioMan->playBGM(BGM_ID::Play);

    // Initialize model variables.
    mScore = 0;    
    mDraggingPlayer = NULL;
    
    // Create players. Memory management will be automatically performed by gKRAnime2DMan after adding them into it.
    Player* p1 = new Player();
    p1->setCenterPos(KRVector2D(100, 100));
    gKRAnime2DMan->addChara2D(p1);
    
    Player* p2 = new Player();
    p2->setCenterPos(gKRScreenSize - KRVector2D(100, 100));
    gKRAnime2DMan->addChara2D(p2);
    
    // Create enemies
    for (int i = 0; i < 40; i++) {
        Enemy* enemy;
        if (KRRandInt() % 2 == 0) {
            enemy = new Enemy1();
        } else {
            enemy = new Enemy2();
        }
        enemy->setCenterPos(KRVector2D(KRRandInt(gKRScreenSize.x-20)+10, KRRandInt(gKRScreenSize.y-20)+10));
        mEnemies.push_back(enemy);
        gKRAnime2DMan->addChara2D(enemy);
    }
    
    // Use label for displaying texts.
    mScoreLabel = new KRLabel(KRRect2D(10, gKRScreenSize.y-30, 240, 30));
    mScoreLabel->setText("Score: 0000");
    addControl(mScoreLabel);

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
    
    unloadResourceGroup(GroupID::Play);
    
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

    // Move Enemies
    for (std::list<Enemy*>::iterator it = mEnemies.begin(); it != mEnemies.end();) {
        // Do move
        (*it)->move();

        // Hit test
        KRChara2D* hitPlayer = gKRAnime2DMan->hitChara2D(ClassType::Player, HitType::Attack, *it, HitType::Block);
        if (hitPlayer != NULL) {
            // Add Score
            mScore += 10;
            mScoreLabel->setText(KRFS("Score: %04d", mScore));
            
            // Explosion
            gKRAnime2DMan->playChara2DCenter(CharaID::Explosion, 0, (*it)->getCenterPos(), 10);
            gKRAudioMan->playSE(SE_ID::Burn, 1.0);
            
            // Remove an enemy
            Enemy* enemy = *it;
            it = mEnemies.erase(it);
            gKRAnime2DMan->removeChara2D(enemy);
        } else {
            // Next Enemy
            it++;
        }
    }
    
    if (isTouched) {
        if (mDraggingPlayer == NULL) {
            // Get an animating character at the touch position
            KRChara2D* theChara = gKRAnime2DMan->getChara2D(ClassType::Player, touchPos);

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
            gKRAnime2DMan->generateParticle2D(ParticleID::Smoke, touchPos, -2);
            gKRAnime2DMan->generateParticle2D(ParticleID::Fire, touchPos, -1);
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

/*void PlayWorld::buttonPressed(KRButton* aButton)
 {
 }*/

/*void PlayWorld::sliderValueChanged(KRSlider* slider)
 {
 }*/

/*void PlayWorld::switchStateChanged(KRSwitch* switcher)
 {
 }*/


