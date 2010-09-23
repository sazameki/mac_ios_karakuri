/*!
    @file   KRMemoryAllocator.h
    @author numata
    @date   09/09/06
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/KarakuriLibrary.h>


/*!
    @define KR_DECLARE_USE_ALLOCATOR
    @group  Game System
    @abstract <p><strong class="warning">(Deprecated) 現在、このマクロ関数の利用は推奨されません。代わりに KRAnime2DManager クラスのアニメーション管理機構を使用してください。</strong></p>
    <p>アロケータの変数名を指定して、アロケータの使用を宣言するためのマクロ関数です。必ずクラス宣言の先頭に記述してください。</p>
    <p>使い方は、「<a href="../../../guide/memory_allocator.html">多数インスタンスのメモリ管理</a>」を参照してください。</p>
 */
#define KR_DECLARE_USE_ALLOCATOR(allocator)\
    public:\
        void*   operator new(size_t size) { return allocator->allocate(size); }\
        void    operator delete(void *ptr) { allocator->release(ptr); }\
    private:

/*
    @define KR_UPDATE_MAX_CLASS_SIZE
    @group  Game System
    @abstract <p><strong class="warning">(Deprecated) 現在、このマクロ関数の利用は推奨されません。代わりに KRAnime2DManager クラスのアニメーション管理機構を使用してください。</strong></p>
    <p>ある基底クラスから派生したすべてのクラスの最大サイズを求めるマクロ関数です。</p>
    <p>使い方は、「<a href="../../../guide/memory_allocator.html">多数インスタンスのメモリ管理</a>」を参照してください。</p>
    <p>第1引数には、最大サイズを格納するための size_t 型の変数を入れてください。</p>
    <p>第2引数には、派生クラスの名前を入れてください。</p>
 */
#define KR_UPDATE_MAX_CLASS_SIZE(size_var, the_class)  if (sizeof(the_class) > size_var) { size_var = sizeof(the_class); }


struct _KRMemoryElement {
    _KRMemoryElement*  prev;
    _KRMemoryElement*  next;
};


/*
    @class KRMemoryAllocator
    @group  Game System
    @deprecated
    @abstract <p><strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRAnime2DManager クラスのアニメーション管理機構を使用してください。</strong></p>
    <p>同じ種類のクラスのインスタンスを複数個作成するために、あらかじめ必要な領域を確保して、連結リストで管理しておくクラスです。</p>
    <p>このクラスのメソッドなどは直接使用しません。主にマクロを使って利用します。主な使い方は、「<a href="../../../../guide/memory_allocator.html">多数インスタンスのメモリ管理</a>」を参照してください。</p>
 */
class KRMemoryAllocator : public KRObject {
    
    std::string mDebugName;
    
    int         mAllocateCount;
    size_t      mMaxClassSize;
    int         mMaxCount;

    _KRMemoryElement     mDummyElement;
    _KRMemoryElement*    mLastFreeElement;

public:
    /*!
        @task コンストラクタ
     */
    /*!
        @method KRMemoryAllocator
        @abstract <p><strong class="warning">(Deprecated) 現在、このクラスの利用は推奨されません。代わりに KRAnime2DManager クラスのアニメーション管理機構を使用してください。</strong></p>
        メモリサイズ、インスタンスの最大生成個数、デバッグ用のアロケータの名称を指定して、アロケータを生成します。
     */
    KRMemoryAllocator(size_t maxClassSize, int maxCount, const std::string &debugName);

    virtual ~KRMemoryAllocator();
    
public:
    void*   allocate(size_t size);
    void    release(void* ptr);
    
};

