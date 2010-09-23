/*!
    @file   «FILENAME»
    @author «FULLUSERNAME»
    @date   «DATE»
 */

#include "«FILEBASENAME».h"
#include "Globals.h"


«FILEBASENAME»::«FILEBASENAME»()
    : KRChara2D(ClassType::YOUR_CHARACTER_CLASS_TYPE, CharaID::YOUR_CHARACTER_ID)
{
	// TODO: Initialize this class
    mState = 0;

    // Make this character visible (initial state = -1)
    changeMotion(0);
}

«FILEBASENAME»::~«FILEBASENAME»()
{
    // TODO: Clean up this class
}

