@import <Foundation/CPObject.j>

@import "FilterManager.j"

@implementation PolygonFilterOptionsController : CPObject
{
    GiseduFilter m_FilterTarget     @accessors(property=filter);
    FilterManager m_FilterManager;
}

- (id)initWithFilter:(GiseduFilter)filter
{
    self = [super init];

    if(self)
    {
        m_FilterTarget = filter;
        m_FilterManager = [FilterManager getInstance];
    }

    return self;
}

- (BOOL)visible
{
    return [m_FilterTarget getDisplayOption:"visible"];
}

- (id)displayOptions
{
    return [m_FilterTarget displayOptions];
}

- (void)updateFilterChains
{
    var filterChains = [m_FilterManager filterChainsWithFilter:m_FilterTarget];

    for(var i=0; i < [filterChains count]; i++)
    {
        var curChain = [filterChains objectAtIndex:i];

        [curChain updateOverlays];
    }
}

- (void)onLineColorChanged:(CPString)lineColor
{
    [m_FilterTarget setDisplayOption:"strokeColor" value:lineColor];

    [self updateFilterChains];
}

- (void)onFillColorChanged:(CPString)fillColor
{
    [m_FilterTarget setDisplayOption:"fillColor" value:fillColor];

    [self updateFilterChains];
}

- (void)onLineStrokeChanged:(id)lineStroke
{
    [m_FilterTarget setDisplayOption:"strokeWeight" value:lineStroke];

    [self updateFilterChains];
}

- (void)onLineOpacityChanged:(id)lineOpacity
{
    [m_FilterTarget setDisplayOption:"strokeOpacity" value:lineOpacity];

    [self updateFilterChains];
}

- (void)onFillOpacityChanged:(id)fillOpacity
{
    [m_FilterTarget setDisplayOption:"fillOpacity" value:fillOpacity];

    [self updateFilterChains];
}

- (void)onVisibilityChanged:(BOOL)visible
{
    if(visible)
        [m_FilterTarget setDisplayOption:"visible" value:YES];
    else
        [m_FilterTarget setDisplayOption:"visible" value:NO];

    [self updateFilterChains];
}

+ (id)controllerWithFilter:(GiseduFilter)filter
{
    return [[PolygonFilterOptionsController alloc] initWithFilter:filter];
}

@end