/*!
    @file   KRLabel.h
    @author numata
    @date   09/08/29
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/KRControl.h>
#include <Karakuri/KRTexture2D.h>
#include <Karakuri/KRFont.h>


/*!
    @enum   KRTextAlignment
    @group  Game Controls
    @constant KRTextAlignmentLeft   左寄せ
    @constant KRTextAlignmentCenter 中央寄せ
    @constant KRTextAlignmentRight  右寄せ
    文字列の横方向の配置方法を表す列挙型です。
 */
typedef enum {
    KRTextAlignmentLeft,
    KRTextAlignmentCenter,
    KRTextAlignmentRight,
} KRTextAlignment;


/*!
    @class KRLabel
    @group Game Controls
 */
class KRLabel : public KRControl {

protected:
    std::string     mText;
    KRTexture2D     *mTextTexture;
    KRFont          *mFont;
    KRColor         mTextColor;
    bool            mHasChangedText;
    KRTextAlignment mTextAlignment;
    
public:
	KRLabel(const KRRect2D& frame);
	virtual ~KRLabel();
    
public:
    virtual bool    update(KRInput *input);
    virtual void    draw(KRGraphics *g);
    
public:
    std::string     getText() const;
    void            setText(const std::string& text);
    
    KRTextAlignment getTextAlignment() const;
    void            setTextAlignment(KRTextAlignment alignment);
    
    void            setTextColor(const KRColor& color);
    
};

