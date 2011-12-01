@import <Foundation/CPObject.j>

@implementation PolygonOptionsController : CPObject
{
    PolygonDisplayOptions m_DisplayOptions  @accessors(property=displayOptions);
}

- (id)initWithOptions:(PolygonDisplayOptions)options
{
    self = [super init];

    if(self)
    {
        m_DisplayOptions = options;
    }

    return self;
}

- (BOOL)visible
{
    return [m_DisplayOptions getDisplayOption:"visible"];
}

- (void)update {}

- (void)onLineColorChanged:(CPString)lineColor
{
    [m_DisplayOptions setDisplayOption:"strokeColor" value:lineColor];

    [self update];
}

- (void)onFillColorChanged:(CPString)fillColor
{
    [m_DisplayOptions setDisplayOption:"fillColor" value:fillColor];

    [self update];
}

- (void)onLineStrokeChanged:(id)lineStroke
{
    [m_DisplayOptions setDisplayOption:"strokeWeight" value:lineStroke];

    [self update];
}

- (void)onLineOpacityChanged:(id)lineOpacity
{
    [m_DisplayOptions setDisplayOption:"strokeOpacity" value:lineOpacity];

    [self update];
}

- (void)onFillOpacityChanged:(id)fillOpacity
{
    [m_DisplayOptions setDisplayOption:"fillOpacity" value:fillOpacity];

    [self update];
}

- (void)onVisibilityChanged:(BOOL)visible
{
    if(visible)
        [m_DisplayOptions setDisplayOption:"visible" value:YES];
    else
        [m_DisplayOptions setDisplayOption:"visible" value:NO];

    [self update];
}

@end
