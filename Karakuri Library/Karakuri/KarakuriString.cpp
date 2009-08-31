/*
 *  KarakuriString.cpp
 *  Karakuri Prototype
 *
 *  Created by numata on 07/08/26.
 *  Copyright 2007 Satoshi Numata. All rights reserved.
 *
 */

#include "KarakuriString.h"


std::string KRFS(const char *format, ...)
{
    static char buffer[1024];
    va_list marker;
    va_start(marker,format);
    vsprintf(buffer, format, marker);
    va_end(marker);
    return buffer;
}

std::string KRStringMake(const char *format, ...)
{
    static char buffer[1024];
    va_list marker;
    va_start(marker,format);
    vsprintf(buffer, format, marker);
    va_end(marker);
    return buffer;
}

std::vector<std::string> KRSplitString(const std::string& str, const std::string& separators)
{
	std::vector<std::string> vec;
	unsigned pos = 0;
	unsigned length = (unsigned) str.length();
	while (pos < length) {
		// 最初に区切り文字が現れる間スキップする
		while (pos < length) {
			if (separators.find(str[pos]) == std::string::npos) {
				break;
			}
			pos++;
		}
		if (pos >= length) {
			break;
		}
		unsigned start = pos;
		pos++;
		// 次の区切り文字が来るまでスキップ
		while (pos < length) {
			if (separators.find(str[pos]) != std::string::npos) {
				break;
			}
			pos++;
		}
		// 追加
		vec.push_back(str.substr(start, pos-start));
	}
	return vec;
}


