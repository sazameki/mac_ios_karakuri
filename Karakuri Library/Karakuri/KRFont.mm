/*!
    @file   KRFont.cpp
    @author numata
    @date   09/07/30
 */

#include "KRFont.h"


/*!
    @method KRFont
    Constructor
 */
KRFont::KRFont(const std::string& fontName, double size)
{
    mFontName = fontName;

    NSString *fontNameStr = [[NSString alloc] initWithCString:fontName.c_str() encoding:NSUTF8StringEncoding];

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    mFontObj = [[NSFont fontWithName:fontNameStr size:(float)size] retain];
#endif
    
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    mFontObj = [[UIFont fontWithName:fontNameStr size:(float)size] retain];
#endif
    
    [fontNameStr release];
}

/*!
    @method ~KRFont
    Destructor
 */
KRFont::~KRFont()
{
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    [(NSFont *)mFontObj release];
#endif

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    [(UIFont *)mFontObj release];
#endif
}

void *KRFont::getFontObject() const
{
    return mFontObj;
}

KRTexture2D *KRFont::createStringTexture(const std::string& str)
{
    return new KRTexture2D(str, this);
}

std::string KRFont::to_s() const
{
    return KRFS("<font>(name=\"%s\")", mFontName.c_str());
}


