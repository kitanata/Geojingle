@import "PolygonOptionsController.j"

@implementation PolygonOverlayOptionsController : PolygonOptionsController
{
    PolygonOverlay m_OverlayTarget    @accessors(property=overlay);
}

- (id)initWithOverlay:(PolygonOverlay)overlay
{
    self = [super initWithOptions:[overlay displayOptions]];

    if(self)
        m_OverlayTarget = overlay;

    return self;
}

- (void)update
{
    if(m_OverlayTarget)
    {
        [m_OverlayTarget removeFromMapView];
        [m_OverlayTarget createGooglePolygon];
        [m_OverlayTarget addToMapView];
    }
}

+ (id)controllerWithOverlay:(PointOverlay)overlay
{
    return [[PolygonOverlayOptionsController alloc] initWithOverlay:overlay];
}

@end
