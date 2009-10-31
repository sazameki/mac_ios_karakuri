/*!
    @file   KRControlManager.cpp
    @author numata
    @date   09/08/28
 */

#include "KRControlManager.h"


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
    for (std::vector<KRControl *>::iterator it = mControls.begin(); it != mControls.end();) {
        KRControl *aControl = (KRControl *)(*it);
        it = mControls.erase(it);
        delete aControl;
    }
}

void KRControlManager::addControl(KRControl *aControl)
{
    mControls.push_back(aControl);
}

void KRControlManager::removeControl(KRControl *aControl)
{
    for (std::vector<KRControl *>::iterator it = mControls.begin(); it != mControls.end(); it++) {
        KRControl *theControl = *it;
        if (theControl == aControl) {
            mControls.erase(it);
            break;
        }
    }
}

bool KRControlManager::updateControls(KRInput *input)
{    
    if (mSelectedControl != NULL) {
        if (!mSelectedControl->update(input)) {
            mSelectedControl = NULL;
        }
        return true;
    } else {
        KRVector2D inputPos(-1, -1);
        
#if KR_MACOSX
        if (input->getMouseState() & KRInput::MouseButtonAny) {
            inputPos = input->getMouseLocation();
        }
#endif
#if KR_IPHONE
        if (input->getTouch()) {
            inputPos = input->getTouchLocation();
        }
#endif

        if (inputPos.x >= 0) {
            for (std::vector<KRControl *>::iterator it = mControls.begin(); it != mControls.end(); it++) {
                KRControl *theControl = *it;
                if (theControl->contains(inputPos)) {
                    mSelectedControl = theControl;
                    mSelectedControl->update(input);
                    return true;
                }
            }
        }
    }
    return false;
}

void KRControlManager::drawAllControls(KRGraphics *g)
{
    // TODO: カメラの設定 (3D)

    g->setBlendMode(KRBlendModeAlpha);
    
    for (std::vector<KRControl *>::reverse_iterator it = mControls.rbegin(); it != mControls.rend(); it++) {
        KRControl *theControl = *it;
        if (!theControl->isHidden()) {
            theControl->draw(g);
        }
    }
}


