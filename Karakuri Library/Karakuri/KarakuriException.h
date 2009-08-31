/*
 *  KarakuriException.h
 *  Karakuri Prototype
 *
 *  Created by numata on 07/08/08.
 *  Copyright 2007 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>

#include <stdexcept>


class KRGameExitError : public std::runtime_error {
public:
    KRGameExitError();
    virtual ~KRGameExitError() throw();
};

class KRRuntimeError : public std::runtime_error {
    
protected:
    std::string mMessage;
    
public:
    KRRuntimeError(const std::string &message);
    KRRuntimeError(const char *format, ...);
    virtual ~KRRuntimeError() throw();

public:
    virtual const char *what() const throw();

};

class KRNetworkError : public KRRuntimeError {

public:
    KRNetworkError(const std::string &message);
    KRNetworkError(const char *format, ...);
    virtual ~KRNetworkError() throw();

};

class KRGameError : public KRRuntimeError {
    
public:
    KRGameError(const std::string &message);
    KRGameError(const char *format, ...);
    virtual ~KRGameError() throw();
    
};


