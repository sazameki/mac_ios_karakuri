/*!
    @file   KRFPSDisplay.cpp
    @author numata
    @date   09/08/06
 */

#include "KRFPSDisplay.h"

#include <Karakuri/KRFont.h>
#include <Karakuri/KRTexture2D.h>
#include <Karakuri/KRGraphics.h>
#include <Karakuri/KRGameManager.h>


/*!
    @method KRFPSDisplay
    Constructor
 */
KRFPSDisplay::KRFPSDisplay()
{
    mFont = new KRFont("Helvetica-Bold", 24.0);

    mNumberTex = mFont->createStringTexture("0123456789");
    mNumberSize = mNumberTex->getSize();
    mNumberSize.x /= 10;

    mPointTex = mFont->createStringTexture(".");
    mFPSTex = mFont->createStringTexture("fps");
    mTPFTex = mFont->createStringTexture("tpf");
    mBPFTex = mFont->createStringTexture("bpf");
    mCPFTex = mFont->createStringTexture("cpf");
}

/*!
    @method ~KRFPSDisplay
    Destructor
 */
KRFPSDisplay::~KRFPSDisplay()
{
    delete mFont;
    delete mNumberTex;
    delete mPointTex;
    delete mFPSTex;
    delete mTPFTex;
    delete mBPFTex;
    delete mCPFTex;
}

void KRFPSDisplay::drawFPS(double x, double y, double fps)
{
    gKRGraphicsInst->setBlendMode(KRBlendModeAlpha);

    std::string str = KRFS("%3.1f", fps);
    
    double width = 0.0;
    if (x > gKRScreenSize.x/2) {
        width = str.length() * mNumberSize.x + mFPSTex->getWidth();
    }
    
    int i;
    
    for (i = 0; i < str.length(); i++) {
        char c = str[i];
        if (c >= '0' && c <= '9') {
            KRRect2D atlasRect((c - '0') * mNumberSize.x, 0, mNumberSize.x, mNumberSize.y);
            mNumberTex->drawAtPointEx_(KRVector2D(x + i * mNumberSize.x + 1 - width, y - 1), atlasRect, 0.0, KRVector2DZero, KRVector2DOne, KRColor::Black);
            mNumberTex->drawAtPointEx_(KRVector2D(x + i * mNumberSize.x - width, y), atlasRect, 0.0, KRVector2DZero, KRVector2DOne, KRColor::White);
        } else {
            mPointTex->drawAtPoint_(KRVector2D(x + i * mNumberSize.x + 1 - width, y - 1), KRColor::Black);
            mPointTex->drawAtPoint_(KRVector2D(x + i * mNumberSize.x - width, y), KRColor::White);
        }
    }
    mFPSTex->drawAtPoint_(KRVector2D(x + i * mNumberSize.x + 5 + 1 - width, y - 1), KRColor::Black);
    mFPSTex->drawAtPoint_(KRVector2D(x + i * mNumberSize.x + 5 - width, y), KRColor::White);
}

void KRFPSDisplay::drawTPF(double x, double y, double tpf)
{
    gKRGraphicsInst->setBlendMode(KRBlendModeAlpha);

    std::string str = KRFS("%3.1f", tpf);
    
    double width = 0.0;
    if (x > gKRScreenSize.x/2) {
        width = str.length() * mNumberSize.x + mFPSTex->getWidth();
    }
    
    int i;
    
    for (i = 0; i < str.length(); i++) {
        char c = str[i];
        if (c >= '0' && c <= '9') {
            KRRect2D atlasRect((c - '0') * mNumberSize.x, 0, mNumberSize.x, mNumberSize.y);
            mNumberTex->drawAtPointEx_(KRVector2D(x + i * mNumberSize.x + 1 - width, y - 1), atlasRect, 0.0, KRVector2DZero, KRVector2DOne, KRColor::Black);
            mNumberTex->drawAtPointEx_(KRVector2D(x + i * mNumberSize.x - width, y), atlasRect, 0.0, KRVector2DZero, KRVector2DOne, KRColor::White);
        } else {
            mPointTex->drawAtPoint_(KRVector2D(x + i * mNumberSize.x + 1 - width, y - 1), KRColor::Black);
            mPointTex->drawAtPoint_(KRVector2D(x + i * mNumberSize.x - width, y), KRColor::White);
        }
    }
    mTPFTex->drawAtPoint_(KRVector2D(x + i * mNumberSize.x + 5 + 1 - width, y - 1), KRColor::Black);
    mTPFTex->drawAtPoint_(KRVector2D(x + i * mNumberSize.x + 5 - width, y), KRColor::White);
}

void KRFPSDisplay::drawBPF(double x, double y, double bpf)
{
    gKRGraphicsInst->setBlendMode(KRBlendModeAlpha);
    
    std::string str = KRFS("%3.1f", bpf);
    
    double width = 0.0;
    if (x > gKRScreenSize.x/2) {
        width = str.length() * mNumberSize.x + mFPSTex->getWidth();
    }
    
    int i;
    
    for (i = 0; i < str.length(); i++) {
        char c = str[i];
        if (c >= '0' && c <= '9') {
            KRRect2D atlasRect((c - '0') * mNumberSize.x, 0, mNumberSize.x, mNumberSize.y);
            mNumberTex->drawAtPointEx_(KRVector2D(x + i * mNumberSize.x + 1 - width, y - 1), atlasRect, 0.0, KRVector2DZero, KRVector2DOne, KRColor::Black);
            mNumberTex->drawAtPointEx_(KRVector2D(x + i * mNumberSize.x - width, y), atlasRect, 0.0, KRVector2DZero, KRVector2DOne, KRColor::White);
        } else {
            mPointTex->drawAtPoint_(KRVector2D(x + i * mNumberSize.x + 1 - width, y - 1), KRColor::Black);
            mPointTex->drawAtPoint_(KRVector2D(x + i * mNumberSize.x - width, y), KRColor::White);
        }
    }
    mBPFTex->drawAtPoint_(KRVector2D(x + i * mNumberSize.x + 5 + 1 - width, y - 1), KRColor::Black);
    mBPFTex->drawAtPoint_(KRVector2D(x + i * mNumberSize.x + 5 - width, y), KRColor::White);
}

void KRFPSDisplay::drawCPF(double x, double y, double cpf)
{
    gKRGraphicsInst->setBlendMode(KRBlendModeAlpha);
    
    std::string str = KRFS("%3.1f", cpf);
    
    double width = 0.0;
    if (x > gKRScreenSize.x/2) {
        width = str.length() * mNumberSize.x + mFPSTex->getWidth();
    }
    
    int i;
    
    for (i = 0; i < str.length(); i++) {
        char c = str[i];
        if (c >= '0' && c <= '9') {
            KRRect2D atlasRect((c - '0') * mNumberSize.x, 0, mNumberSize.x, mNumberSize.y);
            mNumberTex->drawAtPointEx_(KRVector2D(x + i * mNumberSize.x + 1 - width, y - 1), atlasRect, 0.0, KRVector2DZero, KRVector2DOne, KRColor::Black);
            mNumberTex->drawAtPointEx_(KRVector2D(x + i * mNumberSize.x - width, y), atlasRect, 0.0, KRVector2DZero, KRVector2DOne, KRColor::White);
        } else {
            mPointTex->drawAtPoint_(KRVector2D(x + i * mNumberSize.x + 1 - width, y - 1), KRColor::Black);
            mPointTex->drawAtPoint_(KRVector2D(x + i * mNumberSize.x - width, y), KRColor::White);
        }
    }
    mCPFTex->drawAtPoint_(KRVector2D(x + i * mNumberSize.x + 5 + 1 - width, y - 1), KRColor::Black);
    mCPFTex->drawAtPoint_(KRVector2D(x + i * mNumberSize.x + 5 - width, y), KRColor::White);
}

std::string KRFPSDisplay::to_s() const
{
    return "<fps_disp>()";
}


