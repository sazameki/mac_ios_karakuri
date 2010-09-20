/*
 *  KRGraphics.cpp
 *  Karakuri Prototype
 *
 *  Created by numata on 09/07/18.
 *  Copyright 2009 Satoshi Numata. All rights reserved.
 *
 */

#include <Karakuri/KRGraphics.h>
#include <Karakuri/KRTexture2D.h>
#include <Karakuri/KRPrimitive2D.h>


KRGraphics *gKRGraphicsInst = NULL;

KRGraphics::KRGraphics()
{
    gKRGraphicsInst = this;
}

void KRGraphics::clear(const KRColor& color) const
{
    if (_KRIsFullScreen) {
        KRPrimitive2D::fillQuad(KRRect2D(0, 0, gKRScreenSize.x, gKRScreenSize.y), color);
    } else {
        color.setAsClearColor();
        glClear(GL_COLOR_BUFFER_BIT/* | GL_DEPTH_BUFFER_BIT*/);
    }
}

void KRGraphics::setupDefaultSetting()
{
    setBlendMode(KRBlendModeAlpha);
}


KRBlendMode KRGraphics::getBlendMode() const
{
    return mBlendMode;
}

void KRGraphics::setBlendMode(KRBlendMode mode)
{
    if (mBlendMode == mode) {
        return;
    }
    mBlendMode = mode;
    reflectBlendMode();
}

void KRGraphics::reflectBlendMode()
{
    _KRTexture2D::processBatchedTexture2DDraws();
    switch (mBlendMode) {
        case KRBlendModeAlpha:
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            break;
        case KRBlendModeAddition:
            glBlendFunc(GL_SRC_ALPHA, GL_ONE);
            break;
        case KRBlendModeMultiplication:
            glBlendFunc(GL_ZERO, GL_SRC_COLOR);
            break;
        case KRBlendModeInversion:
            glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ZERO);
            break;
        case KRBlendModeScreen:
            glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ONE);
            break;
        case KRBlendModeXOR:
            glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ONE_MINUS_SRC_COLOR);
            break;
        case KRBlendModeCopy:
            glBlendFunc(GL_ONE, GL_ZERO);
            break;
    }
}

std::string KRGraphics::to_s() const
{
    return "<graphics>()";
}


