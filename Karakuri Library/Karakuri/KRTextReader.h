/*!
    @file   KRTextReader.h
    @author numata
    @date   09/07/29
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/Karakuri.h>


/*!
    @class  KRTextReader
    @group  Game Text Processing
    <p>UTF-8形式のテキストファイルを、1行ずつ読み込むためのクラスです。</p>
    <p>改行コードには LF のみを用いてください。</p>
 */
class KRTextReader : public KRObject {

    void		*mFileData;	//!< Objective-C でファイルデータを表すオブジェクトへのポインタ
	unsigned	mLength;	//!< ファイルサイズ
	unsigned	mPos;		//!< ファイル上の現在の位置
    
public:
    /*!
        @task コンストラクタ
     */
    
    /*!
        @method KRTextReader
        指定されたファイル名のテキストファイルを読み込み用に開きます。
     */
	KRTextReader(const std::string& filename);
	virtual ~KRTextReader();
  
public:
    /*!
        @task 基本の関数
     */
    
    /*!
        @method readLine
        ファイルから文字列を1行分読み込み、与えられた string クラスのポインタに値を代入します。
     */
	bool    readLine(std::string *str);

public:
    virtual std::string to_s() const;

};

