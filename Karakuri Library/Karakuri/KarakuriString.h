/*
 *  KarakuriString.h
 *  Karakuri Prototype
 *
 *  Created by numata on 07/08/26.
 *  Copyright 2007 Satoshi Numata. All rights reserved.
 *
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>

#include <string>
#include <vector>


/*!
    @function   KRFS
    @group      Game Foundation
    @abstract   C++版の sprintf() です。
    指定された書式に従って C++ 文字列を生成します。
 */
std::string KRFS(const char *format, ...);

/*!
    @function   KRSplitString
    @group      Game Foundation
    @abstract   文字列を分割します。
    指定された区切り文字を使って文字列を分割し、分割された文字列を格納した vector をリターンします。
 */
std::vector<std::string> KRSplitString(const std::string& str, const std::string& separators);

