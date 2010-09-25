/*
 *  KarakuriException.cpp
 *  Karakuri Prototype
 *
 *  Created by numata on 07/08/08.
 *  Copyright 2007 Satoshi Numata. All rights reserved.
 *
 */

#include "KarakuriException.h"


#pragma mark Runtime error for exiting game

KRGameExitError::KRGameExitError()
    : std::runtime_error("")
{
    // Nothing to do
}

KRGameExitError::~KRGameExitError() throw()
{
    // Nothing to do
}


#pragma mark -
#pragma mark Runtime error caused from framework side

KRRuntimeError::KRRuntimeError(const std::string& message)
    : std::runtime_error("")
{
    mMessage = message;
}

KRRuntimeError::KRRuntimeError(const char* format, ...)
    : std::runtime_error("")
{
    char buffer[1024];
    va_list marker;
    va_start(marker, format);
    vsprintf(buffer, format, marker);
    va_end(marker);
    
    mMessage = buffer;
}

KRRuntimeError::~KRRuntimeError() throw()
{
    // Nothing to do
}

const char* KRRuntimeError::what() const throw()
{
    return mMessage.c_str();
}


#pragma mark -
#pragma mark Network error

KRNetworkError::KRNetworkError(const std::string& message)
    : KRRuntimeError(message)
{
    // Nothing to do
}

KRNetworkError::KRNetworkError(const char* format, ...)
    : KRRuntimeError("")
{
    char buffer[1024];
    va_list marker;
    va_start(marker,format);
    vsprintf(buffer, format, marker);
    va_end(marker);
    
    mMessage = buffer;    
}

KRNetworkError::~KRNetworkError() throw()
{
    // Nothing to do
}



#pragma mark -
#pragma mark Runtime error caused from user (game programmer) side

KRGameError::KRGameError(const std::string& message)
    : KRRuntimeError(message)
{
    // Nothing to do
}

KRGameError::KRGameError(const char* format, ...)
    : KRRuntimeError("")
{
    char buffer[1024];
    va_list marker;
    va_start(marker,format);
    vsprintf(buffer, format, marker);
    va_end(marker);
    
    mMessage = buffer;    
}

KRGameError::~KRGameError() throw()
{
    // Nothing to do
}


