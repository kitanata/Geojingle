@import <Foundation/CPObject.j>
@import <AppKit/CPView.j>
@import <MapKit/MKMapView.j>

@implementation PolygonOverlayOptionsView : CPView
{
    MKMapView m_MapView;
    CPArray m_OverlayPolygons;

    CPColorWell m_LineColorWell;
    CPColorWell m_FillColorWell;
    CPSlider m_LineStrokeSlider;
    CPSlider m_LineOpacitySlider;
    CPSlider m_FillOpacitySlider;
    CPCheckBox m_ShowButton;
}

- (id) initWithFrame:(CGRect)aFrame andMapView:(MKMapView)mapView
{
    console.log("initializing PolygonOverlayOptionsView");
    
    self = [super initWithFrame:aFrame];

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

- (void)setOverlayTarget:(id)overlayTarget
{
    if([overlayTarget typeName] == "MultiPolygonOverlay")
    {
        m_OverlayPolygons = [overlayTarget polygons];
    }
    else if([overlayTarget typeName] == "PolygonOverlay")
    {
        
    }

    if([m_OverlayPolygons count] > 0)
    {
        sample = [m_OverlayPolygons objectAtIndex:0];

        [m_LineColorWell setColor:[CPColor colorWithHexString:[[sample lineColorCode] substringFromIndex:1]]];
        [m_FillColorWell setColor:[CPColor colorWithHexString:[[sample fillColorCode] substringFromIndex:1]]];

        [m_LineStrokeSlider setValue:[sample lineStroke]];
        [m_LineOpacitySlider setValue:([sample lineOpacity] * 100)];
        [m_FillOpacitySlider setValue:([sample fillOpacity] * 100)];

        if([sample visible])
        {
            [m_ShowButton setState:CPOnState];
        }
        else
        {
            [m_ShowButton setState:CPOffState];
        }
    }
}

- (void)onLineColorWell:(id)sender
{
    for(var i=0; i < [m_OverlayPolygons count]; i++)
    {
        polygon = [m_OverlayPolygons objectAtIndex:i];

        [polygon removeFromMapView:m_MapView];
        [polygon setLineColorCode:"#" + [[m_LineColorWell color] hexString]];

        if([polygon visible])
        {
            [polygon addToMapView:m_MapView];
        }
    }
}

- (void)onFillColorWell:(id)sender
{
    for(var i=0; i < [m_OverlayPolygons count]; i++)
    {
        polygon = [m_OverlayPolygons objectAtIndex:i];

        [polygon removeFromMapView:m_MapView];
        [polygon setFillColorCode:"#" + [[m_FillColorWell color] hexString]];

        if([polygon visible])
        {
            [polygon addToMapView:m_MapView];
        }
    }
}

- (void)onStrokeSlider:(id)sender
{
    for(var i=0; i < [m_OverlayPolygons count]; i++)
    {
        polygon = [m_OverlayPolygons objectAtIndex:i];

        [polygon removeFromMapView:m_MapView];
        [polygon setLineStroke:[m_LineStrokeSlider doubleValue]];

        if([polygon visible])
        {
            [polygon addToMapView:m_MapView];
        }
    }
}

- (void)onLineOpacitySlider:(id)sender
{
    for(var i=0; i < [m_OverlayPolygons count]; i++)
    {
        polygon = [m_OverlayPolygons objectAtIndex:i];

        [polygon removeFromMapView:m_MapView];
        [polygon setLineOpacity:([m_LineOpacitySlider doubleValue] / 100)];

        if([polygon visible])
        {
            [polygon addToMapView:m_MapView];
        }
    }
}

- (void)onFillOpacitySlider:(id)sender
{
    for(var i=0; i < [m_OverlayPolygons count]; i++)
    {
        polygon = [m_OverlayPolygons objectAtIndex:i];

        [polygon removeFromMapView:m_MapView];
        [polygon setFillOpacity:([m_FillOpacitySlider doubleValue] / 100)];

        if([polygon visible])
        {
            [polygon addToMapView:m_MapView];
        }
    }
}

- (void)onShowButton:(id)sender
{
    for(var i=0; i < [m_OverlayPolygons count]; i++)
    {
        polygon = [m_OverlayPolygons objectAtIndex:i];

        if([m_ShowButton state] == CPOnState)
        {
            [polygon setVisible:YES];
            [polygon addToMapView:m_MapView];
        }
        //the else is nessecary CPMixedState is possible
        else if([m_ShowButton state] == CPOffState)
        {
            [polygon setVisible:NO];
            [polygon removeFromMapView:m_MapView];
        }
    }
}

@end