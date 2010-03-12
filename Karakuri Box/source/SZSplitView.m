#import "SZSplitView.h"


@implementation SZSplitView

//-------------------------------------------------------------------------
#pragma mark -- ビューの設定 --
//-------------------------------------------------------------------------

- (BOOL)acceptsFirstResponder   { return YES; }


//-------------------------------------------------------------------------
#pragma mark -- 初期化・クリーンアップ --
//-------------------------------------------------------------------------

- (void)awakeFromNib
{
    if ([self isVertical]) {
        mDividerBackImage = [[NSImage imageNamed:@"divider_back"] retain];
        mDividerDipImage = [[NSImage imageNamed:@"divider_dip"] retain];
    } else {
        mDividerBackImage = [[NSImage imageNamed:@"divider_back_horizontal"] retain];
        mDividerDipImage = [[NSImage imageNamed:@"divider_dip_horizontal"] retain];
    }
    [mDividerBackImage setFlipped:YES];
    [mDividerDipImage setFlipped:YES];
}

- (void)dealloc
{
    [mDividerBackImage release];
    [mDividerDipImage release];
    [super dealloc];
}

- (float)dividerThickness
{
    if ([self isVertical]) {
        return 7.0f;
    }
    return 7.0f;
}

- (void)drawDividerInRect:(NSRect)rect
{
    [[NSColor redColor] set];
    NSRectFill(rect);
    NSSize backImageSize = [mDividerBackImage size];
    NSSize dipImageSize = [mDividerDipImage size];
    if ([self isVertical]) {
        [mDividerBackImage drawInRect:rect fromRect:NSMakeRect(0, 0, backImageSize.width, backImageSize.height) operation:NSCompositeSourceOver fraction:1.0f];
        [mDividerDipImage drawAtPoint:NSMakePoint(rect.origin.x, (int)(rect.origin.y+rect.size.height/2-dipImageSize.height/2+0.5))
                             fromRect:NSMakeRect(0, 0, dipImageSize.width, dipImageSize.height)
                            operation:NSCompositeSourceOver
                             fraction:1.0f];
    } else {
        [mDividerBackImage drawInRect:rect fromRect:NSMakeRect(0, 0, backImageSize.width, backImageSize.height) operation:NSCompositeSourceOver fraction:1.0f];
        [mDividerDipImage drawAtPoint:NSMakePoint(rect.origin.x+(int)(rect.size.width/2-dipImageSize.width/2+0.5), rect.origin.y)
                             fromRect:NSMakeRect(0, 0, dipImageSize.width, dipImageSize.height)
                            operation:NSCompositeSourceOver
                             fraction:1.0f];
    }
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize
{
    if (![self isVertical]) {
        [super resizeSubviewsWithOldSize:oldBoundsSize];
        return;
    }

    NSRect newFrame = [self frame];
    
    NSView *firstView = [[self subviews] objectAtIndex:0];
    NSView *secondView = [[self subviews] objectAtIndex:1];
    
    NSRect firstFrame = [firstView frame];
    NSRect secondFrame = [secondView frame];
    float dividerThickness = [self dividerThickness];
    
    if ([self isVertical]) {
        firstFrame.size.height = newFrame.size.height;
        
        secondFrame.origin.x = firstFrame.origin.x + firstFrame.size.width + dividerThickness;
        secondFrame.size.width = newFrame.size.width - firstFrame.size.width - dividerThickness;
        secondFrame.size.height = newFrame.size.height;
    } else {
        firstFrame.size.width = newFrame.size.width;
        
        secondFrame.origin.y = firstFrame.origin.y + firstFrame.size.height + dividerThickness;
        secondFrame.size.width = newFrame.size.width;
        secondFrame.size.height = newFrame.size.height - firstFrame.size.height - dividerThickness;
    }
    
    [firstView setFrame:firstFrame];
    [secondView setFrame:secondFrame];
    
    [self setNeedsDisplay:YES];
}

@end


