@import <Foundation/CPObject.j>

@implementation PointOverlayOptionsView : CPView
{
    MKMapView m_MapView;
    PointOverlay m_OverlayTarget @accessors(property=overlay);

    CPCheckBox m_ShowButton;
}

- (id) initWithFrame:(CGRect)aFrame andMapView:(MKMapView)mapView
{
    self = [super initWithFrame:aFrame];
    [self setAutoresizingMask:CPViewHeightSizable | CPViewMinXMargin];

    if(self)
    {
        m_MapView = mapView;

        m_ShowButton = [[CPCheckBox alloc] initWithFrame:CGRectMakeZero()];
        [m_ShowButton setTitle:@"Show Marker"];
        [m_ShowButton sizeToFit];
        [m_ShowButton setFrameOrigin:CGPointMake(CGRectGetMinX(aFrame) + 20, CGRectGetMinY(aFrame) + 40)];
        [m_ShowButton setTarget:self];
        [m_ShowButton setAction:@selector(onShowButton:)];

        [self addSubview:m_ShowButton];
    }

    return self;
}

- (void)setOverlayTarget:(PointOverlay)overlayTarget
{
    m_OverlayTarget = overlayTarget;
    
    if([overlayTarget visible])
    {
        [m_ShowButton setState:CPOnState];
    }
    else
    {
        [m_ShowButton setState:CPOffState];
    }
}

- (void)onShowButton:(id)sender
{
    if([m_ShowButton state] == CPOnState)
    {
        [m_OverlayTarget setVisible:YES];
        [m_OverlayTarget addToMapView:m_MapView];
    }
    //the else is nessecary CPMixedState is possible
    else if([m_ShowButton state] == CPOffState)
    {
        [m_OverlayTarget setVisible:NO];
        [m_OverlayTarget removeFromMapView];
    }
}

@end