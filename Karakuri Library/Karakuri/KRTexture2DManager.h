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
    @group Game Graphics
    <p>2次元のテクスチャの管理を行うためのクラスです。このクラスのインスタンスには、グローバル変数 gKRTex2DMan を使ってアクセスしてください。</p>
    <p>テクスチャのサイズは、横幅・高さともに1024ピクセル以内である必要があります。このサイズを超えている画像が指定された場合には、実行時例外が発生してゲームが強制終了します。</p>
    <p><a href="../../../../guide/index.html">開発ガイド</a>の「<a href="../../../../guide/texture.html">テクスチャについて</a>」も参照してください。</p>
 */
class KRTexture2DManager : public KRObject {

    std::map<int, std::vector<int> >    mGroupID_TexIDList_Map;
    std::map<int, std::string>          mTexID_ImageFileName_Map;
    std::map<int, KRTexture2DScaleMode> mTexID_ScaleMode_Map;
    std::map<std::string, int>          mTicket_TexID_Map;
    std::map<std::string, unsigned>     mTicket_StartPos_Map;
    std::map<std::string, unsigned>     mTicket_Length_Map;
    std::map<std::string, int>          mTicket_DivX_Map;
    std::map<std::string, int>          mTicket_DivY_Map;
    std::map<int, std::string>          mTexID_Ticket_Map;
    
    std::map<int, KRTexture2D*>         mTexMap;

    int         mNextNewTexID;

public:
	KRTexture2DManager();
	virtual ~KRTexture2DManager();
    
#pragma mark ---- 画像ファイルの管理 ----
public:
    /*!
        @task 画像ファイルの管理
     */
    
    /*!
        @method     addTexture
        @abstract   グループID、テクスチャID、画像ファイルの名前（拡張子を含む）を指定してテクスチャを追加します。
        オプションで KRTexture2DScaleModeNearest, KRTexture2DScaleModeLinear のいずれかの定数で画像補完方法を指定できます。
     */
    void    addTexture(int groupID, int texID, const std::string& imageFileName, KRTexture2DScaleMode scaleMode=KRTexture2DScaleModeNearest);

    /*!
        @method     addTexture
        @abstract   グループID、テクスチャID、画像ファイルの名前（拡張子を含む）を指定してテクスチャを追加します。画像内の1コマあたりのサイズを指定して、各コマを描画できるようにします。
        オプションで KRTexture2DScaleModeNearest, KRTexture2DScaleModeLinear のいずれかの定数で画像補完方法を指定できます。
     */
    void    addTexture(int groupID, int texID, const std::string& imageFileName, const KRVector2D& atlasSize, KRTexture2DScaleMode scaleMode=KRTexture2DScaleModeNearest);
    

    /*!
        @method getAtlasSize
        @abstract テクスチャIDを指定して、テクスチャに指定された1コマごとのサイズを取得します。
     */
    KRVector2D  getAtlasSize(int texID);
    
    /*!
        @method getTextureSize
        @abstract テクスチャIDを指定して、テクスチャの全体のサイズを取得します。
     */
    KRVector2D  getTextureSize(int texID);

    /*!
        @method setTextureAtlasSize
        テクスチャIDを指定して、テクスチャの1コマごとのサイズを指定します。
     */
    void    setTextureAtlasSize(int texID, const KRVector2D& size);
    
    
    void    _addTexture(int groupID, const std::string& resourceName, const std::string& ticket, const std::string& resourceFileName, unsigned pos, unsigned length);

    void        _setDivForTicket(const std::string& ticket, int divX, int divY);
    int         _getTextureIDForTicket(const std::string& ticket);
    std::string _getFileNameForTicket(const std::string& ticket);
    unsigned    _getResourceStartPosForTicket(const std::string& ticket);
    unsigned    _getResourceLengthForTicket(const std::string& ticket);
    
    void    _loadTextureFiles(int groupID, KRWorld* loaderWorld, double minDuration);
    void    _unloadTextureFiles(int groupID);
    
    int     _getResourceSize(int groupID);
    KRTexture2D*        _getTexture(int texID);
    
    
#pragma mark ---- テクスチャの描画 ----
    /*!
        @task テクスチャの描画（基本）
     */
    
    /*!
        @method drawAtPoint
        @abstract IDと位置を指定してテクスチャを描画します。オプションで不透明度を指定できます (0.0〜1.0)。
     */
    void    drawAtPoint(int texID, const KRVector2D& pos, double alpha=1.0);

    /*!
        @method drawAtPoint
        @abstract IDと位置と色を指定してテクスチャを描画します。
     */
    void    drawAtPoint(int texID, const KRVector2D& pos, const KRColor& color);

    /*!
        @method drawAtPointEx
        @abstract IDと位置、回転と回転の中心点、拡大率を指定してテクスチャを描画します。オプションで不透明度を指定できます (0.0〜1.0)。
     */
    void    drawAtPointEx(int texID, const KRVector2D& pos, double rotate, const KRVector2D& origin, const KRVector2D& scale, double alpha=1.0);

    /*!
        @method drawAtPointEx
        @abstract IDと位置、回転と回転の中心点、拡大率、色を指定してテクスチャを描画します。
     */
    void    drawAtPointEx(int texID, const KRVector2D& pos, double rotate, const KRVector2D& origin, const KRVector2D& scale, const KRColor& color);

    /*!
        @method drawAtPointEx2
        @abstract IDと位置、描画対象の矩形、回転と回転の中心点、拡大率を指定してテクスチャを描画します。オプションで不透明度を指定できます (0.0〜1.0)。
     */
    void    drawAtPointEx2(int texID, const KRVector2D& pos, const KRRect2D& srcRect, double rotate, const KRVector2D& origin, const KRVector2D& scale, double alpha=1.0);

    /*!
        @method drawAtPointEx2
        @abstract IDと位置、描画対象の矩形、回転と回転の中心点、拡大率、色を指定してテクスチャを描画します。
     */
    void    drawAtPointEx2(int texID, const KRVector2D& pos, const KRRect2D& srcRect, double rotate, const KRVector2D& origin, const KRVector2D& scale, const KRColor& color);


    /*!
        @task テクスチャの描画（中心点指定）
     */
    
    /*!
        @method drawAtPointCenter
        @abstract IDと描画の中心点を指定してテクスチャを描画します。オプションで不透明度を指定できます (0.0〜1.0)。
     */
    void    drawAtPointCenter(int texID, const KRVector2D& centerPos, double alpha=1.0);

    /*!
        @method drawAtPointCenter
        @abstract IDと描画の中心点と色を指定してテクスチャを描画します。
     */
    void    drawAtPointCenter(int texID, const KRVector2D& centerPos, const KRColor& color);

    /*!
        @method drawAtPointCenterEx
        @abstract IDと描画の中心点、回転角、拡大率を指定してテクスチャを描画します。オプションで不透明度を指定できます (0.0〜1.0)。
     */
    void    drawAtPointCenterEx(int texID, const KRVector2D& centerPos, double rotate, const KRVector2D& scale, double alpha=1.0);

    /*!
        @method drawAtPointCenterEx
        @abstract IDと描画の中心点、回転角、拡大率、色を指定してテクスチャを描画します。
     */
    void    drawAtPointCenterEx(int texID, const KRVector2D& centerPos, double rotate, const KRVector2D& scale, const KRColor& color);

    /*!
        @method drawAtPointCenterEx2
        @abstract IDと描画の中心点、描画対象の矩形、回転角、拡大率を指定してテクスチャを描画します。オプションで不透明度を指定できます (0.0〜1.0)。
     */
    void    drawAtPointCenterEx2(int texID, const KRVector2D& centerPos, const KRRect2D& srcRect, double rotate, const KRVector2D& scale, double alpha=1.0);

    /*!
        @method drawAtPointCenterEx2
        @abstract IDと描画の中心点、描画対象の矩形、回転角、拡大率、色を指定してテクスチャを描画します。
     */
    void    drawAtPointCenterEx2(int texID, const KRVector2D& centerPos, const KRRect2D& srcRect, double rotate, const KRVector2D& scale, const KRColor& color);


    /*!
        @task テクスチャの描画（矩形指定）
     */
    
    /*!
        @method drawInRect
        @abstract IDと描画対象の矩形を指定してテクスチャを描画します。オプションで不透明度を指定できます (0.0〜1.0)。
     */
    void    drawInRect(int texID, const KRRect2D& destRect, double alpha=1.0);

    /*!
        @method drawInRect
        @abstract IDと描画対象の矩形、色を指定してテクスチャを描画します。
     */
    void    drawInRect(int texID, const KRRect2D& destRect, const KRColor& color);

    /*!
        @method drawInRect
        @abstract IDと描画対象の矩形、描画元の矩形を指定してテクスチャを描画します。オプションで不透明度を指定できます (0.0〜1.0)。
     */
    void    drawInRect(int texID, const KRRect2D& destRect, const KRRect2D& srcRect, double alpha=1.0);

    /*!
        @method drawInRect
        @abstract IDと描画対象の矩形、描画元の矩形、色を指定してテクスチャを描画します。
     */
    void    drawInRect(int texID, const KRRect2D& destRect, const KRRect2D& srcRect, const KRColor& color);


#pragma mark ---- アトラスの描画 ----
    /*!
        @task テクスチャの描画（アトラス指定）
     */
    
    /*!
        @method drawAtlasAtPoint
        @abstract IDとアトラス座標、位置を指定してテクスチャを描画します。オプションで不透明度を指定できます (0.0〜1.0)。
     */
    void    drawAtlasAtPoint(int texID, const KRVector2DInt& atlasPos, const KRVector2D& pos, double alpha=1.0);

    /*!
        @method drawAtlasAtPoint
        @abstract IDとアトラス座標、位置、色を指定してテクスチャを描画します。
     */
    void    drawAtlasAtPoint(int texID, const KRVector2DInt& atlasPos, const KRVector2D& pos, const KRColor& color);

    /*!
        @method drawAtlasAtPointEx
        @abstract IDとアトラス座標、回転と回転の中心点、拡大率を指定してテクスチャを描画します。オプションで不透明度を指定できます (0.0〜1.0)。
        回転の中心点 origin は、x も y も 0.0〜1.0 の、横幅と高さに対する比率で指定します。画像の左下の点が (0, 0)、右上の点が (1, 1) です。
     */
    void    drawAtlasAtPointEx(int texID, const KRVector2DInt& atlasPos, const KRVector2D& pos, double rotate, const KRVector2D& origin, const KRVector2D& scale, double alpha=1.0);

    /*!
        @method drawAtlasAtPointEx
        @abstract IDとアトラス座標、回転と回転の中心点、拡大率、色を指定してテクスチャを描画します。
        回転の中心点 origin は、x も y も 0.0〜1.0 の、横幅と高さに対する比率で指定します。画像の左下の点が (0, 0)、右上の点が (1, 1) です。
     */
    void    drawAtlasAtPointEx(int texID, const KRVector2DInt& atlasPos, const KRVector2D& pos, double rotate, const KRVector2D& origin, const KRVector2D& scale, const KRColor& color);


    /*!
        @task テクスチャの描画（アトラス指定＋中心点指定）
     */

    /*!
        @method drawAtlasAtPointCenter
        @abstract IDとアトラス座標、描画の中心点を指定してテクスチャを描画します。オプションで不透明度を指定できます (0.0〜1.0)。
     */
    void    drawAtlasAtPointCenter(int texID, const KRVector2DInt& atlasPos, const KRVector2D& centerPos, double alpha=1.0);

    /*!
        @method drawAtlasAtPointCenter
        @abstract IDとアトラス座標、描画の中心点、色を指定してテクスチャを描画します。
     */
    void    drawAtlasAtPointCenter(int texID, const KRVector2DInt& atlasPos, const KRVector2D& centerPos, const KRColor& color);

    /*!
        @method drawAtlasAtPointCenterEx
        @abstract IDとアトラス座標、描画の中心点、回転と回転の中心点、拡大率を指定してテクスチャを描画します。オプションで不透明度を指定できます (0.0〜1.0)。
     */
    void    drawAtlasAtPointCenterEx(int texID, const KRVector2DInt& atlasPos, const KRVector2D& centerPos, double rotate, const KRVector2D& scale, double alpha=1.0);

    /*!
        @method drawAtlasAtPointCenterEx
        @abstract IDとアトラス座標、描画の中心点、回転と回転の中心点、拡大率、色を指定してテクスチャを描画します。
     */
    void    drawAtlasAtPointCenterEx(int texID, const KRVector2DInt& atlasPos, const KRVector2D& centerPos, double rotate, const KRVector2D& scale, const KRColor& color);


    /*!
        @task テクスチャの描画（アトラス指定＋矩形指定）
     */
    
    /*!
        @method drawAtlasAtPointCenterEx
        @abstract IDとアトラス座標、描画対象の矩形を指定してテクスチャを描画します。オプションで不透明度を指定できます (0.0〜1.0)。
     */
    void    drawAtlasInRect(int texID, const KRVector2DInt& atlasPos, const KRRect2D& destRect, double alpha=1.0);

    /*!
        @method drawAtlasAtPointCenterEx
        @abstract IDとアトラス座標、描画対象の矩形、色を指定してテクスチャを描画します。
     */
    void    drawAtlasInRect(int texID, const KRVector2DInt& atlasPos, const KRRect2D& destRect, const KRColor& color);

};


/*!
    @var    gKRTex2DMan
    @group  Game Graphics
    @abstract テクスチャの管理を行うクラスのインスタンスを指す変数です。
    この変数が指し示すオブジェクトは、ゲーム実行の最初から最後まで絶対に変わりません。
 */
extern KRTexture2DManager*  gKRTex2DMan;

