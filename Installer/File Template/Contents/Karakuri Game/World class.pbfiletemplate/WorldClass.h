/*!
    @file   «FILENAME»
    @author «FULLUSERNAME»
    @date   «DATE»
    
    Please write the description of this world.
 */

#pragma once

#include <Karakuri/Karakuri.h>


class «FILEBASENAMEASIDENTIFIER» : public KRWorld {
    
public:

    virtual void    becameActive();
    virtual void    resignedActive();
    virtual void    updateModel(KRInput *input);
    virtual void    drawView(KRGraphics *g);

};

