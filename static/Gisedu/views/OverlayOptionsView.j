@import <Foundation/CPObject.j>

@import "MapOptionsView.j"
@import "PolygonOverlayOptionsView.j"
@import "PointOverlayOptionsView.j"

@implementation OverlayOptionsView : CPView
{
    MapOptionsView m_MapOptionsView @accessors(property=mapOptionsView);
    PolygonOverlayOptionsView m_PolyOptionsView @accessors(property=polyOptionsView);
    PointOverlayOptionsView m_PointOptionsView @accessors(property=pointOptionsView);

    CPTabView m_TabView;

    CPTabViewItem m_MapOptionsTabItem;
    CPTabViewItem m_PolyTabItem;
    CPTabViewItem m_PointTabItem;
}

- (id) initWithParentView:(CPView)parentView andMapView:(MKMapView)mapView
{
    self = [self initWithFrame:CGRectMake(CGRectGetWidth([parentView bounds]) - 280, 0, 280, CGRectGetHeight([parentView bounds]))];

    if(self)
    {
        m_TabView = [[CPTabView alloc] initWithFrame:CGRectMake(CGRectGetMinX([self bounds]), CGRectGetMinY([self bounds]) + 10, 280, CGRectGetHeight([self bounds]) - 10)];
        [m_TabView setTabViewType:CPTopTabsBezelBorder];
        [m_TabView setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];

        m_MapOptionsView = [[MapOptionsView alloc] initWithFrame:[m_TabView bounds] andMapView:mapView];
        m_PolyOptionsView = [[PolygonOverlayOptionsView alloc] initWithFrame:[m_TabView bounds] andMapView:mapView];
        m_PointOptionsView = [[PointOverlayOptionsView alloc] initWithFrame:[m_TabView bounds] andMapView:mapView];

        m_MapOptionsTabItem = [[CPTabViewItem alloc] initWithIdentifier:@"MapOptionsTab"];
        [m_MapOptionsTabItem setLabel:"Map Options"];
        [m_MapOptionsTabItem setView:m_MapOptionsView];
        [m_TabView addTabViewItem:m_MapOptionsTabItem];

        m_PolyTabItem = [[CPTabViewItem alloc] initWithIdentifier:@"PolyOverlayOptTab"];
        [m_PolyTabItem setLabel:"Polygon Options"];
        [m_PolyTabItem setView:m_PolyOptionsView];
        [m_TabView addTabViewItem:m_PolyTabItem];

        m_PointTabItem = [[CPTabViewItem alloc] initWithIdentifier:@"PointOverlayOptTab"];
        [m_PointTabItem setLabel:"Point Options"];
        [m_PointTabItem setView:m_PointOptionsView];
        [m_TabView addTabViewItem:m_PointTabItem];

        [self addSubview:m_TabView];
    }

    return self;
}

- (void) setPolygonOverlayTarget: (PolygonOverlay)overlayTarget
{
    [m_PolyOptionsView setOverlayTarget:overlayTarget];

    [m_TabView selectTabViewItem:m_PolyTabItem];
}

- (void) setPointOverlayTarget: (PointOverlay)overlayTarget
{
    [m_PointOptionsView setOverlayTarget:overlayTarget];

    [m_TabView selectTabViewItem:m_PointTabItem];
}

@end