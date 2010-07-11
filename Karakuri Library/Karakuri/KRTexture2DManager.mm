/*!
    @file   KRTexture2DManager
    @author numata
    @date   10/02/17
 */

#include "KRTexture2DManager.h"


KRTexture2DManager*  gKRTex2DMan;


KRTexture2DManager::KRTexture2DManager()
{
    gKRTex2DMan = this;
    
    mNextNewTexID = 0;
}

KRTexture2DManager::~KRTexture2DManager()
{
    // Do nothing
}

void KRTexture2DManager::addTexture(int groupID, int texID, const std::string& imageFileName, KRTexture2DScaleMode scaleMode)
{
    addTexture(groupID, texID, imageFileName, KRVector2DZero, scaleMode);
}

void KRTexture2DManager::addTexture(int groupID, int texID, const std::string& imageFileName, const KRVector2D& atlasSize, KRTexture2DScaleMode scaleMode)
{
    // 100万以上の ID は予約済み
    if (texID >= 1000000) {
        const char *errorFormat = "Texture ID should be lower than a million (1000000).";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "テクスチャIDは 999999 以下でなければいけません。";
        }
        throw KRRuntimeError(errorFormat);
    }
    
#if __DEBUG__
    // TODO: texID で既に登録されていないかをチェックして、登録されている場合には警告を出す。
#endif

    std::vector<int>& theTexIDList = mGroupID_TexIDList_Map[groupID];
    theTexIDList.push_back(texID);
    
    mTexID_ImageFileName_Map[texID] = imageFileName;
    mTexID_ScaleMode_Map[texID] = scaleMode;
    
    setTextureAtlasSize(texID, atlasSize);
}

void KRTexture2DManager::_addTexture(int groupID, const std::string& resourceName, const std::string& ticket, const std::string& resourceFileName, unsigned pos, unsigned length)
{
    static int texID = 1000000;
    texID++;
    
    std::vector<int>& theTexIDList = mGroupID_TexIDList_Map[groupID];
    theTexIDList.push_back(texID);
    
    mTexID_Ticket_Map[texID] = ticket;

    mTicket_TexID_Map[ticket] = texID;
    mTicket_StartPos_Map[ticket] = pos;
    mTicket_Length_Map[ticket] = length;
    mTicket_DivX_Map[ticket] = 1;
    mTicket_DivY_Map[ticket] = 1;

    mTexID_ImageFileName_Map[texID] = resourceFileName;
    mTexID_ScaleMode_Map[texID] = KRTexture2DScaleModeLinear;
}

void KRTexture2DManager::_setDivForTicket(const std::string& ticket, int divX, int divY)
{
    mTicket_DivX_Map[ticket] = divX;
    mTicket_DivY_Map[ticket] = divY;
}

int KRTexture2DManager::_getResourceSize(int groupID)
{
    int ret = 0;
    
    std::vector<int>& theTexIDList = mGroupID_TexIDList_Map[groupID];
    
    for (std::vector<int>::const_iterator it = theTexIDList.begin(); it != theTexIDList.end(); it++) {
        int texID = *it;
        std::string filename = mTexID_ImageFileName_Map[texID];
        int resourceSize = _KRTexture2D::getResourceSize(filename);
        ret += resourceSize;
    }
    
    return ret;
}

void KRTexture2DManager::_loadTextureFiles(int groupID, KRWorld* loaderWorld, double minDuration)
{
    std::vector<int>& theTexIDList = mGroupID_TexIDList_Map[groupID];

    int allResourceSize = 0;
    NSTimeInterval sleepTime = 0.2;

    for (std::vector<int>::const_iterator it = theTexIDList.begin(); it != theTexIDList.end(); it++) {
        int texID = *it;
        std::string filename = mTexID_ImageFileName_Map[texID];
        int resourceSize = _KRTexture2D::getResourceSize(filename);
        allResourceSize += resourceSize;
    }

    for (std::vector<int>::const_iterator it = theTexIDList.begin(); it != theTexIDList.end(); it++) {
        int texID = *it;
        std::string filename = mTexID_ImageFileName_Map[texID];
        int resourceSize = KRMusic::getResourceSize(filename);
        double theMinDuration = ((double)resourceSize / allResourceSize) * minDuration;
        
        int baseFinishedSize = 0;
        if (loaderWorld != NULL) {
            baseFinishedSize = loaderWorld->_getFinishedSize();
        }
        
        NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
        if (mTexMap[texID] == NULL) {
            KRTexture2DScaleMode scaleMode = mTexID_ScaleMode_Map[texID];
            
            NSString* filenameStr = [[NSString alloc] initWithCString:filename.c_str() encoding:NSUTF8StringEncoding];
            if ([[filenameStr pathExtension] isEqualToString:@"krrs"]) {
                std::string ticket = mTexID_Ticket_Map[texID];
                int divX = mTicket_DivX_Map[ticket];
                int divY = mTicket_DivY_Map[ticket];
                mTexMap[texID] = new _KRTexture2D(filename, ticket, divX, divY, scaleMode);
            } else {
                mTexMap[texID] = new _KRTexture2D(filename, scaleMode);
            }
            [filenameStr release];
        }
        NSTimeInterval loadTime = [NSDate timeIntervalSinceReferenceDate] - startTime;
        
        double progress = loadTime / theMinDuration;
        if (loaderWorld != NULL) {
            if (progress < 1.0) {
                while (progress < 1.0) {
                    loaderWorld->_setFinishedSize(baseFinishedSize + progress * resourceSize);
                    [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:sleepTime]];
                    loadTime += sleepTime;
                    progress = loadTime / theMinDuration;
                }
            }
            int resourceSize = KRMusic::getResourceSize(filename);
            loaderWorld->_setFinishedSize(baseFinishedSize + resourceSize);
        }
    }
}

void KRTexture2DManager::_unloadTextureFiles(int groupID)
{
    // Do nothing
}

std::string KRTexture2DManager::_getFileNameForTicket(const std::string& ticket)
{
    int texID = mTicket_TexID_Map[ticket];
    return mTexID_ImageFileName_Map[texID];
}

int KRTexture2DManager::_getTextureIDForTicket(const std::string& ticket)
{
    return mTicket_TexID_Map[ticket];
}

unsigned KRTexture2DManager::_getResourceStartPosForTicket(const std::string& ticket)
{
    return mTicket_StartPos_Map[ticket];
}

unsigned KRTexture2DManager::_getResourceLengthForTicket(const std::string& ticket)
{
    return mTicket_Length_Map[ticket];
}

_KRTexture2D* KRTexture2DManager::_getTexture(int texID)
{
    // IDからテクスチャを引っ張ってくる。
    _KRTexture2D* theTex = mTexMap[texID];
    if (theTex == NULL) {
        std::string filename = mTexID_ImageFileName_Map[texID];
        NSString* filenameStr = [[NSString alloc] initWithCString:filename.c_str() encoding:NSUTF8StringEncoding];
        
        KRTexture2DScaleMode scaleMode = mTexID_ScaleMode_Map[texID];
        
        if ([[filenameStr pathExtension] isEqualToString:@"krrs"]) {
            std::string ticket = mTexID_Ticket_Map[texID];
            int divX = mTicket_DivX_Map[ticket];
            int divY = mTicket_DivY_Map[ticket];
            theTex = new _KRTexture2D(filename, ticket, divX, divY, scaleMode);
        } else {
            theTex = new _KRTexture2D(filename, scaleMode);
        }
        
        mTexMap[texID] = theTex;
        
        [filenameStr release];
    }

    // テクスチャが見つからなかったときの処理。
    if (theTex == NULL) {
        const char *errorFormat = "Failed to find the texture with ID %d.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "ID が %d のテクスチャは見つかりませんでした。";
        }
        throw KRRuntimeError(errorFormat, texID);
    }

    // リターン
    return theTex;
}

KRVector2D KRTexture2DManager::getTextureSize(int texID)
{
    return _getTexture(texID)->getSize();
}

KRVector2D KRTexture2DManager::getAtlasSize(int texID)
{
    return _getTexture(texID)->getAtlasSize();
}

void KRTexture2DManager::setTextureAtlasSize(int texID, const KRVector2D& size)
{
    _getTexture(texID)->setTextureAtlasSize(size);
}



#pragma mark -
#pragma mark ---- テクスチャの描画（基本） ----

void KRTexture2DManager::drawAtPoint(int texID, const KRVector2D& pos, double alpha)
{
    _getTexture(texID)->drawAtPoint_(pos, KRColor(1, 1, 1, alpha));
}

void KRTexture2DManager::drawAtPoint(int texID, const KRVector2D& pos, const KRColor& color)
{
    _getTexture(texID)->drawAtPoint_(pos, color);
}

void KRTexture2DManager::drawAtPointEx(int texID, const KRVector2D& pos, double rotate, const KRVector2D& origin, const KRVector2D& scale, double alpha)
{
    _getTexture(texID)->drawAtPointEx_(pos, KRRect2DZero, rotate, origin, scale, KRColor(1, 1, 1, alpha));
}

void KRTexture2DManager::drawAtPointEx(int texID, const KRVector2D& pos, double rotate, const KRVector2D& origin, const KRVector2D& scale, const KRColor& color)
{
    _getTexture(texID)->drawAtPointEx_(pos, KRRect2DZero, rotate, origin, scale, color);
}

void KRTexture2DManager::drawAtPointEx2(int texID, const KRVector2D& pos, const KRRect2D& srcRect, double rotate, const KRVector2D& origin, const KRVector2D& scale, double alpha)
{
    _getTexture(texID)->drawAtPointEx_(pos, srcRect, rotate, origin, scale, KRColor(1, 1, 1, alpha));
}

void KRTexture2DManager::drawAtPointEx2(int texID, const KRVector2D& pos, const KRRect2D& srcRect, double rotate, const KRVector2D& origin, const KRVector2D& scale, const KRColor& color)
{
    _getTexture(texID)->drawAtPointEx_(pos, srcRect, rotate, origin, scale, color);
}


#pragma mark -
#pragma mark ---- テクスチャの描画（中心点指定） ----

void KRTexture2DManager::drawAtPointCenter(int texID, const KRVector2D& centerPos, double alpha)
{
    _getTexture(texID)->drawAtPointCenter_(centerPos, KRColor(1, 1, 1, alpha));
}

void KRTexture2DManager::drawAtPointCenter(int texID, const KRVector2D& centerPos, const KRColor& color)
{
    _getTexture(texID)->drawAtPointCenter_(centerPos, color);
}

void KRTexture2DManager::drawAtPointCenterEx(int texID, const KRVector2D& centerPos, double rotate, const KRVector2D& scale, double alpha)
{
    _getTexture(texID)->drawAtPointCenterEx_(centerPos, KRRect2DZero, rotate, scale, KRColor(1, 1, 1, alpha));
}

void KRTexture2DManager::drawAtPointCenterEx(int texID, const KRVector2D& centerPos, double rotate, const KRVector2D& scale, const KRColor& color)
{
    _getTexture(texID)->drawAtPointCenterEx_(centerPos, KRRect2DZero, rotate, scale, color);
}

void KRTexture2DManager::drawAtPointCenterEx2(int texID, const KRVector2D& centerPos, const KRRect2D& srcRect, double rotate, const KRVector2D& scale, double alpha)
{
    _getTexture(texID)->drawAtPointCenterEx_(centerPos, srcRect, rotate, scale, KRColor(1, 1, 1, alpha));
}

void KRTexture2DManager::drawAtPointCenterEx2(int texID, const KRVector2D& centerPos, const KRRect2D& srcRect, double rotate, const KRVector2D& scale, const KRColor& color)
{
    _getTexture(texID)->drawAtPointCenterEx_(centerPos, srcRect, rotate, scale, color);
}


#pragma mark -
#pragma mark ---- テクスチャの描画（矩形指定） ----

void KRTexture2DManager::drawInRect(int texID, const KRRect2D& destRect, double alpha)
{
    _getTexture(texID)->drawInRect_(destRect, KRColor(1, 1, 1, alpha));
}

void KRTexture2DManager::drawInRect(int texID, const KRRect2D& destRect, const KRColor& color)
{
    _getTexture(texID)->drawInRect_(destRect, color);
}

void KRTexture2DManager::drawInRect(int texID, const KRRect2D& destRect, const KRRect2D& srcRect, double alpha)
{
    _getTexture(texID)->drawInRect_(destRect, srcRect, KRColor(1, 1, 1, alpha));
}

void KRTexture2DManager::drawInRect(int texID, const KRRect2D& destRect, const KRRect2D& srcRect, const KRColor& color)
{
    _getTexture(texID)->drawInRect_(destRect, srcRect, color);
}


#pragma mark -
#pragma mark ---- アトラスの描画 ----

void KRTexture2DManager::drawAtlasAtPoint(int texID, const KRVector2DInt& atlasPos, const KRVector2D& pos, double alpha)
{
    drawAtlasAtPoint(texID, atlasPos, pos, KRColor(1, 1, 1, alpha));
}

void KRTexture2DManager::drawAtlasAtPoint(int texID, const KRVector2DInt& atlasPos, const KRVector2D& pos, const KRColor& color)
{
    _KRTexture2D* theTex = _getTexture(texID);
    KRVector2D atlasSize = theTex->getAtlasSize();
    
    KRRect2D srcRect(atlasSize.x * atlasPos.x, atlasSize.y * atlasPos.y, atlasSize.x, atlasSize.y);

    theTex->drawAtPointEx_(pos, srcRect, 0.0, KRVector2DZero, KRVector2DOne, color);
}

void KRTexture2DManager::drawAtlasAtPointEx(int texID, const KRVector2DInt& atlasPos, const KRVector2D& pos, double rotate, const KRVector2D& origin, const KRVector2D& scale, double alpha)
{
    drawAtlasAtPointEx(texID, atlasPos, pos, rotate, origin, scale, KRColor(1, 1, 1, alpha));
}

void KRTexture2DManager::drawAtlasAtPointEx(int texID, const KRVector2DInt& atlasPos, const KRVector2D& pos, double rotate, const KRVector2D& origin, const KRVector2D& scale, const KRColor& color)
{
    _KRTexture2D* theTex = _getTexture(texID);
    KRVector2D atlasSize = theTex->getAtlasSize();
    
    int theY = atlasPos.y;
    
    if (theTex->isAtlasFlipped()) {
        theY = theTex->getDivY() - atlasPos.y - 1;
    }
    
    KRRect2D srcRect(atlasSize.x * atlasPos.x, atlasSize.y * theY, atlasSize.x, atlasSize.y);
    
    theTex->drawAtPointEx_(pos, srcRect, rotate, origin, scale, color);
}

void KRTexture2DManager::drawAtlasAtPointCenter(int texID, const KRVector2DInt& atlasPos, const KRVector2D& centerPos, double alpha)
{
    drawAtlasAtPointCenter(texID, atlasPos, centerPos, KRColor(1, 1, 1, alpha));
}

void KRTexture2DManager::drawAtlasAtPointCenter(int texID, const KRVector2DInt& atlasPos, const KRVector2D& centerPos, const KRColor& color)
{
    _KRTexture2D* theTex = _getTexture(texID);
    KRVector2D atlasSize = theTex->getAtlasSize();
    
    KRRect2D srcRect(atlasSize.x * atlasPos.x, atlasSize.y * atlasPos.y, atlasSize.x, atlasSize.y);
    
    theTex->drawAtPointCenterEx_(centerPos, srcRect, 0.0, KRVector2DOne, color);
}

void KRTexture2DManager::drawAtlasAtPointCenterEx(int texID, const KRVector2DInt& atlasPos, const KRVector2D& centerPos, double rotate, const KRVector2D& scale, double alpha)
{
    drawAtlasAtPointCenterEx(texID, atlasPos, centerPos, rotate, scale, KRColor(1, 1, 1, alpha));
}

void KRTexture2DManager::drawAtlasAtPointCenterEx(int texID, const KRVector2DInt& atlasPos, const KRVector2D& centerPos, double rotate, const KRVector2D& scale, const KRColor& color)
{
    _KRTexture2D* theTex = _getTexture(texID);
    KRVector2D atlasSize = theTex->getAtlasSize();
    
    KRRect2D srcRect(atlasSize.x * atlasPos.x, atlasSize.y * atlasPos.y, atlasSize.x, atlasSize.y);
    
    theTex->drawAtPointCenterEx_(centerPos, srcRect, rotate, scale, color);
}

void KRTexture2DManager::drawAtlasInRect(int texID, const KRVector2DInt& atlasPos, const KRRect2D& destRect, double alpha)
{
    drawAtlasInRect(texID, atlasPos, destRect, KRColor(1, 1, 1, alpha));
}

void KRTexture2DManager::drawAtlasInRect(int texID, const KRVector2DInt& atlasPos, const KRRect2D& destRect, const KRColor& color)
{
    _KRTexture2D* theTex = _getTexture(texID);
    KRVector2D atlasSize = theTex->getAtlasSize();
    
    KRRect2D srcRect(atlasSize.x * atlasPos.x, atlasSize.y * atlasPos.y, atlasSize.x, atlasSize.y);
    
    theTex->drawInRect_(destRect, srcRect, color);
}


