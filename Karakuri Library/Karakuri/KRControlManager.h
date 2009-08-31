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
    void    addControl(KRControl *aControl);
    void    removeControl(KRControl *aControl);

    bool    updateControls(KRInput *input);
    void    drawAllControls(KRGraphics *g);

};

