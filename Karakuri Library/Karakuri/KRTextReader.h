/*!
    @file   KRTextReader.h
    @author numata
    @date   09/07/29
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/Karakuri.h>


class KRTextReader : KRObject {

    void		*mFileData;	//!< Objective-C でファイルデータを表すオブジェクトへのポインタ
	unsigned	mLength;	//!< ファイルサイズ
	unsigned	mPos;		//!< ファイル上の現在の位置
    
public:
	KRTextReader(const std::string& filename);
	virtual ~KRTextReader();
  
public:
	bool    readLine(std::string *str);

public:
    virtual std::string to_s() const;

};

