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


std::string KRFS(const char *format, ...);
std::string KRStringMake(const char *format, ...);

std::vector<std::string> KRSplitString(const std::string& str, const std::string& separators);

