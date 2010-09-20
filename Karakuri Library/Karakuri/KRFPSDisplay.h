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


class KRFPSDisplay : public KRObject {

    _KRFont*            mFont;

    _KRTexture2D*       mNumberTex;
    KRVector2D          mNumberSize;

    _KRTexture2D*       mPointTex;
    _KRTexture2D*       mFPSTex;
    _KRTexture2D*       mTPFTex;
    _KRTexture2D*       mBPFTex;
    _KRTexture2D*       mCPFTex;
    
public:
	KRFPSDisplay();
	virtual ~KRFPSDisplay();
    
public:
    void    drawFPS(double x, double y, double fps);
    void    drawTPF(double x, double y, double tpf);
    void    drawBPF(double x, double y, double bpf);
    void    drawCPF(double x, double y, double cpf);

public:
    virtual std::string to_s() const;
    
};

