/*!
    @file   KarakuriDebug.mm
    @author Satoshi Numata
    @date   10/01/10
 */

#include "KarakuriDebug.h"
#import "KRGameController.h"
#include <sys/time.h>


void KRDebug(const char *format, ...)
{
#if __DEBUG__
    
    static char buffer[1024];
    va_list marker;
    va_start(marker, format);
    vsprintf(buffer, format, marker);
    va_end(marker);
    
    timeval tp;
    gettimeofday(&tp, NULL);
    
    time_t theTime = time(NULL);
    tm *date = localtime(&theTime);
    
    static char dateBuffer[16];
    strftime(dateBuffer, 15, "%H:%M:%S", date);
    
    printf("[%s.%02d] %s\n", dateBuffer, tp.tv_usec / 10000, buffer);

#endif  // #ifdef __DEBUG__
}

void KRDebugScreen(const char *format, ...)
{
#if __DEBUG__
    
    static char buffer[1024];
    va_list marker;
    va_start(marker, format);
    vsprintf(buffer, format, marker);
    va_end(marker);
    
    [[KRGameController sharedController] addDebugString:buffer];

#endif  // #ifdef __DEBUG__
}

void KRClearDebugScreen()
{
#if __DEBUG__

    [[KRGameController sharedController] removeDebugStrings];
    
#endif  // #ifdef __DEBUG__
}

