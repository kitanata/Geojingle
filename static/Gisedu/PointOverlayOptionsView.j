@import <Foundation/CPObject.j>

@implementation PointOverlayOptionsView : CPView
{
    MKMapView m_MapView;
    PointOverlay m_OverlayTarget @accessors(property=overlay);
}

- (id) initWithFrame:(CGRect)aFrame andMapView:(MKMapView)mapView
{
    self = [super initWithFrame:aFrame];

    if(self)
    {
        m_MapView = mapView;

        lineColorLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()]
        [lineColorLabel setStringValue:@"Polygon Line Color"];
        [lineColorLabel setFont:[CPFont systemFontOfSize:12.0]];
        [lineColorLabel sizeToFit];
        [lineColorLabel setFrameOrigin:CGPointMake(CGRectGetMinX(aFrame) + 50, CGRectGetMinY(aFrame) + 50)];

        m_LineColorWell = [[CPColorWell alloc] initWithFrame:CGRectMake(CGRectGetMinX(aFrame) + 30, CGRectGetMinY(aFrame) + 50, 20, 20)];
        [m_LineColorWell setBordered:YES];

        [self addSubview:lineColorLabel];
        [self addSubview:m_LineColorWell];
    }

    return self;
}

@end