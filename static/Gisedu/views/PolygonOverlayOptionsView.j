@import <Foundation/CPObject.j>
@import <AppKit/CPView.j>
@import "../../MapKit/MKMapView.j"

@implementation PolygonOverlayOptionsView : CPView
{
    MKMapView m_MapView;
    PolygonOverlay m_OverlayPolygon;

    CPColorWell m_LineColorWell;
    CPColorWell m_FillColorWell;
    CPSlider m_LineStrokeSlider;
    CPSlider m_LineOpacitySlider;
    CPSlider m_FillOpacitySlider;
    CPCheckBox m_ShowButton;
}

- (id) initWithFrame:(CGRect)aFrame andMapView:(MKMapView)mapView
{
    self = [super initWithFrame:aFrame];
    [self setAutoresizingMask:CPViewHeightSizable | CPViewMinXMargin];

    if(self)
    {
        m_MapView = mapView;
        
        lineColorLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()]
        [lineColorLabel setStringValue:@"Polygon Line Color"];
        [lineColorLabel setFont:[CPFont systemFontOfSize:12.0]];
        [lineColorLabel sizeToFit];
        [lineColorLabel setFrameOrigin:CGPointMake(CGRectGetMinX(aFrame) + 40, CGRectGetMinY(aFrame) + 40)];

        m_LineColorWell = [[CPColorWell alloc] initWithFrame:CGRectMake(CGRectGetMinX(aFrame) + 20, CGRectGetMinY(aFrame) + 40, 20, 20)];
        [m_LineColorWell setBordered:YES];
        [m_LineColorWell setTarget:self];
        [m_LineColorWell setAction:@selector(onLineColorWell:)];

        [self addSubview:lineColorLabel];
        [self addSubview:m_LineColorWell];

        fillColorLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()]
        [fillColorLabel setStringValue:@"Polygon Fill Color"];
        [fillColorLabel setFont:[CPFont systemFontOfSize:12.0]];
        [fillColorLabel sizeToFit];
        [fillColorLabel setFrameOrigin:CGPointMake(CGRectGetMinX(aFrame) + 40, CGRectGetMinY(aFrame) + 80)];

        m_FillColorWell = [[CPColorWell alloc] initWithFrame:CGRectMake(CGRectGetMinX(aFrame) + 20, CGRectGetMinY(aFrame) + 80, 20, 20)];
        [m_FillColorWell setBordered:YES];
        [m_FillColorWell setTarget:self];
        [m_FillColorWell setAction:@selector(onFillColorWell:)];

        [self addSubview:fillColorLabel];
        [self addSubview:m_FillColorWell];

        lineStrokeLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()]
        [lineStrokeLabel setStringValue:@"Polygon Line Stroke Size"];
        [lineStrokeLabel setFont:[CPFont systemFontOfSize:12.0]];
        [lineStrokeLabel sizeToFit];
        [lineStrokeLabel setFrameOrigin:CGPointMake(CGRectGetMinX(aFrame) + 20, CGRectGetMinY(aFrame) + 120)];

        m_LineStrokeSlider = [[CPSlider alloc] initWithFrame:CGRectMake(CGRectGetMinX(aFrame) + 20, CGRectGetMinY(aFrame) + 140, 210, 20)];
        [m_LineStrokeSlider setMinValue:0];
        [m_LineStrokeSlider setMaxValue:25];
        [m_LineStrokeSlider setTarget:self];
        [m_LineStrokeSlider setAction:@selector(onStrokeSlider:)];

        [self addSubview:lineStrokeLabel];
        [self addSubview:m_LineStrokeSlider];

        lineOpacityLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()]
        [lineOpacityLabel setStringValue:@"Polygon Line Opactiy"];
        [lineOpacityLabel setFont:[CPFont systemFontOfSize:12.0]];
        [lineOpacityLabel sizeToFit];
        [lineOpacityLabel setFrameOrigin:CGPointMake(CGRectGetMinX(aFrame) + 20, CGRectGetMinY(aFrame) + 170)];

        m_LineOpacitySlider = [[CPSlider alloc] initWithFrame:CGRectMake(CGRectGetMinX(aFrame) + 20, CGRectGetMinY(aFrame) + 190, 210, 20)];
        [m_LineOpacitySlider setMinValue:0];
        [m_LineOpacitySlider setMaxValue:100];
        [m_LineOpacitySlider setTarget:self];
        [m_LineOpacitySlider setAction:@selector(onLineOpacitySlider:)];

        [self addSubview:lineOpacityLabel];
        [self addSubview:m_LineOpacitySlider];

        fillOpacityLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()]
        [fillOpacityLabel setStringValue:@"Polygon Fill Opactiy"];
        [fillOpacityLabel setFont:[CPFont systemFontOfSize:12.0]];
        [fillOpacityLabel sizeToFit];
        [fillOpacityLabel setFrameOrigin:CGPointMake(CGRectGetMinX(aFrame) + 20, CGRectGetMinY(aFrame) + 220)];

        m_FillOpacitySlider = [[CPSlider alloc] initWithFrame:CGRectMake(CGRectGetMinX(aFrame) + 20, CGRectGetMinY(aFrame) + 240, 210, 20)];
        [m_FillOpacitySlider setMinValue:0];
        [m_FillOpacitySlider setMaxValue:100];
        [m_FillOpacitySlider setTarget:self];
        [m_FillOpacitySlider setAction:@selector(onFillOpacitySlider:)];

        [self addSubview:fillOpacityLabel];
        [self addSubview:m_FillOpacitySlider];

        m_ShowButton = [[CPCheckBox alloc] initWithFrame:CGRectMakeZero()];
        [m_ShowButton setTitle:@"Show Polygon"];
        [m_ShowButton sizeToFit];
        [m_ShowButton setFrameOrigin:CGPointMake(CGRectGetMinX(aFrame) + 20, CGRectGetMinY(aFrame) + 280)];
        [m_ShowButton setTarget:self];
        [m_ShowButton setAction:@selector(onShowButton:)];

        [self addSubview:m_ShowButton];
    }

    return self;
}

- (void)setOverlayTarget:(PolygonOverlay)overlayTarget
{
    [m_OverlayPolygon setActive:NO];

    m_OverlayPolygon = overlayTarget;

    [m_LineColorWell setColor:[CPColor colorWithHexString:[[m_OverlayPolygon lineColorCode] substringFromIndex:1]]];
    [m_FillColorWell setColor:[CPColor colorWithHexString:[[m_OverlayPolygon fillColorCode] substringFromIndex:1]]];

    [m_LineStrokeSlider setValue:[m_OverlayPolygon lineStroke]];
    [m_LineOpacitySlider setValue:([m_OverlayPolygon lineOpacity] * 100)];
    [m_FillOpacitySlider setValue:([m_OverlayPolygon fillOpacity] * 100)];

    if([m_OverlayPolygon visible])
    {
        [m_ShowButton setState:CPOnState];
    }
    else
    {
        [m_ShowButton setState:CPOffState];
    }

    [m_OverlayPolygon setActive:YES];
}

- (void)onLineColorWell:(id)sender
{
    [m_OverlayPolygon removeFromMapView];
    [m_OverlayPolygon setLineColorCode:"#" + [[m_LineColorWell color] hexString]];

    if([m_OverlayPolygon visible])
    {
        [m_OverlayPolygon addToMapView:m_MapView];
    }
}

- (void)onFillColorWell:(id)sender
{
    [m_OverlayPolygon removeFromMapView];
    [m_OverlayPolygon setFillColorCode:"#" + [[m_FillColorWell color] hexString]];

    if([m_OverlayPolygon visible])
    {
        [m_OverlayPolygon addToMapView:m_MapView];
    }
}

- (void)onStrokeSlider:(id)sender
{
    [m_OverlayPolygon removeFromMapView];
    [m_OverlayPolygon setLineStroke:[m_LineStrokeSlider doubleValue]];

    if([m_OverlayPolygon visible])
    {
        [m_OverlayPolygon addToMapView:m_MapView];
    }
}

- (void)onLineOpacitySlider:(id)sender
{
    [m_OverlayPolygon removeFromMapView];
    [m_OverlayPolygon setLineOpacity:([m_LineOpacitySlider doubleValue] / 100)];

    if([m_OverlayPolygon visible])
    {
        [m_OverlayPolygon addToMapView:m_MapView];
    }
}

- (void)onFillOpacitySlider:(id)sender
{
    [m_OverlayPolygon removeFromMapView];
    [m_OverlayPolygon setFillOpacity:([m_FillOpacitySlider doubleValue] / 100)];

    if([m_OverlayPolygon visible])
    {
        [m_OverlayPolygon addToMapView:m_MapView];
    }
}

- (void)onShowButton:(id)sender
{
    if([m_ShowButton state] == CPOnState)
    {
        [m_OverlayPolygon setVisible:YES];
        [m_OverlayPolygon addToMapView:m_MapView];
    }
    //the else is nessecary CPMixedState is possible
    else if([m_ShowButton state] == CPOffState)
    {
        [m_OverlayPolygon setVisible:NO];
        [m_OverlayPolygon removeFromMapView];
    }
}

@end