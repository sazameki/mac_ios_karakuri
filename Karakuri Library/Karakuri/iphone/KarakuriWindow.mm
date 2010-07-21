//
//  KarakuriWindow.mm
//  Karakuri Prototype
//
//  Created by numata on 09/07/17.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import "KarakuriWindow.h"
#import "KRGameController.h"


KarakuriWindow* gKRWindowInst = nil;


@implementation KarakuriWindow

- (id)init
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self = [super initWithFrame:bounds];
    if (self) {
        gKRWindowInst = self;

        KRGameController* controller = [KRGameController sharedController];
        KRGameManager* game = [controller game];
        int width = game->getScreenWidth();
        int height = game->getScreenHeight();


        if (width < 500 && bounds.size.width > 500) {
            UIImage* image = [UIImage imageNamed:@"ipad_iphonesize_back.png"];
            if (!image) {
                NSString* imageFilePath = @"/Developer/Extras/Karakuri/images/System/iPhone Emulator/ipad_iphonesize_back.png";
                image = [[[UIImage alloc] initWithContentsOfFile:imageFilePath] autorelease];
            }
            UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
            imageView.backgroundColor = [UIColor blackColor];
            [self addSubview:imageView];
            [imageView release];
            [image release];
        }
        
        
        self.backgroundColor = [UIColor blackColor];
        
        mGLView = [[KarakuriGLView alloc] initWithScreenSize:CGSizeMake(width, height)];
        
        CGRect viewFrame = mGLView.frame;
        viewFrame.origin.x = (bounds.size.width - viewFrame.size.width) / 2;
        viewFrame.origin.y = (bounds.size.height - viewFrame.size.height) / 2;
        mGLView.frame = viewFrame;
        
        [self addSubview:mGLView];
    }
    return self;
}

- (void)dealloc
{
    [mGLView release];
    
    [super dealloc];
}

- (KarakuriGLView*)glView
{
    return mGLView;
}

- (void)changeToSubScreenWindow
{
    mProxyView = [[KRProxyView alloc] initWithFrame:[mGLView frame]];
    [mProxyView setGLView:mGLView];
    
    [mGLView setAttachedToSecondScreen];
    [mGLView removeFromSuperview];
    mGLView = nil;
    
    [self addSubview:mProxyView];
}

@end


