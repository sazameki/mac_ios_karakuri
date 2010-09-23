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
    // 1000以上の ID は予約済み
    if (texID >= 1000) {
        const char *errorFormat = "Texture ID should be lower than a thousand (1000).";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "テクスチャIDは 999 以下でなければいけません。";
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
}

void KRTexture2DManager::_addTexture(int groupID, int texID, const std::string& resourceName, const std::string& resourceFileName, unsigned pos, unsigned length)
{
    static int undefinedTexID = 1000000;
    if (texID == 0) {
        texID = undefinedTexID;
        undefinedTexID++;
    }    
    
    std::vector<int>& theTexIDList = mGroupID_TexIDList_Map[groupID];
    theTexIDList.push_back(texID);
    
    _KRTexture2DResourceInfo info;
    info.start_pos = pos;
    info.length = length;
    info.file_name = resourceFileName;
    info.scale_mode = KRTexture2DScaleModeLinear;
    
    mTexID_ResourceInfo_Map[texID] = info;
}

int KRTexture2DManager::_getResourceSizeInGroup(int groupID)
{
    int ret = 0;
    
    std::vector<int>& theTexIDList = mGroupID_TexIDList_Map[groupID];
    
    for (std::vector<int>::const_iterator it = theTexIDList.begin(); it != theTexIDList.end(); it++) {
        int texID = *it;        

        int resourceSize;
        if (texID >= 1000) {
            resourceSize = mTexID_ResourceInfo_Map[texID].length;
        } else {
            std::string filename = mTexID_ImageFileName_Map[texID];
            resourceSize = _KRTexture2D::getResourceSize(filename);
        }
        ret += resourceSize;
    }
    
    return ret;
}

void KRTexture2DManager::_loadTextureFilesInGroup(int groupID, KRWorld* loaderWorld, double minDuration)
{
    std::vector<int>& theTexIDList = mGroupID_TexIDList_Map[groupID];

    int allResourceSize = 0;
    NSTimeInterval sleepTime = 0.2;

    // 全リソースサイズの計算
    for (std::vector<int>::const_iterator it = theTexIDList.begin(); it != theTexIDList.end(); it++) {
        int texID = *it;

        int resourceSize;
        if (texID >= 1000) {
            resourceSize = mTexID_ResourceInfo_Map[texID].length;
        } else {
            std::string filename = mTexID_ImageFileName_Map[texID];
            resourceSize = _KRTexture2D::getResourceSize(filename);
        }
        allResourceSize += resourceSize;
    }

    // 全リソースの読み込み
    for (std::vector<int>::const_iterator it = theTexIDList.begin(); it != theTexIDList.end(); it++) {
        int texID = *it;

        // リソースサイズの取得
        int resourceSize;
        if (texID >= 1000) {
            resourceSize = mTexID_ResourceInfo_Map[texID].length;
        } else {
            std::string filename = mTexID_ImageFileName_Map[texID];
            resourceSize = _KRTexture2D::getResourceSize(filename);
        }

        // リソースの読み込み処理
        double theMinDuration = ((double)resourceSize / allResourceSize) * minDuration;
        
        int baseFinishedSize = 0;
        if (loaderWorld != NULL) {
            baseFinishedSize = loaderWorld->_getFinishedSize();
        }
        
        NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
        if (mTexMap[texID] == NULL) {
            if (texID >= 1000) {
                _KRTexture2DResourceInfo info = mTexID_ResourceInfo_Map[texID];
                mTexMap[texID] = new _KRTexture2D(info.file_name, info.start_pos, info.length, info.scale_mode);
            } else {
                KRTexture2DScaleMode scaleMode = mTexID_ScaleMode_Map[texID];
                std::string filename = mTexID_ImageFileName_Map[texID];
                mTexMap[texID] = new _KRTexture2D(filename, scaleMode);
            }
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
            loaderWorld->_setFinishedSize(baseFinishedSize + resourceSize);
        }
    }
}

void KRTexture2DManager::_unloadTextureFilesInGroup(int groupID)
{
    std::vector<int>& theTexIDList = mGroupID_TexIDList_Map[groupID];

    for (std::vector<int>::const_iterator it = theTexIDList.begin(); it != theTexIDList.end(); it++) {
        int texID = *it;
        if (mTexMap[texID] != NULL) {
            delete mTexMap[texID];
            mTexMap[texID] = NULL;
        }
    }
}

_KRTexture2D* KRTexture2DManager::_getTexture(int texID)
{
    _KRTexture2D* ret = mTexMap[texID];

    if (ret == NULL) {
        const char *errorFormat = "Texture is not loaded with ID %d.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "ID が %d のテクスチャはロードされていません。";
        }
        throw KRRuntimeError(errorFormat, texID);
    }

    return mTexMap[texID];
}

KRVector2D KRTexture2DManager::getTextureSize(int texID)
{
    return _getTexture(texID)->getSize();
}


#pragma mark -
#pragma mark ---- テクスチャの描画（基本） ----

void KRTexture2DManager::drawAtPoint(int texID, const KRVector2D& pos, double alpha)
{
    _getTexture(texID)->drawAtPoint(pos, KRColor(1, 1, 1, alpha));
}

void KRTexture2DManager::drawAtPoint(int texID, const KRVector2D& pos, const KRColor& color)
{
    _getTexture(texID)->drawAtPoint(pos, color);
}

void KRTexture2DManager::drawAtPointEx(int texID, const KRVector2D& pos, double rotate, const KRVector2D& origin, const KRVector2D& scale, double alpha)
{
    _getTexture(texID)->drawAtPointEx(pos, KRRect2DZero, rotate, origin, scale, KRColor(1, 1, 1, alpha));
}

void KRTexture2DManager::drawAtPointEx(int texID, const KRVector2D& pos, double rotate, const KRVector2D& origin, const KRVector2D& scale, const KRColor& color)
{
    _getTexture(texID)->drawAtPointEx(pos, KRRect2DZero, rotate, origin, scale, color);
}

void KRTexture2DManager::drawAtPointEx2(int texID, const KRVector2D& pos, const KRRect2D& srcRect, double rotate, const KRVector2D& origin, const KRVector2D& scale, double alpha)
{
    _getTexture(texID)->drawAtPointEx(pos, srcRect, rotate, origin, scale, KRColor(1, 1, 1, alpha));
}

void KRTexture2DManager::drawAtPointEx2(int texID, const KRVector2D& pos, const KRRect2D& srcRect, double rotate, const KRVector2D& origin, const KRVector2D& scale, const KRColor& color)
{
    _getTexture(texID)->drawAtPointEx(pos, srcRect, rotate, origin, scale, color);
}


#pragma mark -
#pragma mark ---- テクスチャの描画（中心点指定） ----

void KRTexture2DManager::drawAtPointCenter(int texID, const KRVector2D& centerPos, double alpha)
{
    _getTexture(texID)->drawAtPointCenter(centerPos, KRColor(1, 1, 1, alpha));
}

void KRTexture2DManager::drawAtPointCenter(int texID, const KRVector2D& centerPos, const KRColor& color)
{
    _getTexture(texID)->drawAtPointCenter(centerPos, color);
}

void KRTexture2DManager::drawAtPointCenterEx(int texID, const KRVector2D& centerPos, double rotate, const KRVector2D& scale, double alpha)
{
    _getTexture(texID)->drawAtPointCenterEx(centerPos, KRRect2DZero, rotate, scale, KRColor(1, 1, 1, alpha));
}

void KRTexture2DManager::drawAtPointCenterEx(int texID, const KRVector2D& centerPos, double rotate, const KRVector2D& scale, const KRColor& color)
{
    _getTexture(texID)->drawAtPointCenterEx(centerPos, KRRect2DZero, rotate, scale, color);
}

void KRTexture2DManager::drawAtPointCenterEx2(int texID, const KRVector2D& centerPos, const KRRect2D& srcRect, double rotate, const KRVector2D& scale, double alpha)
{
    _getTexture(texID)->drawAtPointCenterEx(centerPos, srcRect, rotate, scale, KRColor(1, 1, 1, alpha));
}

void KRTexture2DManager::drawAtPointCenterEx2(int texID, const KRVector2D& centerPos, const KRRect2D& srcRect, double rotate, const KRVector2D& scale, const KRColor& color)
{
    _getTexture(texID)->drawAtPointCenterEx(centerPos, srcRect, rotate, scale, color);
}


#pragma mark -
#pragma mark ---- テクスチャの描画（矩形指定） ----

void KRTexture2DManager::drawInRect(int texID, const KRRect2D& destRect, double alpha)
{
    _getTexture(texID)->drawInRect(destRect, KRColor(1, 1, 1, alpha));
}

void KRTexture2DManager::drawInRect(int texID, const KRRect2D& destRect, const KRColor& color)
{
    _getTexture(texID)->drawInRect(destRect, color);
}

void KRTexture2DManager::drawInRect(int texID, const KRRect2D& destRect, const KRRect2D& srcRect, double alpha)
{
    _getTexture(texID)->drawInRect(destRect, srcRect, KRColor(1, 1, 1, alpha));
}

void KRTexture2DManager::drawInRect(int texID, const KRRect2D& destRect, const KRRect2D& srcRect, const KRColor& color)
{
    _getTexture(texID)->drawInRect(destRect, srcRect, color);
}


