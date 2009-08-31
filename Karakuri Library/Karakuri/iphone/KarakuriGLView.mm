//
//  KarakuriGLView.mm
//  Karakuri Prototype
//
//  Created by numata on 09/07/17.
//  Copyright Satoshi Numata 2009. All rights reserved.
//

#import "KarakuriGLView.h"
#import "KarakuriController.h"


#define USE_DEPTH_BUFFER 0


KarakuriGLView   *KRGLViewInst = nil;

static volatile BOOL    sIsReady = NO;
static BOOL sPhoneOrientatilHorizontal = YES;


@interface KarakuriGLView ()

- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;

@end


@implementation KarakuriGLView


// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)init {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 480)];
    if (self) {
        KRGLViewInst = self;

        self.multipleTouchEnabled = YES;

        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];
                
        //KarakuriController *controller = [KarakuriController sharedController];
        //EAGLSharegroup *sharegroup = [controller eaglSharegroup];
        //NSLog(@"%@", sharegroup);

        mKRGLContext.eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        //mKRGLContext.eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1 sharegroup:sharegroup];
        
        if (!mKRGLContext.eaglContext || ![EAGLContext setCurrentContext:mKRGLContext.eaglContext]) {
            [self release];
            return nil;
        }
        
        mNextTouchID = 0;
        
        mIsAccelerometerEnabled = NO;
        for (int i = 0; i < KR_TOUCH_MAX_COUNT; i++) {
            mTouchInfos[i].is_used = false;
        }

        sPhoneOrientatilHorizontal = (KRGame->getScreenWidth() > KRGame->getScreenHeight())? true: false;
        
        [[KarakuriController sharedController] setKRGLContext:&mKRGLContext];
    }
    return self;
}

- (void)dealloc {
    if ([EAGLContext currentContext] == mKRGLContext.eaglContext) {
        [EAGLContext setCurrentContext:nil];
    }

    [mKRGLContext.eaglContext release];  

    delete mDefaultTex;

    [super dealloc];
}

- (void)layoutSubviews {
    [EAGLContext setCurrentContext:mKRGLContext.eaglContext];
    [self destroyFramebuffer];
    [self createFramebuffer];
    
    mDefaultTex = new KRTexture2D("Default.png");

    glBindFramebufferOES(GL_FRAMEBUFFER_OES, mKRGLContext.viewFramebuffer);
    
    glViewport(0, 0, mKRGLContext.backingWidth, mKRGLContext.backingHeight);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    glOrthof(0.0f, mKRGLContext.backingWidth, 0.0f, mKRGLContext.backingHeight, -1.0f, 1.0f);
    
    mDefaultTex->draw(KRRect2D(0, 0, 320, 480));
    KRTexture2D::processBatchedTexture2DDraws();
    [mKRGLContext.eaglContext presentRenderbuffer:GL_RENDERBUFFER_OES];

    mDefaultTex->draw(KRRect2D(0, 0, 320, 480));
    KRTexture2D::processBatchedTexture2DDraws();
    [mKRGLContext.eaglContext presentRenderbuffer:GL_RENDERBUFFER_OES];

    sIsReady = YES;
}

- (void)waitForReady
{
    while (!sIsReady) {
        [NSThread sleepForTimeInterval:0.1];
    }
}

- (BOOL)createFramebuffer {
    glGenFramebuffersOES(1, &mKRGLContext.viewFramebuffer);
    glGenRenderbuffersOES(1, &mKRGLContext.viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, mKRGLContext.viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, mKRGLContext.viewRenderbuffer);
    [mKRGLContext.eaglContext renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, mKRGLContext.viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &mKRGLContext.backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &mKRGLContext.backingHeight);
    
    if (USE_DEPTH_BUFFER) {
        glGenRenderbuffersOES(1, &mKRGLContext.depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, mKRGLContext.depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, mKRGLContext.backingWidth, mKRGLContext.backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, mKRGLContext.depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"KarakuriGLView: Failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}

- (void)destroyFramebuffer
{
    glDeleteFramebuffersOES(1, &mKRGLContext.viewFramebuffer);
    mKRGLContext.viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &mKRGLContext.viewRenderbuffer);
    mKRGLContext.viewRenderbuffer = 0;
    
    if (mKRGLContext.depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &mKRGLContext.depthRenderbuffer);
        mKRGLContext.depthRenderbuffer = 0;
    }
}

- (void)enableAccelerometer
{
    if (mIsAccelerometerEnabled) {
        return;
    }
    
    mIsAccelerometerEnabled = YES;
    
    UIAccelerometer *uiAcc = [UIAccelerometer sharedAccelerometer];
    uiAcc.updateInterval = 0.1;
    uiAcc.delegate = self;
}

- (void)disableAccelerometer
{
    if (!mIsAccelerometerEnabled) {
        return;
    }
    
    mIsAccelerometerEnabled = NO;
    
    UIAccelerometer *uiAcc = [UIAccelerometer sharedAccelerometer];
    uiAcc.delegate = nil;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    if (KRGame->getScreenWidth() > KRGame->getScreenHeight()) {
        KRInputInst->setAcceleration(-acceleration.y, acceleration.x, acceleration.z);
    } else {
        KRInputInst->setAcceleration(acceleration.x, acceleration.y, acceleration.z);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *aTouch in touches) {
        for (int i = 0; i < KR_TOUCH_MAX_COUNT; i++) {
            if (!mTouchInfos[i].is_used) {
                CGPoint pos = [aTouch locationInView:nil];

                mTouchInfos[i].is_used = true;
                mTouchInfos[i].touch_id = mNextTouchID++;
                if (mNextTouchID == 100) {
                    mNextTouchID = 0;
                }
                mTouchInfos[i].pos = pos;
                mTouchInfos[i].touch_pointer = aTouch;

                if (sPhoneOrientatilHorizontal) {
                    KRInputInst->startTouch(mTouchInfos[i].touch_id, pos.y, pos.x);
                } else {
                    KRInputInst->startTouch(mTouchInfos[i].touch_id, pos.x, 480-pos.y);
                }
                break;
            }
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *aTouch in touches) {
        for (int i = 0; i < KR_TOUCH_MAX_COUNT; i++) {
            if (mTouchInfos[i].is_used && mTouchInfos[i].touch_pointer == aTouch) {
                CGPoint pos = [aTouch locationInView:nil];
                CGPoint& oldPos = mTouchInfos[i].pos;
                mTouchInfos[i].pos = pos;
                if (sPhoneOrientatilHorizontal) {
                    KRInputInst->moveTouch(mTouchInfos[i].touch_id, pos.y, pos.x, pos.y-oldPos.y, pos.x-oldPos.x);
                } else {
                    KRInputInst->moveTouch(mTouchInfos[i].touch_id, pos.x, 480-pos.y, pos.x-oldPos.x, oldPos.y-pos.y);
                }
                break;
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *aTouch in touches) {
        for (int i = 0; i < KR_TOUCH_MAX_COUNT; i++) {
            if (mTouchInfos[i].is_used && mTouchInfos[i].touch_pointer == aTouch) {
                CGPoint pos = [aTouch locationInView:nil];
                CGPoint& oldPos = mTouchInfos[i].pos;
                if (sPhoneOrientatilHorizontal) {
                    KRInputInst->endTouch(mTouchInfos[i].touch_id, pos.y, pos.x, pos.y-oldPos.y, pos.x-oldPos.x);
                } else {
                    KRInputInst->endTouch(mTouchInfos[i].touch_id, pos.x, 480-pos.y, oldPos.x-pos.x, oldPos.y-pos.y);
                }

                mTouchInfos[i].is_used = false;
                break;
            }
        }
    }
}

@end

