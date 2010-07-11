/*!
    @file   KRFPSDisplay.h
    @author numata
    @date   09/08/06
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>


class _KRFont;
class _KRTexture2D;
class _KRTexture2DAtlas;


class KRFPSDisplay : public KRObject {

    _KRFont*            mFont;

    _KRTexture2D*       mNumberTex;
    _KRTexture2DAtlas*  mNumberAtlas;

    _KRTexture2D*       mPointTex;
    _KRTexture2D*       mFPSTex;
    _KRTexture2D*       mTPFTex;
    _KRTexture2D*       mBPFTex;
    
public:
	KRFPSDisplay();
	virtual ~KRFPSDisplay();
    
public:
    void    drawFPS(double x, double y, double fps);
    void    drawTPF(double x, double y, double tpf);
    void    drawBPF(double x, double y, double bpf);

public:
    virtual std::string to_s() const;
    
};

