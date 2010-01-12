/*!
    @file   KRMemoryAllocator.cpp
    @author numata
    @date   09/09/06
 */

#include "KRMemoryAllocator.h"


/*!
    @method KRMemoryAllocator
    Constructor
 */
KRMemoryAllocator::KRMemoryAllocator(size_t maxClassSize, int maxCount, const std::string& debugName)
    : mMaxClassSize(maxClassSize), mMaxCount(maxCount), mDebugName(debugName)
{
    size_t allocateSize = (maxClassSize + 1) * maxCount;
    
    mDummyElement.prev = NULL;
    mDummyElement.next = NULL;
    
    KRMemoryElement *lastElem = &mDummyElement;

    for (int i = 0; i < maxCount; i++) {
        KRMemoryElement *newElem = (KRMemoryElement *)malloc(maxClassSize + sizeof(KRMemoryElement));
        if (newElem == NULL) {
            const char *errorFormat = "KRMemoryAllocator: Failed to allocate enough memory (size=%d) <%s>.";
            if (gKRLanguage == KRLanguageJapanese) {
                errorFormat = "KRMemoryAllocator: 十分なメモリを確保できませんでした。 (size=%d) <%s>.";
            }
            throw KRRuntimeError(errorFormat, allocateSize, mDebugName.c_str());
        }
        lastElem->next = newElem;
        newElem->prev = lastElem;
        newElem->next = NULL;
        lastElem = newElem;
    }

    mLastFreeElement = lastElem;

    mAllocateCount = 0;
}

/*!
    @method ~KRMemoryAllocator
    Destructor
 */
KRMemoryAllocator::~KRMemoryAllocator()
{
    KRMemoryElement *theElem = mDummyElement.next;
    
    while (theElem != NULL) {
        KRMemoryElement *nextElem = theElem->next;
        free(theElem);
        theElem = nextElem;
    }
}

void* KRMemoryAllocator::allocate(size_t size)
{
    if (size > mMaxClassSize) {
        const char *errorFormat = "KRMemoryAllocator: Memory allocation size error (request=%dbytes, limit=%dbytes) <%s>.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "KRMemoryAllocator: new で要求されたメモリサイズが、登録されたクラスの最大メモリサイズを超えました。 (request=%dbytes, limit=%dbytes) <%s>.";
        }
        throw KRRuntimeError(errorFormat, (int)size, (int)mMaxClassSize, mDebugName.c_str());
    }
    if (mAllocateCount >= mMaxCount) {
        const char *errorFormat = "KRMemoryAllocator: Tried to instantiate over max count %d <%s>.";
        if (gKRLanguage == KRLanguageJapanese) {
            errorFormat = "KRMemoryAllocator: 設定された最大数 %d を超えてインスタンスを作成しようとしました。 <%s>.";
        }
        throw KRRuntimeError(errorFormat, mMaxCount, mDebugName.c_str());
    }
    
    KRMemoryElement *theElem = mLastFreeElement;
    mLastFreeElement = theElem->prev;
    mLastFreeElement->next = NULL;
    
    mDummyElement.next->prev = theElem;
    theElem->next = mDummyElement.next;
    theElem->prev = &mDummyElement;
    mDummyElement.next = theElem;
    
    mAllocateCount++;
    
    return (void *)((char *)theElem + sizeof(KRMemoryElement));
}

void KRMemoryAllocator::release(void *ptr)
{
    KRMemoryElement *theElem = (KRMemoryElement *)((char *)ptr - sizeof(KRMemoryElement));
    
    if (theElem != mLastFreeElement) {
        theElem->prev->next = theElem->next;
        if (theElem->next != NULL) {
            theElem->next->prev = theElem->prev;
        }
        theElem->next = NULL;
        
        mLastFreeElement->next = theElem;
        theElem->prev = mLastFreeElement;
        mLastFreeElement = theElem;
    }
    
    mAllocateCount--;
}


