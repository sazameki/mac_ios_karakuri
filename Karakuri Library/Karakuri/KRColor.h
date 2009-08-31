/*
 *  KRColor.h
 *  Karakuri Prototype
 *
 *  Created by numata on 08/06/07.
 *  Copyright 2008 Satoshi Numata. All rights reserved.
 *
 */

#pragma once


#include <Karakuri/Karakuri_Types.h>


class KRColor : public KRObject {
public:
    static const KRColor &AliceBlue;
    static const KRColor &AntiqueWhite;
    static const KRColor &Aqua;
    static const KRColor &Aquamarine;
    static const KRColor &Azure;
    static const KRColor &Beige;
    static const KRColor &Bisque;
    static const KRColor &Black;
    static const KRColor &BlanchedAlmond;
    static const KRColor &Blue;
    static const KRColor &BlueViolet;
    static const KRColor &Brown;
    static const KRColor &BurlyWood;
    static const KRColor &CadetBlue;
    static const KRColor &Chartreuse;
    static const KRColor &Chocolate;
    static const KRColor &Coral;
    static const KRColor &CornflowerBlue;
    static const KRColor &CornSilk;
    static const KRColor &Crimson;
    static const KRColor &Cyan;
    static const KRColor &DarkBlue;
    static const KRColor &DarkCyan;
    static const KRColor &DarkGoldenrod;
    static const KRColor &DarkGray;
    static const KRColor &DarkGreen;
    static const KRColor &DarkKhaki;
    static const KRColor &DarkMagenta;
    static const KRColor &DarkOliveGreen;
    static const KRColor &DarkOrange;
    static const KRColor &DarkOrchid;
    static const KRColor &DarkRed;
    static const KRColor &DarkSalmon;
    static const KRColor &DarkSeaGreen;
    static const KRColor &DarkSlateBlue;
    static const KRColor &DarkSlateGray;
    static const KRColor &DarkTurquoise;
    static const KRColor &DarkViolet;
    static const KRColor &DeepPink;
    static const KRColor &DeepSkyBlue;
    static const KRColor &DimGray;
    static const KRColor &DodgerBlue;
    static const KRColor &FireBrick;
    static const KRColor &FloralWhite;
    static const KRColor &ForestGreen;
    static const KRColor &Fuchsia;
    static const KRColor &Gainsboro;
    static const KRColor &GhostWhite;
    static const KRColor &Gold;
    static const KRColor &Goldenrod;
    static const KRColor &Gray;
    static const KRColor &Green;
    static const KRColor &GreenYellow;
    static const KRColor &Honeydew;
    static const KRColor &HotPink;
    static const KRColor &IndianRed;
    static const KRColor &Indigo;
    static const KRColor &Ivory;
    static const KRColor &Khaki;
    static const KRColor &Lavender;
    static const KRColor &LavenderBlush;
    static const KRColor &LawnGreen;
    static const KRColor &LemonChiffon;
    static const KRColor &LightBlue;
    static const KRColor &LightCoral;
    static const KRColor &LightCyan;
    static const KRColor &LightGoldenrodYellow;
    static const KRColor &LightGray;
    static const KRColor &LightGreen;
    static const KRColor &LightPink;
    static const KRColor &LightSalmon;
    static const KRColor &LightSeaGreen;
    static const KRColor &LightSkyBlue;
    static const KRColor &LightSlateGray;
    static const KRColor &LightSteelBlue;
    static const KRColor &LightYellow;
    static const KRColor &Lime;
    static const KRColor &LimeGreen;
    static const KRColor &Linen;
    static const KRColor &Magenta;
    static const KRColor &Maroon;
    static const KRColor &MediumAquamarine;
    static const KRColor &MediumBlue;
    static const KRColor &MediumOrchid;
    static const KRColor &MediumPurple;
    static const KRColor &MediumSeaGreen;
    static const KRColor &MediumSlateBlue;
    static const KRColor &MediumSpringGreen;
    static const KRColor &MediumTurquoise;
    static const KRColor &MediumVioletred;
    static const KRColor &MidnightBlue;
    static const KRColor &MintCream;
    static const KRColor &MistyRose;
    static const KRColor &Moccasin;
    static const KRColor &NavajoWhite;
    static const KRColor &Navy;
    static const KRColor &OldLace;
    static const KRColor &Olive;
    static const KRColor &OliveDrab;
    static const KRColor &Orange;
    static const KRColor &OrangeRed;
    static const KRColor &Orchid;
    static const KRColor &PaleGoldenrod;
    static const KRColor &PaleGreen;
    static const KRColor &PaleTurquoise;
    static const KRColor &PaleVioletred;
    static const KRColor &PapayaWhip;
    static const KRColor &PeachPuff;
    static const KRColor &Peru;
    static const KRColor &Pink;
    static const KRColor &Plum;
    static const KRColor &PowderBlue;
    static const KRColor &Purple;
    static const KRColor &Red;
    static const KRColor &RosyBrown;
    static const KRColor &RoyalBlue;
    static const KRColor &SaddleBrown;
    static const KRColor &Salmon;
    static const KRColor &SandyBrown;
    static const KRColor &SeaGreen;
    static const KRColor &SeaShell;
    static const KRColor &Sienna;
    static const KRColor &Silver;
    static const KRColor &SkyBlue;
    static const KRColor &SlateBlue;
    static const KRColor &SlateGray;
    static const KRColor &Snow;
    static const KRColor &SpringGreen;
    static const KRColor &SteelBlue;
    static const KRColor &Tan;
    static const KRColor &Teal;
    static const KRColor &Thistle;
    static const KRColor &Tomato;
    static const KRColor &Turquoise;
    static const KRColor &Violet;
    static const KRColor &Wheat;
    static const KRColor &White;
    static const KRColor &WhiteSmoke;
    static const KRColor &Yellow;
    static const KRColor &YellowGreen;
    
    static const KRColor &ClearColor;
    
public:
    float r;
    float g;
    float b;
    float a;
    
public:
    KRColor();
    KRColor(int rgb);
    KRColor(float r, float g, float b);
    KRColor(float r, float g, float b, float a);
    KRColor(const KRColor &color);
    
public:
    void set() const;
    void setAsClearColor() const;
    
public:
    KRColor&    operator=(const KRColor &color);
    bool        operator==(const KRColor &color);


#pragma mark -
#pragma mark Debug Support

public:
    std::string to_s() const;
    
};

