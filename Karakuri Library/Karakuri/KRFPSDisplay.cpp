/*!
    @file   KRFPSDisplay.cpp
    @author numata
    @date   09/08/06
 */

#include "KRFPSDisplay.h"

#include <Karakuri/KRFont.h>
#include <Karakuri/KRTexture2D.h>
#include <Karakuri/KRTexture2DAtlas.h>


/*!
    @method KRFPSDisplay
    Constructor
 */
KRFPSDisplay::KRFPSDisplay()
{
    mFont = new KRFont("Helvetica-Bold", 24.0);

    mNumberTex = mFont->createStringTexture("0123456789");
    mNumberAtlas = new KRTexture2DAtlas(mNumberTex, KRVector2DZero, KRVector2D(mNumberTex->getWidth()/10, mNumberTex->getHeight()));

    mPointTex = mFont->createStringTexture(".");
    mFPSTex = mFont->createStringTexture("fps");
    mTPFTex = mFont->createStringTexture("tpf");
    mBPFTex = mFont->createStringTexture("bpf");
}

/*!
    @method ~KRFPSDisplay
    Destructor
 */
KRFPSDisplay::~KRFPSDisplay()
{
    delete mFont;
    delete mNumberTex;
    delete mNumberAtlas;
    delete mPointTex;
    delete mFPSTex;
    delete mTPFTex;
    delete mBPFTex;
}

void KRFPSDisplay::drawFPS(double x, double y, double fps)
{
    gKRGraphicsInst->setBlendMode(KRBlendModeAlpha);

    std::string str = KRFS("%3.1f", fps);
    
    double width = 0.0;
    if (x > gKRScreenSize.x/2) {
        width = str.length() * mNumberTex->getWidth()/10 + mFPSTex->getWidth();
    }
    
    int i;
    
    for (i = 0; i < str.length(); i++) {
        char c = str[i];
        if (c >= '0' && c <= '9') {
            mNumberAtlas->draw(0, c-'0', KRVector2D(x + i * mNumberTex->getWidth()/10 + 1 - width, y - 1), KRColor::Black);
            mNumberAtlas->draw(0, c-'0', KRVector2D(x + i * mNumberTex->getWidth()/10 - width, y));
        } else {
            mPointTex->draw(x + i * mNumberTex->getWidth()/10 + 1 - width, y - 1, KRColor::Black);
            mPointTex->draw(x + i * mNumberTex->getWidth()/10 - width, y);
        }
    }
    mFPSTex->draw(x + i * mNumberTex->getWidth()/10 + 5 + 1 - width, y - 1, KRColor::Black);
    mFPSTex->draw(x + i * mNumberTex->getWidth()/10 + 5 - width, y);
}

void KRFPSDisplay::drawTPF(double x, double y, double tpf)
{
    gKRGraphicsInst->setBlendMode(KRBlendModeAlpha);

    std::string str = KRFS("%3.1f", tpf);
    
    double width = 0.0;
    if (x > gKRScreenSize.x/2) {
        width = str.length() * mNumberTex->getWidth()/10 + mFPSTex->getWidth();
    }
    
    int i;
    
    for (i = 0; i < str.length(); i++) {
        char c = str[i];
        if (c >= '0' && c <= '9') {
            mNumberAtlas->draw(0, c-'0', KRVector2D(x + i * mNumberTex->getWidth()/10 + 1 - width, y - 1), KRColor::Black);
            mNumberAtlas->draw(0, c-'0', KRVector2D(x + i * mNumberTex->getWidth()/10 - width, y));
        } else {
            mPointTex->draw(x + i * mNumberTex->getWidth()/10 + 1 - width, y - 1, KRColor::Black);
            mPointTex->draw(x + i * mNumberTex->getWidth()/10 - width, y);
        }
    }
    mTPFTex->draw(x + i * mNumberTex->getWidth()/10 + 5 + 1 - width, y - 1, KRColor::Black);
    mTPFTex->draw(x + i * mNumberTex->getWidth()/10 + 5 - width, y);
}

void KRFPSDisplay::drawBPF(double x, double y, double bpf)
{
    gKRGraphicsInst->setBlendMode(KRBlendModeAlpha);
    
    std::string str = KRFS("%3.1f", bpf);
    
    double width = 0.0;
    if (x > gKRScreenSize.x/2) {
        width = str.length() * mNumberTex->getWidth()/10 + mFPSTex->getWidth();
    }
    
    int i;
    
    for (i = 0; i < str.length(); i++) {
        char c = str[i];
        if (c >= '0' && c <= '9') {
            mNumberAtlas->draw(0, c-'0', KRVector2D(x + i * mNumberTex->getWidth()/10 + 1 - width, y - 1), KRColor::Black);
            mNumberAtlas->draw(0, c-'0', KRVector2D(x + i * mNumberTex->getWidth()/10 - width, y));
        } else {
            mPointTex->draw(x + i * mNumberTex->getWidth()/10 + 1 - width, y - 1, KRColor::Black);
            mPointTex->draw(x + i * mNumberTex->getWidth()/10 - width, y);
        }
    }
    mBPFTex->draw(x + i * mNumberTex->getWidth()/10 + 5 + 1 - width, y - 1, KRColor::Black);
    mBPFTex->draw(x + i * mNumberTex->getWidth()/10 + 5 - width, y);
}

std::string KRFPSDisplay::to_s() const
{
    return "<fps_disp>()";
}


