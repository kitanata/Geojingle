@import <Foundation/CPObject.j>

@import "PolygonOverlayOptionsView.j"
@import "PointOverlayOptionsView.j"

@implementation OverlayOptionsView : CPView
{
    PolygonOverlayOptionsView m_PolyOptionsView @accessors(property=polyOptionsView);
    PointOverlayOptionsView m_PointOptionsView @accessors(property=pointOptionsView);

    CPTabView m_TabView;
    CPTabItem m_TabItem;
}

- (id) initWithParentView:(CPView)parentView andMapView:(MKMapView)mapView
{
    [self initWithFrame:CGRectMake(CGRectGetWidth([parentView bounds]) - 250, 0, 250, CGRectGetHeight([parentView bounds]))];

    m_TabView = [[CPTabView alloc] initWithFrame:CGRectMake(CGRectGetMinX([self bounds]), CGRectGetMinY([self bounds]) + 10, 250, CGRectGetHeight([self bounds]) - 10)];
	[m_TabView setTabViewType:CPTopTabsBezelBorder];
	[m_TabView setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];
	    //Map Options
	    m_TabItem = [[CPTabViewItem alloc] initWithIdentifier:@"OverlayOptTab"];
	    [m_TabItem setLabel:"Overlay Options"];
        //depending on the type of overlay selected This will change. TODO
                m_PolyOptionsView = [[PolygonOverlayOptionsView alloc] initWithFrame:[m_TabView bounds] andMapView:mapView];
                //m_PointOptionsView = [[PointOverlayOptionsView alloc] initWithFrame:[m_TabView bounds] andMapView:mapView]; TODO
        [m_TabItem setView:m_PolyOptionsView];
    [m_TabView addTabViewItem:m_TabItem];

    [self addSubview:m_TabView];

    return self;
}

- (void) setPolygonOverlayTarget: (PolygonOverlay)overlayTarget
{
    console.log("Before or After?");
    [m_PolyOptionsView setOverlayTarget:overlayTarget];
    [m_TabItem setView:m_PolyOptionsView];
}

- (void) setPointOverlayTarget: (PointOverlay)overlayTarget
{
    [m_PointOptionsView setOverlayTarget:overlayTarget];
    [m_TabItem setView:m_PointOptionsView];
}

@end