@import <Foundation/CPObject.j>

@implementation PointOverlayOptionsController : CPObject
{
    PointOverlay m_OverlayTarget    @accessors(property=overlay);
}

- (id)initWithOverlay:(PointOverlay)overlay
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

- (CPString)icon
{
    return [m_OverlayTarget displayOptions].icon;
}

- (CPString)iconColor
{
    return [m_OverlayTarget displayOptions].iconColor;
}

- (void)updateTarget
{
    if(m_OverlayTarget)
    {
        [m_OverlayTarget removeFromMapView];
        [m_OverlayTarget createGoogleMarker];
        [m_OverlayTarget updateGoogleMarker];
        [m_OverlayTarget addToMapView];
    }
}

- (void)onIconTypeChanged:(CPString)newType
{
    if(newType != "education")
        [m_OverlayTarget setDisplayOption:"icon" value:newType];

    [self updateTarget];
}

- (void)onIconSubTypeChanged:(CPString)newType
{
    [m_OverlayTarget setDisplayOption:"icon" value:newType];
    
    [self updateTarget];
}

- (void)onIconColorChanged:(CPString)iconColor
{
    [m_OverlayTarget setDisplayOption:"iconColor" value:iconColor];

    [self updateTarget];
}

- (void)onLineColorChanged:(CPString)lineColor
{
    [m_OverlayTarget setDisplayOption:"strokeColor" value:lineColor];
    
    [m_OverlayTarget updateGoogleMarker];
}

- (void)onFillColorChanged:(CPString)fillColor
{
    [m_OverlayTarget setDisplayOption:"fillColor" value:fillColor];

    [m_OverlayTarget updateGoogleMarker];
}

- (void)onLineStrokeChanged:(id)lineStroke
{
    [m_OverlayTarget setDisplayOption:"strokeWeight" value:lineStroke];
    
    [m_OverlayTarget updateGoogleMarker];
}

- (void)onLineOpacityChanged:(id)lineOpacity
{
    [m_OverlayTarget setDisplayOption:"strokeOpacity" value:lineOpacity];

    [m_OverlayTarget updateGoogleMarker];
}

- (void)onFillOpacityChanged:(id)fillOpacity
{
    [m_OverlayTarget setDisplayOption:"fillOpacity" value:fillOpacity];

    [m_OverlayTarget updateGoogleMarker];
}

- (void)onShapeRadiusChanged:(id)shapeRadius
{
    [m_OverlayTarget setDisplayOption:"radius" value:shapeRadius];
    
    [m_OverlayTarget updateGoogleMarker];
}

- (void)onVisibilityChanged:(BOOL)visible
{
    [m_OverlayTarget setDisplayOption:"visible" value:visible];

    [m_OverlayTarget updateGoogleMarker];
}

+ (id)controllerWithOverlay:(PointOverlay)overlay
{
    return [[PointOverlayOptionsController alloc] initWithOverlay:overlay];
}

@end