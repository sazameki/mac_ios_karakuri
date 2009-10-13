//
//  KarakuriWorld.cpp
//  Karakuri Prototype
//
//  Created by numata on 09/07/23.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#include <Karakuri/KarakuriWorld.h>

#include <Karakuri/KRControlManager.h>

#import "KarakuriController.h"
#import "KRTextReader.h"


void *gInputLogHandle = nil;
unsigned gInputLogFrameCounter = 0;


KRWorld::KRWorld()
    : mIsLoadingWorld(false)
{
}

#pragma mark -
#pragma mark Pre-process World Management

void KRWorld::startBecameActive()
{
    gKRInputInst->resetAllInputs();
    
    mHasDummyInputSource = false;
    mDummyInputSourceDataPos = 0;
    mDummyInputSourceDataList.clear();

    gInputLogHandle = nil;
    gInputLogFrameCounter = 0;

    mIsControlProcessEnabled = true;

    mControlManager = new KRControlManager();

    becameActive();
    
    if (mHasDummyInputSource) {
        gKRInputInst->plugDummySourceIn();
    }
}

void KRWorld::startResignedActive()
{    
    resignedActive();
    
    if ((NSFileHandle *)gInputLogHandle != nil) {
        [(NSFileHandle *)gInputLogHandle writeData:[@"# Log End\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [(NSFileHandle *)gInputLogHandle closeFile];
        gInputLogHandle = nil;
    }
    
    gKRInputInst->pullDummySourceOut();

    delete mControlManager;
    mControlManager = NULL;
}

void KRWorld::startUpdateModel(KRInput *input)
{
#if KR_MACOSX
    if ((NSFileHandle *)gInputLogHandle != nil && (input->getMouseState() & KRInput::MouseButtonAny)) {
        input->processMouseDrag();
    }
#endif
    
    if (mHasDummyInputSource && mDummyInputSourceDataPos < mDummyInputSourceDataList.size()) {
        KRInputSourceData& inputSourceData = mDummyInputSourceDataList[mDummyInputSourceDataPos];
        if (inputSourceData.frame <= gInputLogFrameCounter) {
            input->processDummyData(inputSourceData);
            mDummyInputSourceDataPos++;
        }
    }
    
    mHasProcessedControl = false;
    if (mIsControlProcessEnabled && mControlManager->updateControls(input)) {
        mHasProcessedControl = true;
    }

    updateModel(input);
    
    gInputLogFrameCounter++;
}

void KRWorld::startDrawView(KRGraphics *g)
{
    drawView(g);
    
    mControlManager->drawAllControls(g);
}


#pragma mark -

std::string KRWorld::getLoadingScreenWorldName() const
{
    return "";
}

void KRWorld::saveForEmergency(KRSaveBox *saveBox)
{
    // Do nothing
}


#pragma mark -

void KRWorld::addControl(KRControl *aControl)
{
    aControl->setWorld(this);
    mControlManager->addControl(aControl);
}

void KRWorld::removeControl(KRControl *aControl)
{
    mControlManager->removeControl(aControl);
    aControl->setWorld(NULL);
}

bool KRWorld::hasProcessedControl() const
{
    return mHasProcessedControl;
}

void KRWorld::startControlProcess()
{
    mIsControlProcessEnabled = true;
}

void KRWorld::stopControlProcess()
{
    mIsControlProcessEnabled = false;
}

void KRWorld::buttonPressed(KRButton *aButton)
{
    // Do nothing
}

void KRWorld::sliderValueChanged(KRSlider *slider)
{
    // Do nothing
}

void KRWorld::switchStateChanged(KRSwitch *switcher)
{
    // Do nothing
}


#pragma mark -
#pragma mark Dummy Input Support

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

static void makeDirectories(NSString *path)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        return;
    }
    
    NSString *basePath = [path stringByDeletingLastPathComponent];
    makeDirectories(basePath);
    
    [fileManager createDirectoryAtPath:path attributes:nil];
}

std::string KRWorld::startInputLog()
{
    if (mIsLoadingWorld) {
        const char *errorFormat = "startInputLog(): Cannot log user inputs in loading screen world: \"%s\"";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "startInputLog(): 読み込み画面のためのワールド \"%s\" では、ユーザ入力のログ出力はできません。";
        }
        throw KRRuntimeError(errorFormat, getName().c_str());
    }

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|
                                                             NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit)
                                                   fromDate:[NSDate date]];
    
    int year = [dateComponents year];
    int month = [dateComponents month];
    int day = [dateComponents day];
    int hour = [dateComponents hour];
    int minute = [dateComponents minute];
    int second = [dateComponents second];
    
    NSMutableString *worldName = [[NSMutableString new] autorelease];
    [worldName appendString:[NSString stringWithCString:getName().c_str() encoding:NSUTF8StringEncoding]];
    [worldName replaceOccurrencesOfString:@" " withString:@"-" options:0 range:NSMakeRange(0, [worldName length])];
    
#if KR_MACOSX
    NSString *filename = [NSString stringWithFormat:@"MacOSX__%@__%04d%02d%02d_%02d%02d%02d.log", worldName, year, month, day, hour, minute, second];
#else
    NSString *filename = [NSString stringWithFormat:@"iPhone__%@__%04d%02d%02d_%02d%02d%02d.log", worldName, year, month, day, hour, minute, second];
#endif
    
    NSString *baseDirPath = nil;

#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    NSMutableString *titleName = [NSString stringWithCString:gKRGameInst->getTitle().c_str() encoding:NSUTF8StringEncoding];
    NSString *bundleID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    baseDirPath = [[NSString stringWithFormat:@"~/Library/Application Support/Karakuri/%@/%@/Input Log", bundleID, titleName] stringByExpandingTildeInPath];
#else
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    baseDirPath = [documentsDirectory stringByAppendingPathComponent:@"Input Log"];
#endif
    
    makeDirectories(baseDirPath);
    
    NSString *filepath = [baseDirPath stringByAppendingPathComponent:filename];
    
    [[NSData data] writeToFile:filepath atomically:NO];
    gInputLogHandle = [[NSFileHandle fileHandleForWritingAtPath:filepath] retain];
    [(NSFileHandle *)gInputLogHandle writeData:[@"# Karakuri Input Log\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [(NSFileHandle *)gInputLogHandle writeData:[@"# @version 1.0\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [(NSFileHandle *)gInputLogHandle writeData:[[NSString stringWithFormat:@"# @date %04d/%02d/%02d %02d:%02d:%02d\n", year, month, day, hour, minute, second] dataUsingEncoding:NSUTF8StringEncoding]];
    
#if KR_MACOSX
    [(NSFileHandle *)gInputLogHandle writeData:[@"# @target Mac OS X\n" dataUsingEncoding:NSUTF8StringEncoding]];
#endif
    
#if KR_IPHONE
    [(NSFileHandle *)gInputLogHandle writeData:[@"# @target iPhone\n" dataUsingEncoding:NSUTF8StringEncoding]];
#endif

    [calendar release];
    
    std::string ret = [(NSString *)filename cStringUsingEncoding:NSUTF8StringEncoding];
    
    return ret;
}

void KRWorld::setDummyInputSource(const std::string& filename)
{
    mDummyInputSourceDataPos = 0;
    mDummyInputSourceDataList.clear();

    try {
        KRTextReader reader(filename);
        
        std::string aLine;
        while (reader.readLine(&aLine)) {
            if (aLine.length() == 0 || aLine[0] == '#') {
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
                    unsigned char mouseMaskC = aLine[pos];
                    if (mouseMaskC == '1') {
                        aData.data_mask = KRInput::MouseButtonLeft;
                    } else {
                        aData.data_mask = KRInput::MouseButtonRight;
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
        
        mHasDummyInputSource = true;
    } catch (KRRuntimeError& e) {
        const char *errorFormat = "Failed to open dummy input file \"%s\". Please confirm that the file exists.";
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

