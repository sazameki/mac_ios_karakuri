/*!
    @file   KRTexture2DManager.h
    @author numata
    @date   10/02/17
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/Karakuri.h>


/*!
    @class KRTexture2DManager
    @group Game 2D Graphics
    <p>2次元のテクスチャの管理を行うためのクラスです。</p>
    <p>テクスチャのサイズは、横幅・高さともに1024ピクセル以内である必要があります。このサイズを超えている画像が指定された場合には、実行時例外が発生してゲームが強制終了します。</p>
    <p><a href="../../../../guide/index.html">開発ガイド</a>の「<a href="../../../../guide/texture.html">テクスチャについて</a>」も参照してください。</p>
 */
class KRTexture2DManager {

    std::map<int, std::vector<int> >    mGroupID_TexIDList_Map;
    std::map<int, std::string>          mTexID_ImageFileName_Map;
    std::map<int, KRTexture2DScaleMode> mTexID_ScaleMode_Map;

    std::map<int, KRTexture2D*>         mTexMap;

    int         mNextNewTexID;

public:
	KRTexture2DManager();
	virtual ~KRTexture2DManager();
    
#pragma mark ---- 画像ファイルの管理 ----
public:
    int     addTexture(int groupID, const std::string& imageFileName, KRTexture2DScaleMode scaleMode=KRTexture2DScaleModeNearest);
    int     addTexture(int groupID, const std::string& imageFileName, const KRVector2D& atlasSize, KRTexture2DScaleMode scaleMode=KRTexture2DScaleModeNearest);

    int     addFont(int groupID, const std::string& fontName, double size);
    
#pragma mark ---- リソース管理 ----
public:
    /*!
        @task リソースの管理
     */
    
    int     getResourceSize(int groupID);
    void    loadTextureFiles(int groupID, KRWorld* loaderWorld, double minDuration);
    void    unloadTextureFiles(int groupID);
    
    KRVector2D  getTextureSize(int texID);
    KRVector2D  getAtlasSize(int texID);
    
    void    setTextureAtlasSize(int texID, const KRVector2D& size);
    
    KRTexture2D*    _getTexture(int texID);

#pragma mark ---- テクスチャの描画 ----
    void    drawAtPoint(int texID, const KRVector2D& pos, double alpha=1.0);
    void    drawAtPoint(int texID, const KRVector2D& pos, const KRColor& color);
    void    drawAtPointEx(int texID, const KRVector2D& pos, double rotate, const KRVector2D& origin, const KRVector2D& scale, double alpha=1.0);
    void    drawAtPointEx(int texID, const KRVector2D& pos, double rotate, const KRVector2D& origin, const KRVector2D& scale, const KRColor& color);
    void    drawAtPointEx2(int texID, const KRVector2D& pos, const KRRect2D& srcRect, double rotate, const KRVector2D& origin, const KRVector2D& scale, double alpha=1.0);
    void    drawAtPointEx2(int texID, const KRVector2D& pos, const KRRect2D& srcRect, double rotate, const KRVector2D& origin, const KRVector2D& scale, const KRColor& color);

    void    drawAtPointCenter(int texID, const KRVector2D& centerPos, double alpha=1.0);
    void    drawAtPointCenter(int texID, const KRVector2D& centerPos, const KRColor& color);
    void    drawAtPointCenterEx(int texID, const KRVector2D& centerPos, double rotate, const KRVector2D& origin, const KRVector2D& scale, double alpha=1.0);
    void    drawAtPointCenterEx(int texID, const KRVector2D& centerPos, double rotate, const KRVector2D& origin, const KRVector2D& scale, const KRColor& color);
    void    drawAtPointCenterEx2(int texID, const KRVector2D& centerPos, const KRRect2D& srcRect, double rotate, const KRVector2D& origin, const KRVector2D& scale, double alpha=1.0);
    void    drawAtPointCenterEx2(int texID, const KRVector2D& centerPos, const KRRect2D& srcRect, double rotate, const KRVector2D& origin, const KRVector2D& scale, const KRColor& color);

    void    drawInRect(int texID, const KRRect2D& destRect, double alpha=1.0);
    void    drawInRect(int texID, const KRRect2D& destRect, const KRColor& color);
    void    drawInRect(int texID, const KRRect2D& destRect, const KRRect2D& srcRect, double alpha=1.0);
    void    drawInRect(int texID, const KRRect2D& destRect, const KRRect2D& srcRect, const KRColor& color);
    
#pragma mark ---- アトラスの描画 ----
    void    drawAtlasAtPoint(int texID, const KRVector2DInt& atlasPos, const KRVector2D& pos, double alpha=1.0);
    void    drawAtlasAtPoint(int texID, const KRVector2DInt& atlasPos, const KRVector2D& pos, const KRColor& color);
    void    drawAtlasAtPointEx(int texID, const KRVector2DInt& atlasPos, const KRVector2D& pos, double rotate, const KRVector2D& origin, const KRVector2D& scale, double alpha=1.0);
    void    drawAtlasAtPointEx(int texID, const KRVector2DInt& atlasPos, const KRVector2D& pos, double rotate, const KRVector2D& origin, const KRVector2D& scale, const KRColor& color);
    
    void    drawAtlasAtPointCenter(int texID, const KRVector2DInt& atlasPos, const KRVector2D& centerPos, double alpha=1.0);
    void    drawAtlasAtPointCenter(int texID, const KRVector2DInt& atlasPos, const KRVector2D& centerPos, const KRColor& color);
    void    drawAtlasAtPointCenterEx(int texID, const KRVector2DInt& atlasPos, const KRVector2D& centerPos, double rotate, const KRVector2D& origin, const KRVector2D& scale, double alpha=1.0);
    void    drawAtlasAtPointCenterEx(int texID, const KRVector2DInt& atlasPos, const KRVector2D& centerPos, double rotate, const KRVector2D& origin, const KRVector2D& scale, const KRColor& color);
    
    void    drawAtlasInRect(int texID, const KRVector2DInt& atlasPos, const KRRect2D& destRect, double alpha=1.0);
    void    drawAtlasInRect(int texID, const KRVector2DInt& atlasPos, const KRRect2D& destRect, const KRColor& color);

#pragma mark ---- フォントのサポート ----
    int     createStringTexture(int fontID, const std::string& str);    
    
};


/*!
    @var    gKRTex2DMan
    @group  Game 2D Graphics
    @abstract テクスチャの管理を行うクラスのインスタンスを指す変数です。
    この変数が指し示すオブジェクトは、ゲーム実行の最初から最後まで絶対に変わりません。
 */
extern KRTexture2DManager*  gKRTex2DMan;

