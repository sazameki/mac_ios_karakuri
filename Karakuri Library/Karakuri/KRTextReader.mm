/*!
    @file   KRTextReader.cpp
    @author numata
    @date   09/07/29
 */

#include "KRTextReader.h"

#import <Foundation/Foundation.h>
#include <sstream>


/*!
    @method KRTextReader
    Constructor
 */
KRTextReader::KRTextReader(const std::string& filename)
{
    NSString* filenameStr = [[NSString alloc] initWithCString:filename.c_str() encoding:NSUTF8StringEncoding];
	NSString* path = [[NSBundle mainBundle] pathForResource:filenameStr ofType:nil];

    // 
#if KR_MACOSX || KR_IPHONE_MACOSX_EMU
    if (!path) {
        NSMutableString* titleName = [NSString stringWithCString:gKRGameMan->getTitle().c_str() encoding:NSUTF8StringEncoding];
        NSString* bundleID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
        NSString* baseDirPath = [[NSString stringWithFormat:@"~/Library/Application Support/Karakuri/%@/%@/Input Log", bundleID, titleName] stringByExpandingTildeInPath];
        NSString* thePath = [baseDirPath stringByAppendingPathComponent:filenameStr];
        if ([[NSFileManager defaultManager] fileExistsAtPath:thePath]) {
            path = thePath;
        }
    }
#endif
    
#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
    if (!path) {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex:0];
        NSString* baseDirPath = [documentsDirectory stringByAppendingPathComponent:@"Input Log"];
        NSString* thePath = [baseDirPath stringByAppendingPathComponent:filenameStr];
        if ([[NSFileManager defaultManager] fileExistsAtPath:thePath]) {
            path = thePath;
        }
    }
#endif
    
    if (!path) {
        const char* errorFormat = "KRTextReader: Failed to load text named \"%s\". Please check the file existence.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "KRTextReader: テキストファイルの読み込みに失敗しました。ファイルの存在を確認してください。\"%s\".";
        }        
        throw KRRuntimeError(errorFormat, filename.c_str());
    }

	mFileData = nil;
	if (path) {
		mFileData = [[NSData alloc] initWithContentsOfMappedFile:path];
		mLength = [(NSData*)mFileData length];
	}
	mPos = 0;
	[filenameStr release];
}

/*!
    @method ~KRTextReader
    Destructor
 */
KRTextReader::~KRTextReader()
{
    [(NSData*)mFileData release];
}


bool KRTextReader::readLine(std::string* str)
{
    if (!mFileData) {
		return false;
	}
	if (mPos >= mLength) {
		return false;
	}
	std::stringstream ret;
	unsigned char* p = (unsigned char*) [(NSData*)mFileData bytes];
	while (mPos < mLength) {
		if (p[mPos] == '\n') {
			mPos++;
			break;
		}
		ret << p[mPos];
		mPos++;
	}
	*str = ret.str();
	return true;    
}

std::string KRTextReader::to_s() const
{
    return "<text_reader>()";
}

