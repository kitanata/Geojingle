@import <Foundation/CPObject.j>

@import "MapKit/MKLocation.j"
@import "MapKit/MKMarker.j"

@import "loaders/InfoWindowOverlayLoader.j"

@import "PointDisplayOptions.j"

var DEG_TO_METERS = 111120;
var METERS_TO_DEG = 0.000008999;

@implementation MapOverlay : CPControl
{
    BOOL m_bDirty                    @accessors(property=dirty);
    id m_Delegate                   @accessors(property=delegate);
}

- (id)init
{
    self = [super init];

    if(self)
    {
        m_bDirty = YES;

        m_DisplayOptions = [PointDisplayOptions defaultOptions];
    }

    return self;
}

- (void)setDirty
{
    m_bDirty = YES;
}

- (void)update
{
    if(m_bDirty)
        [self _update];

    m_bDirty = NO;
}

- (void)update:(BOOL)dirty
{
    m_bDirty = YES;

    [self update];
}

/* Override this in deriving classes */
- (void)_update
{
}

@end
