@import "PointOptionsController.j"

@implementation PointOverlayOptionsController : PointOptionsController
{
    PointOverlay m_OverlayTarget    @accessors(property=overlay);
}

- (id)initWithOverlay:(PointOverlay)overlay
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
        [m_OverlayTarget createGoogleMarker];
        [m_OverlayTarget updateGoogleMarker];
        [m_OverlayTarget addToMapView];
    }
}

+ (id)controllerWithOverlay:(PointOverlay)overlay
{
    return [[PointOverlayOptionsController alloc] initWithOverlay:overlay];
}

@end
