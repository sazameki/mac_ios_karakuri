/*!
    @file   KRFont.h
    @author numata
    @date   09/07/30
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>

#include <Karakuri/KRTexture2D.h>
#include <Karakuri/KRColor.h>


class KRFont : public KRObject {
    
    void        *mFontObj;
    std::string mFontName;

public:
	KRFont(const std::string& fontName, float size);
	virtual ~KRFont();
    
public:
    KRTexture2D *createStringTexture(const std::string& str);

public:
    void        *getFontObject() const KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY;

public:
    virtual std::string to_s() const;

};

