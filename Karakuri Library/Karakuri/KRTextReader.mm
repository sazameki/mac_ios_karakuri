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
	NSData *strData = [[NSData alloc] initWithBytes:filename.data() length:filename.length()];
	NSString *str = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
	NSString *path = [[NSBundle mainBundle] pathForResource:str ofType:nil];
    if (!path) {
        throw KRRuntimeError("KRTextReader() failed to load text named \"%s\".", filename.c_str());
    }
	mFileData = nil;
	if (path) {
		mFileData = [[NSData alloc] initWithContentsOfMappedFile:path];
		mLength = [(NSData *)mFileData length];
	}
	mPos = 0;
	[str release];
	[strData release];
}

/*!
    @method ~KRTextReader
    Destructor
 */
KRTextReader::~KRTextReader()
{
    [(NSData *)mFileData release];
}


bool KRTextReader::readLine(std::string *str)
{
    if (!mFileData) {
		return false;
	}
	if (mPos >= mLength) {
		return false;
	}
	std::stringstream ret;
	unsigned char *p = (unsigned char *) [(NSData *)mFileData bytes];
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

