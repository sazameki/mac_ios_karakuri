/*
 *  KRColor.cpp
 *  Karakuri Prototype
 *
 *  Created by numata on 08/06/07.
 *  Copyright 2008 Satoshi Numata. All rights reserved.
 *
 */

#include <Karakuri/KRColor.h>

#include <Karakuri/KarakuriLibrary.h>


const KRColor &KRColor::AliceBlue               = KRColor(0xF0F8FF);
const KRColor &KRColor::AntiqueWhite            = KRColor(0xFAEBD7);
const KRColor &KRColor::Aqua                    = KRColor(0x00FFFF);
const KRColor &KRColor::Aquamarine              = KRColor(0x7FFFD4);
const KRColor &KRColor::Azure                   = KRColor(0xF0FFFF);
const KRColor &KRColor::Beige                   = KRColor(0xF5F5DC);
const KRColor &KRColor::Bisque                  = KRColor(0xFFE4C4);
const KRColor &KRColor::Black                   = KRColor(0x000000);
const KRColor &KRColor::BlanchedAlmond          = KRColor(0xFFEBCD);
const KRColor &KRColor::Blue                    = KRColor(0x0000FF);
const KRColor &KRColor::BlueViolet              = KRColor(0x8A2BE2);
const KRColor &KRColor::Brown                   = KRColor(0xA52A2A);
const KRColor &KRColor::BurlyWood               = KRColor(0xDEB887);
const KRColor &KRColor::CadetBlue               = KRColor(0x5F9EA0);
const KRColor &KRColor::Chartreuse              = KRColor(0x7FFF00);
const KRColor &KRColor::Chocolate               = KRColor(0xD2691E);
const KRColor &KRColor::Coral                   = KRColor(0xFF7F50);
const KRColor &KRColor::CornflowerBlue          = KRColor(0x6495ED);
const KRColor &KRColor::CornSilk                = KRColor(0xFFF8DC);
const KRColor &KRColor::Crimson                 = KRColor(0xDC143C);
const KRColor &KRColor::Cyan                    = KRColor(0x00FFFF);
const KRColor &KRColor::DarkBlue                = KRColor(0x00008B);
const KRColor &KRColor::DarkCyan                = KRColor(0x008B8B);
const KRColor &KRColor::DarkGoldenrod           = KRColor(0xB8860B);
const KRColor &KRColor::DarkGray                = KRColor(0xA9A9A9);
const KRColor &KRColor::DarkGreen               = KRColor(0x006400);
const KRColor &KRColor::DarkKhaki               = KRColor(0xBDB76B);
const KRColor &KRColor::DarkMagenta             = KRColor(0x8B008B);
const KRColor &KRColor::DarkOliveGreen          = KRColor(0x556B2F);
const KRColor &KRColor::DarkOrange              = KRColor(0xFF8C00);
const KRColor &KRColor::DarkOrchid              = KRColor(0x9932CC);
const KRColor &KRColor::DarkRed                 = KRColor(0x8B0000);
const KRColor &KRColor::DarkSalmon              = KRColor(0xE9967A);
const KRColor &KRColor::DarkSeaGreen            = KRColor(0x8FBC8F);
const KRColor &KRColor::DarkSlateBlue           = KRColor(0x483D8B);
const KRColor &KRColor::DarkSlateGray           = KRColor(0x2F4F4F);
const KRColor &KRColor::DarkTurquoise           = KRColor(0x00CED1);
const KRColor &KRColor::DarkViolet              = KRColor(0x9400D3);
const KRColor &KRColor::DeepPink                = KRColor(0xFF1493);
const KRColor &KRColor::DeepSkyBlue             = KRColor(0x00BFFF);
const KRColor &KRColor::DimGray                 = KRColor(0x696969);
const KRColor &KRColor::DodgerBlue              = KRColor(0x1E90FF);
const KRColor &KRColor::FireBrick               = KRColor(0xB22222);
const KRColor &KRColor::FloralWhite             = KRColor(0xFFFAF0);
const KRColor &KRColor::ForestGreen             = KRColor(0x228B22);
const KRColor &KRColor::Fuchsia                 = KRColor(0xFF00FF);
const KRColor &KRColor::Gainsboro               = KRColor(0xDCDCDC);
const KRColor &KRColor::GhostWhite              = KRColor(0xF8F8FF);
const KRColor &KRColor::Gold                    = KRColor(0xFFD700);
const KRColor &KRColor::Goldenrod               = KRColor(0xDAA520);
const KRColor &KRColor::Gray                    = KRColor(0x808080);
const KRColor &KRColor::Green                   = KRColor(0x008000);
const KRColor &KRColor::GreenYellow             = KRColor(0xADFF2F);
const KRColor &KRColor::Honeydew                = KRColor(0xF0FFF0);
const KRColor &KRColor::HotPink                 = KRColor(0xFF69B4);
const KRColor &KRColor::IndianRed               = KRColor(0xCD5C5C);
const KRColor &KRColor::Indigo                  = KRColor(0x4B0082);
const KRColor &KRColor::Ivory                   = KRColor(0xFFFFF0);
const KRColor &KRColor::Khaki                   = KRColor(0xF0E68C);
const KRColor &KRColor::Lavender                = KRColor(0xE6E6FA);
const KRColor &KRColor::LavenderBlush           = KRColor(0xFFF0F5);
const KRColor &KRColor::LawnGreen               = KRColor(0x7CFC00);
const KRColor &KRColor::LemonChiffon            = KRColor(0xFFFACD);
const KRColor &KRColor::LightBlue               = KRColor(0xADD8E6);
const KRColor &KRColor::LightCoral              = KRColor(0xF08080);
const KRColor &KRColor::LightCyan               = KRColor(0xE0FFFF);
const KRColor &KRColor::LightGoldenrodYellow    = KRColor(0xFAFAD2);
const KRColor &KRColor::LightGray               = KRColor(0xD3D3D3);
const KRColor &KRColor::LightGreen              = KRColor(0x90EE90);
const KRColor &KRColor::LightPink               = KRColor(0xFFB6C1);
const KRColor &KRColor::LightSalmon             = KRColor(0xFFA07A);
const KRColor &KRColor::LightSeaGreen           = KRColor(0x20B2AA);
const KRColor &KRColor::LightSkyBlue            = KRColor(0x87CEFA);
const KRColor &KRColor::LightSlateGray          = KRColor(0x778899);
const KRColor &KRColor::LightSteelBlue          = KRColor(0xB0C4DE);
const KRColor &KRColor::LightYellow             = KRColor(0xFFFFE0);
const KRColor &KRColor::Lime                    = KRColor(0x00FF00);
const KRColor &KRColor::LimeGreen               = KRColor(0x32CD32);
const KRColor &KRColor::Linen                   = KRColor(0xFAF0E6);
const KRColor &KRColor::Magenta                 = KRColor(0xFF00FF);
const KRColor &KRColor::Maroon                  = KRColor(0x800000);
const KRColor &KRColor::MediumAquamarine        = KRColor(0x66CDAA);
const KRColor &KRColor::MediumBlue              = KRColor(0x0000CD);
const KRColor &KRColor::MediumOrchid            = KRColor(0xBA55D3);
const KRColor &KRColor::MediumPurple            = KRColor(0x9370DB);
const KRColor &KRColor::MediumSeaGreen          = KRColor(0x3CB371);
const KRColor &KRColor::MediumSlateBlue         = KRColor(0x7B68EE);
const KRColor &KRColor::MediumSpringGreen       = KRColor(0x00FA9A);
const KRColor &KRColor::MediumTurquoise         = KRColor(0x48D1CC);
const KRColor &KRColor::MediumVioletred         = KRColor(0xC71585);
const KRColor &KRColor::MidnightBlue            = KRColor(0x191970);
const KRColor &KRColor::MintCream               = KRColor(0xF5FFFA);
const KRColor &KRColor::MistyRose               = KRColor(0xFFE4E1);
const KRColor &KRColor::Moccasin                = KRColor(0xFFE4B5);
const KRColor &KRColor::NavajoWhite             = KRColor(0xFFDEAD);
const KRColor &KRColor::Navy                    = KRColor(0x000080);
const KRColor &KRColor::OldLace                 = KRColor(0xFDF5E6);
const KRColor &KRColor::Olive                   = KRColor(0x808000);
const KRColor &KRColor::OliveDrab               = KRColor(0x6B8E23);
const KRColor &KRColor::Orange                  = KRColor(0xFFA500);
const KRColor &KRColor::OrangeRed               = KRColor(0xFF4500);
const KRColor &KRColor::Orchid                  = KRColor(0xDA70D6);
const KRColor &KRColor::PaleGoldenrod           = KRColor(0xEEE8AA);
const KRColor &KRColor::PaleGreen               = KRColor(0x98FB98);
const KRColor &KRColor::PaleTurquoise           = KRColor(0xAFEEEE);
const KRColor &KRColor::PaleVioletred           = KRColor(0xDB7093);
const KRColor &KRColor::PapayaWhip              = KRColor(0xFFEFD5);
const KRColor &KRColor::PeachPuff               = KRColor(0xFFDAB9);
const KRColor &KRColor::Peru                    = KRColor(0xCD853F);
const KRColor &KRColor::Pink                    = KRColor(0xFFC0CB);
const KRColor &KRColor::Plum                    = KRColor(0xDDA0DD);
const KRColor &KRColor::PowderBlue              = KRColor(0xB0E0E6);
const KRColor &KRColor::Purple                  = KRColor(0x800080);
const KRColor &KRColor::Red                     = KRColor(0xFF0000);
const KRColor &KRColor::RosyBrown               = KRColor(0xBC8F8F);
const KRColor &KRColor::RoyalBlue               = KRColor(0x4169E1);
const KRColor &KRColor::SaddleBrown             = KRColor(0x8B4513);
const KRColor &KRColor::Salmon                  = KRColor(0xFA8072);
const KRColor &KRColor::SandyBrown              = KRColor(0xF4A460);
const KRColor &KRColor::SeaGreen                = KRColor(0x2E8B57);
const KRColor &KRColor::SeaShell                = KRColor(0xFFF5EE);
const KRColor &KRColor::Sienna                  = KRColor(0xA0522D);
const KRColor &KRColor::Silver                  = KRColor(0xC0C0C0);
const KRColor &KRColor::SkyBlue                 = KRColor(0x87CEEB);
const KRColor &KRColor::SlateBlue               = KRColor(0x6A5ACD);
const KRColor &KRColor::SlateGray               = KRColor(0x708090);
const KRColor &KRColor::Snow                    = KRColor(0xFFFAFA);
const KRColor &KRColor::SpringGreen             = KRColor(0x00FF7F);
const KRColor &KRColor::SteelBlue               = KRColor(0x4682B4);
const KRColor &KRColor::Tan                     = KRColor(0xD2B48C);
const KRColor &KRColor::Teal                    = KRColor(0x008080);
const KRColor &KRColor::Thistle                 = KRColor(0xD8BFD8);
const KRColor &KRColor::Tomato                  = KRColor(0xFF6347);
const KRColor &KRColor::Turquoise               = KRColor(0x40E0D0);
const KRColor &KRColor::Violet                  = KRColor(0xEE82EE);
const KRColor &KRColor::Wheat                   = KRColor(0xF5DEB3);
const KRColor &KRColor::White                   = KRColor(0xFFFFFF);
const KRColor &KRColor::WhiteSmoke              = KRColor(0xF5F5F5);
const KRColor &KRColor::Yellow                  = KRColor(0xFFFF00);
const KRColor &KRColor::YellowGreen             = KRColor(0x9ACD32);

const KRColor &KRColor::ClearColor              = KRColor(1.0, 1.0, 1.0, 0.0);


#pragma mark -
#pragma mark Constructor

KRColor::KRColor()
    : r(0.0), g(0.0), b(0.0), a(1.0)
{
}

KRColor::KRColor(int rgb)
    : r((double)((rgb >> 16) & 0xff) / 255.0),
      g((double)((rgb >> 8) & 0xff) / 255.0),
      b((double)(rgb & 0xff) / 255.0),
      a(1.0)
{
}

KRColor::KRColor(double _r, double _g, double _b)
    : r(_r), g(_g), b(_b), a(1.0)
{
}

KRColor::KRColor(double _r, double _g, double _b, double _a)
    : r(_r), g(_g), b(_b), a(_a)
{
}

KRColor::KRColor(const KRColor &color)
    : r(color.r), g(color.g), b(color.b), a(color.a)
{
}

void KRColor::set() const
{
    if (_KRColorRed != r || _KRColorGreen != g || _KRColorBlue != b || _KRColorAlpha != a) {
        _KRColorRed = r;
        _KRColorGreen = g;
        _KRColorBlue = b;
        _KRColorAlpha = a;
#if defined(KR_IPHONE) && !defined(KR_IPHONE_MACOSX_EMU)
        glColor4f((float)r, (float)g, (float)b, (float)a);
#else
        glColor4d(r, g, b, a);
#endif
    }
}

void KRColor::setAsClearColor() const
{
    if (_KRClearColorRed != r || _KRClearColorGreen != g || _KRClearColorBlue != b || _KRClearColorAlpha != a) {
        _KRClearColorRed = r;
        _KRClearColorGreen = g;
        _KRClearColorBlue = b;
        _KRClearColorAlpha = a;
        glClearColor(r, g, b, a);
    }
}

KRColor& KRColor::operator=(const KRColor &color)
{
    r = color.r;
    g = color.g;
    b = color.b;
    a = color.a;
    return *this;
}

bool KRColor::operator==(const KRColor &color)
{
    return (r == color.r && g == color.g && b == color.b && a == color.a);
}

bool KRColor::operator!=(const KRColor &color)
{
    return (r != color.r || g != color.g || b != color.b || a != color.a);
}


#pragma mark -
#pragma mark Debug Support

std::string KRColor::to_s() const
{
    return KRFS("<color>(r=%6.5f, g=%6.5f, b=%6.5f, a=%6.5f)", r, g, b, a);
}

