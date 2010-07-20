//
//  KRWorld.cpp
//  Karakuri Prototype
//
//  Created by numata on 09/07/23.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#include <Karakuri/KRWorld.h>

#include <Karakuri/KRControlManager.h>
#include <Karakuri/KRAudioManager.h>
#include <Karakuri/KRWorldManager.h>

#import "KRGameController.h"
#import "KRTextReader.h"


void*       gInputLogHandle = nil;
unsigned    gInputLogFrameCounter = 0;


KRWorld::KRWorld()
    : mIsLoadingWorld(false)
{
    mResourceLoadingWorld = NULL;
}

#pragma mark -
#pragma mark Pre-process World Management

void KRWorld::startBecameActive()
{
    gKRInputInst->_resetAllInputs();
    gKRRandInst->resetSeed();
    
    mHasDummyInputSource = false;
    mDummyInputSourceDataPos = 0;
    mDummyInputSourceDataList.clear();

    gInputLogHandle = nil;
    gInputLogFrameCounter = 0;

    mIsControlProcessDisabled = false;
    mIsManualControlManagementEnabled = false;
    mIsShowingLoadingWorld = false;

    mControlManager = new KRControlManager();

    becameActive();
    
    if (mHasDummyInputSource) {
        gKRInputInst->_plugDummySourceIn();
    }
}

void KRWorld::startResignedActive()
{    
    resignedActive();
    
    if ((NSFileHandle*)gInputLogHandle != nil) {
        [(NSFileHandle*)gInputLogHandle writeData:[@"# Log End\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [(NSFileHandle*)gInputLogHandle closeFile];
        gInputLogHandle = nil;
    }
    
    gKRInputInst->_pullDummySourceOut();

    delete mControlManager;
    mControlManager = NULL;
}

void KRWorld::startUpdateModel(KRInput* input)
{
#if KR_MACOSX
    if ((NSFileHandle*)gInputLogHandle != nil && (input->_getMouseState() & KRInput::_MouseButtonAny)) {
        input->_processMouseDrag();
    }
#endif
    
    if (mHasDummyInputSource && mDummyInputSourceDataPos < mDummyInputSourceDataList.size()) {
        KRInputSourceData& inputSourceData = mDummyInputSourceDataList[mDummyInputSourceDataPos];
        if (inputSourceData.frame <= gInputLogFrameCounter) {
            input->_processDummyData(inputSourceData);
            mDummyInputSourceDataPos++;
        }
    }
    
    input->_updateOnceInfo();
    
    mHasProcessedControl = false;
    if (!mIsControlProcessDisabled && !mIsManualControlManagementEnabled) {
        processControls(input);
    }

    updateModel(input);
    
    gKRAnime2DMan->stepAllCharas();

    gInputLogFrameCounter++;
}

void KRWorld::startDrawView(KRGraphics* g)
{
    drawView(g);
    
    if (!mIsManualControlManagementEnabled) {
        drawControls(g);
    }
}


#pragma mark -

bool KRWorld::hasLoadedResourceGroup(int groupID)
{
    return false;
}

double KRWorld::getLoadingProgress() const
{
    if (mResourceLoadingWorld != NULL) {
        return mResourceLoadingWorld->getLoadingProgress();
    }
    return (double)mLoadingResourceFinishedSize / mLoadingResourceAllSize;
}

void KRWorld::startLoadingWorld(const std::string& loadingWorldName, double minDuration)
{
    if (mResourceLoadingWorld != NULL) {
        if (gKRLanguage == KRLanguageJapanese) {
            std::string errorFormat = "読み込み画面用ワールド \"" + getName() + "\" の中で、別の読み込み画面を使うことはできません。";
            throw KRRuntimeError(errorFormat);
        } else {
            std::string errorFormat = "You cannot use an extra loading screen in a loading screen world \"" + getName() + "\".";
            throw KRRuntimeError(errorFormat);
        }
    }
    
    mIsShowingLoadingWorld = true;
    mLoadingResourceGroupIDs.clear();
    mLoadingResourceAllSize = 0;
    mLoadingResourceFinishedSize = 0;
    mLoadingResourceMinDuration = minDuration;

    KRWorld* loadingWorld = gKRWorldManagerInst->getWorldWithName(loadingWorldName);

    if (loadingWorld == NULL) {
        if (gKRLanguage == KRLanguageJapanese) {
            std::string errorFormat = "\"" + getName() + "\" ワールドのための読み込み画面用ワールド \"" + loadingWorldName + "\" は見つかりませんでした。";
            throw KRRuntimeError(errorFormat);
        } else {
            std::string errorFormat = "World \"" + loadingWorldName + "\" was not found for loading screen at \"" + getName() + "\" world.";
            throw KRRuntimeError(errorFormat);
        }
    }
    
    loadingWorld->setResourceLoadingWorld(this);
    
    [[KRGameController sharedController] startLoadingWorld:loadingWorld];    
}

void KRWorld::setResourceLoadingWorld(KRWorld* aWorld) KARAKURI_FRAMEWORK_INTERNAL_USE_ONLY
{
    mResourceLoadingWorld = aWorld;
}

void KRWorld::loadResourceGroup(int groupID)
{
    if (mIsShowingLoadingWorld) {
        mLoadingResourceAllSize += gKRTex2DMan->_getResourceSize(groupID);
        mLoadingResourceAllSize += gKRAudioMan->_getResourceSize(groupID);
        mLoadingResourceGroupIDs.push_back(groupID);
    } else {
        gKRTex2DMan->_loadTextureFiles(groupID, NULL, 0.0);
        gKRAudioMan->_loadAudioFiles(groupID, NULL, 0.0);
    }
}

void KRWorld::finishLoadingWorld()
{
    if (mIsShowingLoadingWorld) {
        for (std::vector<int>::iterator it = mLoadingResourceGroupIDs.begin(); it != mLoadingResourceGroupIDs.end(); it++) {
            int resourceSize = gKRTex2DMan->_getResourceSize(*it);
            double ratio = (double)resourceSize / mLoadingResourceAllSize;
            double minDuration = ratio * mLoadingResourceMinDuration;
            
            gKRTex2DMan->_loadTextureFiles(*it, this, minDuration);
        }

        for (std::vector<int>::iterator it = mLoadingResourceGroupIDs.begin(); it != mLoadingResourceGroupIDs.end(); it++) {
            int resourceSize = gKRAudioMan->_getResourceSize(*it);
            double ratio = (double)resourceSize / mLoadingResourceAllSize;
            double minDuration = ratio * mLoadingResourceMinDuration;

            gKRAudioMan->_loadAudioFiles(*it, this, minDuration);
        }
        
        if (mLoadingResourceAllSize == 0) {
            mLoadingResourceAllSize = 100;
            int divCount = 10;
            double oneDuration = mLoadingResourceMinDuration / divCount;
            double oneSize = mLoadingResourceAllSize / divCount;
            for (int i = 0; i < divCount; i++) {
                _setFinishedSize(oneSize * i);
                KRSleep(oneDuration);
            }
            _setFinishedSize(mLoadingResourceAllSize);
        }
        
        KRSleep(1.0);
    }

    [[KRGameController sharedController] finishLoadingWorld];
    
    mIsShowingLoadingWorld = false;
}

void KRWorld::unloadResourceGroup(int groupID)
{
}

int KRWorld::_getFinishedSize()
{
    return mLoadingResourceFinishedSize;
}

void KRWorld::_setFinishedSize(int size)
{
    mLoadingResourceFinishedSize = size;
}


#pragma mark -

void KRWorld::saveForEmergency(KRSaveBox* saveBox)
{
    // Do nothing
}


#pragma mark -

void KRWorld::addControl(KRControl* aControl, int groupID)
{
    aControl->setWorld(this);
    mControlManager->addControl(aControl, groupID);
}

void KRWorld::removeControl(KRControl* aControl)
{
    mControlManager->removeControl(aControl);
    aControl->setWorld(NULL);
}

bool KRWorld::hasProcessedControl() const
{
    return mHasProcessedControl;
}

void KRWorld::disableControlProcess(bool flag)
{
    mIsControlProcessDisabled = flag;
}

bool KRWorld::processControls(KRInput* input, int groupID)
{
    if (mControlManager->updateControls(input, groupID)) {
        mHasProcessedControl = true;
    }
    return mHasProcessedControl;
}

void KRWorld::enableManualControlManagement(bool flag)
{
    mIsManualControlManagementEnabled = flag;
}

bool KRWorld::isManualControlManagementEnabled() const
{
    return mIsManualControlManagementEnabled;
}

void KRWorld::drawControls(KRGraphics* g, int groupID)
{
    mControlManager->drawAllControls(g, groupID);
}

void KRWorld::buttonPressed(KRButton* aButton)
{
    // Do nothing
}

void KRWorld::sliderValueChanged(KRSlider* slider)
{
    // Do nothing
}

void KRWorld::switchStateChanged(KRSwitch* switcher)
{
    // Do nothing
}


#pragma mark -
#pragma mark Dummy Input Support

std::vector<std::string> KRWorld::listAllInputLogFiles() const
{
    std::vector<std::string> ret;

    NSString* baseDirPath = nil;
    
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    NSMutableString* titleName = [NSString stringWithCString:gKRGameMan->getTitle().c_str() encoding:NSUTF8StringEncoding];
    NSString* bundleID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    baseDirPath = [[NSString stringWithFormat:@"~/Library/Application Support/Karakuri/%@/%@/Input Log", bundleID, titleName] stringByExpandingTildeInPath];
#else
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    baseDirPath = [documentsDirectory stringByAppendingPathComponent:@"Input Log"];
#endif
    
    NSMutableArray* logFiles = [NSMutableArray array];
    
    NSArray* filesInDir = [[NSFileManager defaultManager] directoryContentsAtPath:baseDirPath];
    for (unsigned i = 0; i < [filesInDir count]; i++) {
        NSString* aFileName = [filesInDir objectAtIndex:i];
        if ([[[aFileName pathExtension] lowercaseString] isEqualToString:@"log"]) {
            [logFiles addObject:aFileName];
        }
    }
    
    [logFiles sortUsingSelector:@selector(compare:)];
    
    for (unsigned i = 0; i < [logFiles count]; i++) {
        NSString* aFileName = [logFiles objectAtIndex:i];
        std::string theStr = [aFileName cStringUsingEncoding:NSUTF8StringEncoding];
        ret.push_back(theStr);
    }

    return ret;
}

bool KRWorld::hasDummyInputSource() const
{
    return mHasDummyInputSource;
}

bool KRWorld::hasMoreDummyInputData() const
{
    if (!mHasDummyInputSource) {
        return false;
    }
    return (mDummyInputSourceDataPos < mDummyInputSourceDataList.size())? true: false;
}

static void makeDirectories(NSString* path)
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        return;
    }
    
    NSString* basePath = [path stringByDeletingLastPathComponent];
    makeDirectories(basePath);
    
    [fileManager createDirectoryAtPath:path attributes:nil];
}

std::string KRWorld::startInputLog()
{
    if (mIsLoadingWorld) {
        const char* errorFormat = "startInputLog(): Cannot log user inputs in loading screen world: \"%s\"";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "startInputLog(): 読み込み画面のためのワールド \"%s\" では、ユーザ入力のログ出力はできません。";
        }
        throw KRRuntimeError(errorFormat, getName().c_str());
    }

    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents* dateComponents = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|
                                                             NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit)
                                                   fromDate:[NSDate date]];
    
    int year = [dateComponents year];
    int month = [dateComponents month];
    int day = [dateComponents day];
    int hour = [dateComponents hour];
    int minute = [dateComponents minute];
    int second = [dateComponents second];
    
    NSMutableString* worldName = [[NSMutableString new] autorelease];
    [worldName appendString:[NSString stringWithCString:getName().c_str() encoding:NSUTF8StringEncoding]];
    [worldName replaceOccurrencesOfString:@" " withString:@"-" options:0 range:NSMakeRange(0, [worldName length])];
    
#if KR_MACOSX
    NSString* filename = [NSString stringWithFormat:@"MacOSX__%@__%04d%02d%02d_%02d%02d%02d.log", worldName, year, month, day, hour, minute, second];
#else
    NSString* filename = [NSString stringWithFormat:@"iPhone__%@__%04d%02d%02d_%02d%02d%02d.log", worldName, year, month, day, hour, minute, second];
#endif
    
    NSString* baseDirPath = nil;

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    NSMutableString* titleName = [NSString stringWithCString:gKRGameMan->getTitle().c_str() encoding:NSUTF8StringEncoding];
    NSString* bundleID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    baseDirPath = [[NSString stringWithFormat:@"~/Library/Application Support/Karakuri/%@/%@/Input Log", bundleID, titleName] stringByExpandingTildeInPath];
#else
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    baseDirPath = [documentsDirectory stringByAppendingPathComponent:@"Input Log"];
#endif
    
    makeDirectories(baseDirPath);
    
    NSString* filepath = [baseDirPath stringByAppendingPathComponent:filename];
    
    [[NSData data] writeToFile:filepath atomically:NO];
    gInputLogHandle = [[NSFileHandle fileHandleForWritingAtPath:filepath] retain];
    [(NSFileHandle*)gInputLogHandle writeData:[@"# Karakuri Input Log\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [(NSFileHandle*)gInputLogHandle writeData:[@"# @version 1.0\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [(NSFileHandle*)gInputLogHandle writeData:[[NSString stringWithFormat:@"# @date %04d/%02d/%02d %02d:%02d:%02d\n", year, month, day, hour, minute, second] dataUsingEncoding:NSUTF8StringEncoding]];
    
#if KR_MACOSX
    [(NSFileHandle*)gInputLogHandle writeData:[@"# @target Mac OS X\n" dataUsingEncoding:NSUTF8StringEncoding]];
#endif
    
#if KR_IPHONE
    [(NSFileHandle*)gInputLogHandle writeData:[@"# @target iPhone\n" dataUsingEncoding:NSUTF8StringEncoding]];
#endif

    [(NSFileHandle*)gInputLogHandle writeData:[[NSString stringWithFormat:@"# @rand_x %qX\n", gKRRandInst->getX()] dataUsingEncoding:NSUTF8StringEncoding]];
    [(NSFileHandle*)gInputLogHandle writeData:[[NSString stringWithFormat:@"# @rand_y %qX\n", gKRRandInst->getY()] dataUsingEncoding:NSUTF8StringEncoding]];
    [(NSFileHandle*)gInputLogHandle writeData:[[NSString stringWithFormat:@"# @rand_z %qX\n", gKRRandInst->getZ()] dataUsingEncoding:NSUTF8StringEncoding]];
    [(NSFileHandle*)gInputLogHandle writeData:[[NSString stringWithFormat:@"# @rand_w %qX\n", gKRRandInst->getW()] dataUsingEncoding:NSUTF8StringEncoding]];

    [calendar release];
    
    std::string ret = [(NSString*)filename cStringUsingEncoding:NSUTF8StringEncoding];
    
    return ret;
}

void KRWorld::setDummyInputSource(const std::string& filename)
{
    mDummyInputSourceDataPos = 0;
    mDummyInputSourceDataList.clear();

    try {
        KRTextReader reader(filename);
        
        unsigned rand_x = 0, rand_y = 0, rand_z = 0, rand_w = 0;
        
        std::string aLine;
        while (reader.readLine(&aLine)) {
            if (aLine.length() == 0 || aLine[0] == '#') {
                if (aLine.substr(2, 7) == "@rand_x") {
                    std::string xStr = aLine.substr(10);
                    rand_x = strtoul(xStr.c_str(), NULL, 16);
                } else if (aLine.substr(2, 7) == "@rand_y") {
                    std::string yStr = aLine.substr(10);
                    rand_y = strtoul(yStr.c_str(), NULL, 16);
                } else if (aLine.substr(2, 7) == "@rand_z") {
                    std::string zStr = aLine.substr(10);
                    rand_z = strtoul(zStr.c_str(), NULL, 16);
                } else if (aLine.substr(2, 7) == "@rand_w") {
                    std::string wStr = aLine.substr(10);
                    rand_w = strtoul(wStr.c_str(), NULL, 16);
                }
                continue;
            }

            KRInputSourceData aData;
            unsigned pos = 1;

            // Find frame separator
            while (pos < aLine.length()) {
                if (aLine[pos] == ':') {
                    break;
                }
                pos++;
            }
            std::string frameStr = aLine.substr(0, pos);
            aData.frame = atoi(frameStr.c_str());
            pos++;
            
            aData.command[0] = aLine[pos++];
            aData.command[1] = aLine[pos++];

#if KR_MACOSX
            // Keyboard
            if (aData.command[0] == 'K') {
                std::string keyMaskStr = aLine.substr(pos);
                aData.data_mask = strtoull(keyMaskStr.c_str(), NULL, 16);
                mDummyInputSourceDataList.push_back(aData);
            }
            // Mouse
            else if (aData.command[0] == 'M') {
                if (aData.command[1] == 'D' || aData.command[1] == 'U') {
                    unsigned char mouseMaskC = aLine[pos++];
                    if (mouseMaskC == '1') {
                        aData.data_mask = KRInput::_MouseButtonLeft;
                    } else {
                        aData.data_mask = KRInput::_MouseButtonRight;
                    }
                }
                // Skip '('
                pos++;
                
                // Find comma for X
                unsigned xStartPos = pos;
                while (pos < aLine.length()) {
                    if (aLine[pos] == ',') {
                        break;
                    }
                    pos++;
                }
                std::string xStr = aLine.substr(xStartPos, pos - xStartPos);

                // Find ')' for Y
                pos++;
                unsigned yStartPos = pos;
                while (pos < aLine.length()) {
                    if (aLine[pos] == ')') {
                        break;
                    }
                    pos++;
                }
                std::string yStr = aLine.substr(yStartPos, pos - yStartPos);
                
                aData.location.x = (double)atoi(xStr.c_str());
                aData.location.y = (double)atoi(yStr.c_str());
                
                mDummyInputSourceDataList.push_back(aData);
            }
#endif
            
#if KR_IPHONE
            // Touch
            if (aData.command[0] == 'T') {
                // Find Touch ID End
                unsigned idStartPos = pos;
                while (pos < aLine.length()) {
                    if (aLine[pos] == '(') {
                        break;
                    }
                    pos++;
                }
                std::string touchIDStr = aLine.substr(idStartPos, pos - idStartPos);
                aData.data_mask = (unsigned long long)strtoul(touchIDStr.c_str(), NULL, 16);
                
                // Skip '('
                pos++;
                
                // Find comma for X
                unsigned xStartPos = pos;
                while (pos < aLine.length()) {
                    if (aLine[pos] == ',') {
                        break;
                    }
                    pos++;
                }
                std::string xStr = aLine.substr(xStartPos, pos - xStartPos);
                
                // Find ')' for Y
                pos++;
                unsigned yStartPos = pos;
                while (pos < aLine.length()) {
                    if (aLine[pos] == ')') {
                        break;
                    }
                    pos++;
                }
                std::string yStr = aLine.substr(yStartPos, pos - yStartPos);
                
                aData.location.x = atof(xStr.c_str());
                aData.location.y = atof(yStr.c_str());

                mDummyInputSourceDataList.push_back(aData);
            }
            // Acceleration
            else if (aData.command[0] == 'A') {
                // Skip '('
                pos++;

                // Find comma for X
                unsigned xStartPos = pos;
                while (pos < aLine.length()) {
                    if (aLine[pos] == ',') {
                        break;
                    }
                    pos++;
                }
                std::string xStr = aLine.substr(xStartPos, pos - xStartPos);

                // Find comma for Y
                pos++;
                unsigned yStartPos = pos;
                while (pos < aLine.length()) {
                    if (aLine[pos] == ',') {
                        break;
                    }
                    pos++;
                }
                std::string yStr = aLine.substr(yStartPos, pos - yStartPos);
                
                // Find ')' for Z
                pos++;
                unsigned zStartPos = pos;
                while (pos < aLine.length()) {
                    if (aLine[pos] == ')') {
                        break;
                    }
                    pos++;
                }
                std::string zStr = aLine.substr(zStartPos, pos - zStartPos);
                
                aData.location.x = atof(xStr.c_str());
                aData.location.y = atof(yStr.c_str());
                aData.location.z = atof(zStr.c_str());
                
                mDummyInputSourceDataList.push_back(aData);                
            }
#endif
        }
        
        if (rand_x != 0 && rand_y != 0 && rand_z != 0 && rand_w != 0) {
            gKRRandInst->setXYZW(rand_x, rand_y, rand_z, rand_w);
        }
        
        mHasDummyInputSource = true;
    } catch (KRRuntimeError& e) {
        const char* errorFormat = "Failed to open dummy input file \"%s\". Please confirm that the file exists.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "ダミー入力ファイル \"%s\" の読み込みに失敗しました。";
        }
        throw KRRuntimeError(errorFormat, filename.c_str());
    }
}


#pragma mark -
#pragma mark Debug Support

std::string KRWorld::getName() const
{
    return mName;
}

void KRWorld::setName(const std::string& str)
{
    mName = str;
}

void KRWorld::setLoadingWorld()
{
    mIsLoadingWorld = true;
}

std::string KRWorld::to_s() const
{
    return "<world>(name=\"" + mName + "\")";
}

