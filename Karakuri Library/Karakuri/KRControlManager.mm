/*!
    @file   KRControlManager.cpp
    @author numata
    @date   09/08/28
 */

#include "KRControlManager.h"
#include "KRGameManager.h"


/*!
    @method KRControlManager
    Constructor
 */
KRControlManager::KRControlManager()
{
    mSelectedControl = NULL;
}

/*!
    @method ~KRControlManager
    Destructor
 */
KRControlManager::~KRControlManager()
{
    removeAllControls();
}

void KRControlManager::addControl(KRControl* aControl, int groupID)
{
    aControl->setGroupID(groupID);
    mControls.push_back(aControl);
}

void KRControlManager::removeAllControls()
{
    for (std::vector<KRControl*>::iterator it = mControls.begin(); it != mControls.end();) {
        KRControl* aControl = (KRControl*)(*it);
        it = mControls.erase(it);
        delete aControl;
    }    
}

void KRControlManager::removeControl(KRControl* aControl)
{
    for (std::vector<KRControl*>::iterator it = mControls.begin(); it != mControls.end(); it++) {
        KRControl* theControl = *it;
        if (theControl == aControl) {
            mControls.erase(it);
            break;
        }
    }
}

bool KRControlManager::updateControls(KRInput* input, int groupID)
{    
    if (mSelectedControl != NULL) {
        if (!mSelectedControl->update(input)) {
            mSelectedControl = NULL;
        }
        return true;
    } else {
        KRVector2D inputPos(-1, -1);
        
#if KR_MACOSX
        if (input->isMouseDown()) {
            inputPos = input->getMouseLocation();
        }
#endif
#if KR_IPHONE
        if (input->getTouch()) {
            inputPos = input->getTouchLocation();
        }
#endif

        if (inputPos.x >= 0) {
            for (std::vector<KRControl*>::iterator it = mControls.begin(); it != mControls.end(); it++) {
                KRControl* theControl = *it;
                if (theControl->contains(inputPos) && theControl->getGroupID() == groupID &&
                        !theControl->isHidden() && theControl->isEnabled() && theControl->_isUpdatableControl())
                {
                    mSelectedControl = theControl;
                    mSelectedControl->update(input);
                    return true;
                }
            }
        }
    }
    return false;
}

void KRControlManager::drawAllControls(KRGraphics* g, int groupID)
{
    g->setBlendMode(KRBlendModeAlpha);

    for (std::vector<KRControl*>::reverse_iterator it = mControls.rbegin(); it != mControls.rend(); it++) {
        KRControl* theControl = *it;
        if (!theControl->isHidden() && theControl->getGroupID() == groupID) {
            theControl->draw(g);
        }
    }
}

void KRControlManager::scrollUpAllDebugLabels()
{
    for (std::vector<KRControl*>::iterator it = mControls.begin(); it != mControls.end();) {
        KRControl* theControl = *it;
        KRRect2D frame = theControl->getFrame();
        frame.y += 16;
        theControl->setFrame(frame);
        
        if (frame.y >= gKRScreenSize.y) {
            it = mControls.erase(it);
            delete theControl;
        } else {
            it++;
        }
    }
}


