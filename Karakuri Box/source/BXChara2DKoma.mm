//
//  BXChara2DKoma.mm
//  Karakuri Box
//
//  Created by numata on 10/03/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BXChara2DKoma.h"
#import "NSDictionary+LoadSave.h"
#import "BXChara2DSpec.h"
#import "BXChara2DMotion.h"
#import "BXTexture2DSpec.h"
#import "BXDocument.h"
#import "NSImage+BXEx.h"


@implementation BXChara2DKomaHitInfo

- (id)initWithType:(int)type group:(int)groupIndex rect:(NSRect)rect
{
    self = [super init];
    if (self) {
        mHitType = type;
        mGroupIndex = groupIndex;
        mRect = rect;
    }
    return self;
}

- (id)initWithInfo:(NSDictionary*)infoDict
{
    self = [super init];
    if (self) {
        mHitType = [infoDict intValueForName:@"Hit Type" currentValue:BXChara2DKomaHitTypeRect];
        mGroupIndex = [infoDict intValueForName:@"Group Index" currentValue:1];
        mRect.origin.x = [infoDict doubleValueForName:@"Rect X" currentValue:0.0];
        mRect.origin.y = [infoDict doubleValueForName:@"Rect Y" currentValue:0.0];
        mRect.size.width = [infoDict doubleValueForName:@"Rect Width" currentValue:2.0];
        mRect.size.height = [infoDict doubleValueForName:@"Rect Height" currentValue:2.0];
    }
    return self;
}

- (id)copyWithZone:(NSZone*)zone
{
    return [[BXChara2DKomaHitInfo alloc] initWithInfo:[self infoDict]];
}

- (BXDocument*)document
{
    return [mParentKoma document];
}

- (BXChara2DKoma*)parentKoma
{
    return mParentKoma;
}

- (void)setParentKoma:(BXChara2DKoma*)aKoma
{
    mParentKoma = aKoma;
}

- (BOOL)contains:(NSPoint)pos
{
    return NSPointInRect(pos, mRect);
}

- (BOOL)isPointInTopMiddleHandle:(NSPoint)pos
{
    NSRect theRect = NSMakeRect(mTopMiddlePoint.x-2, mTopMiddlePoint.y-2, 4, 4);
    return NSPointInRect(pos, theRect);
}

- (BOOL)isPointInBottomMiddleHandle:(NSPoint)pos
{
    NSRect theRect = NSMakeRect(mBottomMiddlePoint.x-2, mBottomMiddlePoint.y-2, 4, 4);
    return NSPointInRect(pos, theRect);
}

- (BOOL)isPointInLeftMiddleHandle:(NSPoint)pos
{
    NSRect theRect = NSMakeRect(mLeftMiddlePoint.x-2, mLeftMiddlePoint.y-2, 4, 4);
    return NSPointInRect(pos, theRect);
}

- (BOOL)isPointInRightMiddleHandle:(NSPoint)pos
{
    NSRect theRect = NSMakeRect(mRightMiddlePoint.x-2, mRightMiddlePoint.y-2, 4, 4);
    return NSPointInRect(pos, theRect);
}

- (void)resizeFromTopWithPoint:(NSPoint)pos
{
    NSRect theRect = mRect;
    theRect.size.height = pos.y - theRect.origin.y;
    if (theRect.size.height < 1) {
        theRect.size.height = 1;
    }
    [self setRect:theRect];
}

- (void)resizeFromBottomWithPoint:(NSPoint)pos
{
    NSRect theRect = mRect;
    
    float orgBottomEdge = theRect.origin.y + theRect.size.height;
    theRect.origin.y = pos.y;
    if (theRect.origin.y >= orgBottomEdge-1) {
        theRect.origin.y = orgBottomEdge - 1;
    }
    theRect.size.height = orgBottomEdge - theRect.origin.y;
    
    [self setRect:theRect];    
}

- (void)resizeFromLeftWithPoint:(NSPoint)pos
{    
    NSRect theRect = mRect;

    float orgRightEdge = theRect.origin.x + theRect.size.width;
    theRect.origin.x = pos.x;
    if (theRect.origin.x >= orgRightEdge-1) {
        theRect.origin.x = orgRightEdge - 1;
    }
    theRect.size.width = orgRightEdge - theRect.origin.x;

    [self setRect:theRect];
}

- (void)resizeFromRightWithPoint:(NSPoint)pos
{
    NSRect theRect = mRect;
    theRect.size.width = pos.x - theRect.origin.x;
    if (theRect.size.width < 1) {
        theRect.size.width = 1;
    }
    [self setRect:theRect];
}

- (NSRect)rect
{
    return mRect;
}

- (void)setRect:(NSRect)rect
{
    if (!NSEqualRects(mRect, rect)) {
        mRect = rect;
        [[self document] updateChangeCount:NSChangeUndone];
    }
}

- (void)drawInRect:(NSRect)targetRect scale:(double)scale isMain:(BOOL)isMain
{
    NSColor* borderColor = [NSColor colorWithCalibratedWhite:0.4 alpha:1.0];
    NSColor* fillColor = [NSColor colorWithCalibratedWhite:0.4 alpha:0.5];
    if (isMain) {
        if (mGroupIndex == 1) {
            borderColor = [NSColor colorWithCalibratedRed:1.0 green:0.5 blue:0.0 alpha:1.0];
            fillColor = [NSColor colorWithCalibratedRed:1.0 green:0.5 blue:0.0 alpha:0.5];
        } else if (mGroupIndex == 2) {
            borderColor = [NSColor colorWithCalibratedRed:0.0 green:0.5 blue:0.0 alpha:1.0];
            fillColor = [NSColor colorWithCalibratedRed:0.0 green:0.5 blue:0.0 alpha:0.5];
        } else if (mGroupIndex == 3) {
            borderColor = [NSColor colorWithCalibratedRed:0.0 green:0.5 blue:1.0 alpha:1.0];
            fillColor = [NSColor colorWithCalibratedRed:0.0 green:0.5 blue:1.0 alpha:0.5];
        } else if (mGroupIndex == 4) {
            borderColor = [NSColor colorWithCalibratedRed:1.0 green:0.3 blue:1.0 alpha:1.0];
            fillColor = [NSColor colorWithCalibratedRed:1.0 green:0.3 blue:1.0 alpha:0.5];
        } else if (mGroupIndex == 5) {
            borderColor = [NSColor colorWithCalibratedRed:1.0 green:0.2 blue:0.2 alpha:1.0];
            fillColor = [NSColor colorWithCalibratedRed:1.0 green:0.2 blue:0.2 alpha:0.5];
        } else if (mGroupIndex == 6) {
            borderColor = [NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.0 alpha:1.0];
            fillColor = [NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.0 alpha:0.5];
        } else if (mGroupIndex == 7) {
            borderColor = [NSColor colorWithCalibratedRed:0.0 green:0.7 blue:0.5 alpha:1.0];
            fillColor = [NSColor colorWithCalibratedRed:0.0 green:0.7 blue:0.5 alpha:0.5];
        } else if (mGroupIndex == 8) {
            borderColor = [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:1.0];
            fillColor = [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:0.5];
        } else if (mGroupIndex == 9) {
            borderColor = [NSColor colorWithCalibratedRed:0.75 green:0.0 blue:0.0 alpha:1.0];
            fillColor = [NSColor colorWithCalibratedRed:0.75 green:0.0 blue:0.0 alpha:0.5];
        } else if (mGroupIndex == 10) {
            borderColor = [NSColor colorWithCalibratedRed:0.4 green:0.0 blue:0.4 alpha:1.0];
            fillColor = [NSColor colorWithCalibratedRed:0.4 green:0.0 blue:0.4 alpha:0.5];
        } else if (mGroupIndex == 11) {
            borderColor = [NSColor colorWithCalibratedRed:0.6 green:0.3 blue:0.0 alpha:1.0];
            fillColor = [NSColor colorWithCalibratedRed:0.6 green:0.3 blue:0.0 alpha:0.5];
        } else if (mGroupIndex == 12) {
            borderColor = [NSColor colorWithCalibratedRed:0.0 green:0.8 blue:0.0 alpha:1.0];
            fillColor = [NSColor colorWithCalibratedRed:0.0 green:0.8 blue:0.0 alpha:0.5];
        }
    }
    
    NSRect theRect = NSMakeRect(targetRect.origin.x + ((int)(mRect.origin.x+0.5)) * scale,
                                targetRect.origin.y + targetRect.size.height - ((int)(mRect.origin.y+0.5)) * scale - ((int)(mRect.size.height+0.5)) * scale,
                                ((int)(mRect.size.width+0.5)) * scale,
                                ((int)(mRect.size.height+0.5)) * scale);
    NSBezierPath* thePath = nil;
    if (mHitType == BXChara2DKomaHitTypeRect) {
        thePath = [NSBezierPath bezierPathWithRect:theRect];
    } else if (mHitType == BXChara2DKomaHitTypeOval) {
        thePath = [NSBezierPath bezierPathWithOvalInRect:theRect];
    }
    
    [fillColor set];
    [thePath fill];
    
    [[NSColor whiteColor] set];
    [thePath setLineWidth:3.0];
    [thePath stroke];
    
    [borderColor set];
    [thePath setLineWidth:2.0];
    [thePath stroke];
}

- (void)drawHandleAtPoint:(NSPoint)pos
{
    NSRect theRect = NSMakeRect(pos.x-1, pos.y-1, 2, 2);
    
    [[NSColor whiteColor] set];
    [NSBezierPath setDefaultLineWidth:2.0];
    [NSBezierPath strokeRect:theRect];
    
    [[NSColor colorWithCalibratedRed:0.0 green:0.6 blue:1.0 alpha:0.7] set];
    [NSBezierPath fillRect:theRect];
}

- (void)drawResizeHandlesInRect:(NSRect)targetRect scale:(double)scale
{
    NSRect theRect = NSMakeRect(targetRect.origin.x + ((int)(mRect.origin.x+0.5)) * scale,
                                targetRect.origin.y + targetRect.size.height - ((int)(mRect.origin.y+0.5)) * scale - ((int)(mRect.size.height+0.5)) * scale,
                                ((int)(mRect.size.width+0.5)) * scale,
                                ((int)(mRect.size.height+0.5)) * scale);

    mTopMiddlePoint = NSMakePoint(theRect.origin.x+theRect.size.width/2, theRect.origin.y);
    mBottomMiddlePoint = NSMakePoint(theRect.origin.x+theRect.size.width/2, theRect.origin.y+theRect.size.height);
    mLeftMiddlePoint = NSMakePoint(theRect.origin.x, theRect.origin.y+theRect.size.height/2);
    mRightMiddlePoint = NSMakePoint(theRect.origin.x+theRect.size.width, theRect.origin.y+theRect.size.height/2);

    [self drawHandleAtPoint:mTopMiddlePoint];
    [self drawHandleAtPoint:mBottomMiddlePoint];
    [self drawHandleAtPoint:mLeftMiddlePoint];
    [self drawHandleAtPoint:mRightMiddlePoint];
    
    NSMutableDictionary* strAttr = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSFont systemFontOfSize:10.0], NSFontAttributeName,
                                    [NSColor whiteColor], NSForegroundColorAttributeName,
                                    nil];
    
    NSString* infoStr = [NSString stringWithFormat:@"(%d,%d)-[%d,%d]", (int)(mRect.origin.x+0.5), (int)(mRect.origin.y+0.5),
                         (int)(mRect.size.width+0.5), (int)(mRect.size.height+0.5)];
                                    
    [infoStr drawAtPoint:NSMakePoint(mTopMiddlePoint.x-1, mTopMiddlePoint.y-10-1) withAttributes:strAttr];
    [infoStr drawAtPoint:NSMakePoint(mTopMiddlePoint.x+1, mTopMiddlePoint.y-10-1) withAttributes:strAttr];
    [infoStr drawAtPoint:NSMakePoint(mTopMiddlePoint.x-1, mTopMiddlePoint.y-10+1) withAttributes:strAttr];
    [infoStr drawAtPoint:NSMakePoint(mTopMiddlePoint.x+1, mTopMiddlePoint.y-10+1) withAttributes:strAttr];

    [strAttr setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
    [infoStr drawAtPoint:NSMakePoint(mTopMiddlePoint.x, mTopMiddlePoint.y-10) withAttributes:strAttr];
}

- (int)groupIndex
{
    return mGroupIndex;
}

- (NSDictionary*)infoDict
{
    NSMutableDictionary* theInfo = [NSMutableDictionary dictionary];
    
    [theInfo setIntValue:mHitType forName:@"Hit Type"];
    [theInfo setIntValue:mGroupIndex forName:@"Group Index"];
    [theInfo setDoubleValue:mRect.origin.x forName:@"Rect X"];
    [theInfo setDoubleValue:mRect.origin.y forName:@"Rect Y"];
    [theInfo setDoubleValue:mRect.size.width forName:@"Rect Width"];
    [theInfo setDoubleValue:mRect.size.height forName:@"Rect Height"];
    
    return theInfo;
}

@end


@implementation BXChara2DKoma

- (id)init
{
    self = [super init];
    if (self) {
        mKomaIndex = -1;
        mIsCancelable = YES;
        mInterval = 0;
        mGotoTargetKoma = nil;        

        mHitInfos = [[NSMutableArray alloc] init];
        mShowsHitInfos = YES;
        mCurrentHitGroupIndex = 1;
        
        mPreviewTex = NULL;
    }
    return self;
}

- (id)initWithInfo:(NSDictionary*)info chara2DSpec:(BXChara2DSpec*)chara2DSpec
{
    self = [super init];
    if (self) {
        mTexture2DResourceUUID = [[info stringValueForName:@"Texture UUID" currentValue:nil] copy];
        int atlasX = [info intValueForName:@"Atlas X" currentValue:0];
        int atlasY = [info intValueForName:@"Atlas Y" currentValue:0];
        int atlasWidth = [info intValueForName:@"Atlas Width" currentValue:0];
        int atlasHeight = [info intValueForName:@"Atlas Height" currentValue:0];
        mTextureAtlasRect = NSMakeRect(atlasX, atlasY, atlasWidth, atlasHeight);

        mKomaIndex = [info intValueForName:@"Koma Index" currentValue:-1];
        mIsCancelable = [info boolValueForName:@"Cancelable" currentValue:YES];
        mInterval = [info intValueForName:@"Interval" currentValue:0];
        
        mTempGotoTargetKomaIndex = [info intValueForName:@"Goto Target Index" currentValue:-1];

        mGotoTargetKoma = nil;

        mHitInfos = [[NSMutableArray alloc] init];
        mShowsHitInfos = [info intValueForName:@"Shows Hit Infos" currentValue:YES];
        mCurrentHitGroupIndex = [info intValueForName:@"Current Hit Group Index" currentValue:1];
        
        NSArray* hitInfoDicts = [info objectForKey:@"Hit Infos"];
        if (hitInfoDicts) {
            for (int i = 0; i < [hitInfoDicts count]; i++) {
                NSDictionary* infoDict = [hitInfoDicts objectAtIndex:i];
                BXChara2DKomaHitInfo* theInfo = [[[BXChara2DKomaHitInfo alloc] initWithInfo:infoDict] autorelease];
                [self addHitInfo:theInfo];
            }
        }
    }
    return self;
}

- (void)dealloc
{
    [mHitInfos release];
    [mTexture2DResourceUUID release];

    [super dealloc];
}

- (BXDocument*)document
{
    return [mParentMotion document];
}

- (BXChara2DMotion*)parentMotion
{
    return mParentMotion;
}

- (void)setParentMotion:(BXChara2DMotion*)aMotion
{
    mParentMotion = aMotion;
}

- (void)drawHitInfosInRect:(NSRect)targetRect scale:(double)scale
{
    // メイン以外の当たり判定範囲をすべて描画する
    for (int i = 0; i < [mHitInfos count]; i++) {
        BXChara2DKomaHitInfo* anInfo = [mHitInfos objectAtIndex:i];
        if ([anInfo groupIndex] != mCurrentHitGroupIndex) {
            [anInfo drawInRect:targetRect scale:scale isMain:NO];
        }
    }

    // メインの当たり判定範囲をすべて描画する
    for (int i = 0; i < [mHitInfos count]; i++) {
        BXChara2DKomaHitInfo* anInfo = [mHitInfos objectAtIndex:i];
        if ([anInfo groupIndex] == mCurrentHitGroupIndex) {
            [anInfo drawInRect:targetRect scale:scale isMain:YES];
        }
    }
}

- (int)hitInfoCount
{
    return [mHitInfos count];
}

- (BXChara2DKomaHitInfo*)hitInfoAtIndex:(int)index
{
    return [mHitInfos objectAtIndex:index];
}

- (BOOL)showsHitInfos
{
    return mShowsHitInfos;
}

- (void)setShowsHitInfos:(BOOL)flag
{
    mShowsHitInfos = flag;
}

- (int)currentHitGroupIndex
{
    return mCurrentHitGroupIndex;
}

- (void)setCurrentHitGroupIndex:(int)index
{
    mCurrentHitGroupIndex = index;
}

- (void)addHitInfo:(BXChara2DKomaHitInfo*)aHitInfo
{
    [aHitInfo setParentKoma:self];
    [mHitInfos addObject:aHitInfo];
}

- (void)removeAllHitInfos
{
    [mHitInfos removeAllObjects];
}

- (void)removeSelectedHitInfo
{
}

- (BXChara2DKomaHitInfo*)addHitInfoOval
{
    NSImage* nsImage = [self nsImage];
    NSSize size = [nsImage size];
    
    NSRect theRect = NSMakeRect(0, 0, 10, 10);
    if (size.width < theRect.size.width) {
        theRect.size.width = size.width;
    }
    if (size.height < theRect.size.height) {
        theRect.size.height = size.height;
    }
    
    BXChara2DKomaHitInfo* theInfo = [[[BXChara2DKomaHitInfo alloc] initWithType:BXChara2DKomaHitTypeOval
                                                                          group:mCurrentHitGroupIndex
                                                                           rect:theRect] autorelease];
    
    [self addHitInfo:theInfo];
    
    return theInfo;
}

- (BXChara2DKomaHitInfo*)addHitInfoRect
{
    NSImage* nsImage = [self nsImage];
    NSSize size = [nsImage size];
    
    NSRect theRect = NSMakeRect(0, 0, 10, 10);
    if (size.width < theRect.size.width) {
        theRect.size.width = size.width;
    }
    if (size.height < theRect.size.height) {
        theRect.size.height = size.height;
    }
    
    BXChara2DKomaHitInfo* theInfo = [[[BXChara2DKomaHitInfo alloc] initWithType:BXChara2DKomaHitTypeRect
                                                                          group:mCurrentHitGroupIndex
                                                                           rect:theRect] autorelease];
    [self addHitInfo:theInfo];

    return theInfo;
}

- (void)importHitInfosFromKoma:(BXChara2DKoma*)aKoma
{
    int hitInfoCount = [aKoma hitInfoCount];
    
    for (int i = 0; i < hitInfoCount; i++) {
        BXChara2DKomaHitInfo* anInfo = [aKoma hitInfoAtIndex:i];
        BXChara2DKomaHitInfo* theCopy = [[anInfo copy] autorelease];
        [self addHitInfo:theCopy];
    }
}

- (void)replaceHitInfosFromKoma:(BXChara2DKoma*)aKoma
{
    [self removeAllHitInfos];
    [self importHitInfosFromKoma:aKoma];
}

- (BXChara2DKomaHitInfo*)hitInfoAtPoint:(NSPoint)pos
{
    for (int i = 0; i < [mHitInfos count]; i++) {
        BXChara2DKomaHitInfo* anInfo = [mHitInfos objectAtIndex:i];
        if ([anInfo groupIndex] == mCurrentHitGroupIndex && [anInfo contains:pos]) {
            return anInfo;
        }
    }
    return nil;
}

- (void)removeHitInfo:(BXChara2DKomaHitInfo*)aHitInfo
{
    [mHitInfos removeObject:aHitInfo];
}

- (void)setTexture:(BXTexture2DSpec*)texture atlasRect:(NSRect)rect
{
    [mTexture2DResourceUUID release];
    mTexture2DResourceUUID = nil;
    
    if (texture) {
        mTexture2DResourceUUID = [[texture resourceUUID] copy];
        mTextureAtlasRect = rect;
    }
}

- (int)komaIndex
{
    return mKomaIndex;
}

- (void)setKomaIndex:(int)index
{
    mKomaIndex = index;
}

- (BOOL)isCancelable
{
    return mIsCancelable;
}

- (void)setCancelable:(BOOL)flag
{
    mIsCancelable = flag;
}

- (int)interval
{
    return mInterval;
}

- (void)setInterval:(int)interval
{
    mInterval = interval;
}

- (NSImage*)nsImage
{
    if (!mTexture2DResourceUUID) {
        return nil;
    }
    BXTexture2DSpec* texture = [[self document] tex2DWithUUID:mTexture2DResourceUUID];
    if (!texture) {
        return nil;
    }
    NSImage* image = [texture image72dpi];
    if (!image) {
        return nil;
    }
    return [image subImageFromRect:mTextureAtlasRect];
}

- (int)gotoTargetKomaIndex
{
    if (!mGotoTargetKoma) {
        return -1;
    }
    return [mGotoTargetKoma komaIndex];
}

- (BXChara2DKoma*)gotoTargetKoma
{
    return mGotoTargetKoma;
}

- (void)setGotoTargetKoma:(BXChara2DKoma*)koma
{
    mGotoTargetKoma = koma;
}

- (void)replaceTempGotoInfoForMotion:(BXChara2DMotion*)motion
{
    if (mTempGotoTargetKomaIndex >= 0) {
        BXChara2DKoma* targetKoma = [motion komaAtIndex:mTempGotoTargetKomaIndex];
        mGotoTargetKoma = targetKoma;
    }
    
    mTempGotoTargetKomaIndex = -1;
}

- (void)preparePreviewTexture
{
    if (mTexture2DResourceUUID) {
        BXTexture2DSpec* texture = [[self document] tex2DWithUUID:mTexture2DResourceUUID];
        mPreviewTex = new KRTexture2D(texture, mTextureAtlasRect);
    }
}

- (KRTexture2D*)previewTexture
{
    return mPreviewTex;
}

- (NSDictionary*)komaInfo
{
    NSMutableDictionary* theInfo = [NSMutableDictionary dictionary];
    
    if (mTexture2DResourceUUID) {
        [theInfo setStringValue:mTexture2DResourceUUID forName:@"Texture UUID"];
        BXTexture2DSpec* texture = [[self document] tex2DWithUUID:mTexture2DResourceUUID];
        if (texture) {
            [theInfo setIntValue:[texture resourceID] forName:@"Texture ID"];
        } else {
            [theInfo removeObjectForKey:@"Texture ID"];
        }
    } else {
        [theInfo removeObjectForKey:@"Texture UUID"];
        [theInfo removeObjectForKey:@"Texture ID"];
    }
    [theInfo setIntValue:(int)mTextureAtlasRect.origin.x forName:@"Atlas X"];
    [theInfo setIntValue:(int)mTextureAtlasRect.origin.y forName:@"Atlas Y"];
    [theInfo setIntValue:(int)mTextureAtlasRect.size.width forName:@"Atlas Width"];
    [theInfo setIntValue:(int)mTextureAtlasRect.size.height forName:@"Atlas Height"];
    
    [theInfo setIntValue:mKomaIndex forName:@"Koma Index"];
    [theInfo setBoolValue:mIsCancelable forName:@"Cancelable"];
    [theInfo setIntValue:mInterval forName:@"Interval"];
    [theInfo setIntValue:[self gotoTargetKomaIndex] forName:@"Goto Target Index"];
    [theInfo setBoolValue:mShowsHitInfos forName:@"Shows Hit Infos"];
    [theInfo setIntValue:mCurrentHitGroupIndex forName:@"Current Hit Group Index"];
    
    NSMutableArray* hitInfoDicts = [NSMutableArray array];
    for (int i = 0; i < [mHitInfos count]; i++) {
        BXChara2DKomaHitInfo* anInfo = [mHitInfos objectAtIndex:i];
        [hitInfoDicts addObject:[anInfo infoDict]];
    }
    [theInfo setObject:hitInfoDicts forKey:@"Hit Infos"];

    return theInfo;
}

@end

