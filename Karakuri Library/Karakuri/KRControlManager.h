/*!
    @file   KRControlManager.h
    @author numata
    @date   09/08/28
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>
#include <Karakuri/KRControl.h>
#include <Karakuri/KRGraphics.h>
#include <Karakuri/KRInput.h>


class KRControlManager {

private:
    std::vector<KRControl *>    mControls;
    KRControl                   *mSelectedControl;

public:
	KRControlManager();
	virtual ~KRControlManager();

public:
    void    addControl(KRControl *aControl, int groupID);
    void    removeAllControls();
    void    removeControl(KRControl *aControl);

    bool    updateControls(KRInput *input, int groupID);
    void    drawAllControls(KRGraphics *g, int groupID);
    
    void    scrollUpAllDebugLabels();   KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY

};

