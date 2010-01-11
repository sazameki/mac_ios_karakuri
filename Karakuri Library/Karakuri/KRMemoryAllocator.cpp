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
            throw KRGameError("Failed to allocate enough memory (size=%d) <%s>.", allocateSize, mDebugName.c_str());
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
        throw KRGameError("Memory allocation size error (request=%dbytes, limit=%dbytes) <%s>.", (int)size, (int)mMaxClassSize, mDebugName.c_str());
    }
    if (mAllocateCount >= mMaxCount) {
        throw KRGameError("You tried to allocate memory fragments over max count %d <%s>.", mMaxCount, mDebugName.c_str());
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


