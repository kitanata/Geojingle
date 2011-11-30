@import <Foundation/CPObject.j>

@implementation PolygonOverlayOptionsController : CPObject
{
    PolygonOverlay m_OverlayTarget    @accessors(property=overlay);
}

- (id)initWithOverlay:(PolygonOverlay)overlay
{
    self = [super init];

    if(self)
        m_OverlayTarget = overlay;

    return self;
}

- (BOOL)visible
{
    return [m_OverlayTarget displayOptions].visible;
}

- (id)displayOptions
{
    return [m_OverlayTarget displayOptions];
}

- (void)updateTarget
{
    if(m_OverlayTarget)
    {
        [m_OverlayTarget removeFromMapView];
        [m_OverlayTarget createGooglePolygon];
        [m_OverlayTarget addToMapView];
    }
}

- (void)onLineColorChanged:(CPString)lineColor
{
    [m_OverlayTarget setDisplayOption:"strokeColor" value:lineColor];

    [m_OverlayTarget updateGooglePolygon];
}

- (void)onFillColorChanged:(CPString)fillColor
{
    [m_OverlayTarget setDisplayOption:"fillColor" value:fillColor];

    [m_OverlayTarget updateGooglePolygon];
}

- (void)onLineStrokeChanged:(id)lineStroke
{
    [m_OverlayTarget setDisplayOption:"strokeWeight" value:lineStroke];

    [m_OverlayTarget updateGooglePolygon];
}

- (void)onLineOpacityChanged:(id)lineOpacity
{
    [m_OverlayTarget setDisplayOption:"strokeOpacity" value:lineOpacity];

    [m_OverlayTarget updateGooglePolygon];
}

- (void)onFillOpacityChanged:(id)fillOpacity
{
    [m_OverlayTarget setDisplayOption:"fillOpacity" value:fillOpacity];

    [m_OverlayTarget updateGooglePolygon];
}

- (void)onVisibilityChanged:(BOOL)visible
{
    [m_OverlayTarget setDisplayOption:"visible" value:visible];

    [m_OverlayTarget updateGooglePolygon];
}

+ (id)controllerWithOverlay:(PointOverlay)overlay
{
    return [[PolygonOverlayOptionsController alloc] initWithOverlay:overlay];
}

@end