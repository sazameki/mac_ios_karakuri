/*!
    @file   KRMemoryAllocator.h
    @author numata
    @date   09/09/06
    
    Please write the description of this class.
 */

#pragma once

#include <Karakuri/Karakuri.h>


#define KR_UPDATE_MAX_ALLOC_CLASS_SIZE(size_var, the_class)  if (sizeof(the_class) > size_var) { size_var = sizeof(the_class); }

#define KR_DISABLE_DEFAULT_ALLOCATOR()\
    private:\
        void*   operator new(size_t size) throw() { return NULL; }

#define KR_DECLARE_USE_ALLOCATOR(allocator)\
    public:\
        void*   operator new(size_t size) { return allocator->allocate(size); }\
        void    operator delete(void *ptr) { allocator->release(ptr); }


struct KRMemoryElement {
    KRMemoryElement*  prev;
    KRMemoryElement*  next;
};


/*!
    @class KRMemoryAllocator
    @group  Game Foundation
    @abstract 同じ種類のクラスのインスタンスを複数個作成するために、あらかじめ必要な領域を確保して、連結リストで管理しておくクラスです。
 */
class KRMemoryAllocator : public KRObject {
    
    std::string mDebugName;
    
    int         mAllocateCount;
    size_t      mMaxClassSize;
    int         mMaxCount;

    KRMemoryElement     mDummyElement;
    KRMemoryElement*    mLastFreeElement;

public:
    KRMemoryAllocator(size_t maxClassSize, int maxCount, const std::string &debugName);
    virtual ~KRMemoryAllocator();
    
public:
    void*   allocate(size_t size);
    void    release(void *ptr);
    
};

