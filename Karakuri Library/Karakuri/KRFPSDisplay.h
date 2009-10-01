/*!
    @file   KRFPSDisplay.h
    @author numata
    @date   09/08/06
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>


class KRFont;
class KRTexture2D;
class KRTexture2DAtlas;


class KRFPSDisplay : public KRObject {

    KRFont          *mFont;

    KRTexture2D     *mNumberTex;
    KRTexture2DAtlas    *mNumberAtlas;

    KRTexture2D     *mPointTex;
    KRTexture2D     *mFPSTex;
    KRTexture2D     *mTPFTex;
    KRTexture2D     *mBPFTex;
    
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

