#import "SZStatusBarBackgroundView.h"


@implementation SZStatusBarBackgroundView

- (void)drawRect:(NSRect)rect
{
    NSRect frame = [self frame];

    BOOL isWindowMain = [[self window] isMainWindow];
    
    if (isWindowMain) {
        [[NSColor colorWithCalibratedWhite:0.250980392 alpha:1.0] set];
    } else {
        [[NSColor colorWithCalibratedWhite:0.529411765 alpha:1.0] set];
    }
    NSRectFill(NSMakeRect(frame.origin.x, frame.origin.y+frame.size.height-1, frame.size.width, 1));
    
    if (isWindowMain) {
        [[NSColor colorWithCalibratedWhite:0.780392157 alpha:1.0] set];
    } else {
        [[NSColor colorWithCalibratedWhite:0.901960784 alpha:1.0] set];
    }
    NSRectFill(NSMakeRect(frame.origin.x, frame.origin.y+frame.size.height-2, frame.size.width, 1));
    
    if (isWindowMain) {
        [[NSColor colorWithCalibratedWhite:0.596078431 alpha:1.0] set];
    } else {
        [[NSColor colorWithCalibratedWhite:0.82745098 alpha:1.0] set];
    }
    NSRectFill(NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height-2));
}

@end


