@import <Foundation/CPObject.j>

@import "PolygonOverlayOptionsView.j"
@import "PointOverlayOptionsView.j"

@implementation OverlayOptionsView : CPView
{
    PolygonOverlayOptionsView m_PolyOptionsView @accessors(property=polyOptionsView);
    PointOverlayOptionsView m_PointOptionsView @accessors(property=pointOptionsView);

    CPTabView m_TabView;
}

- (void) initWithParentView:(CPView)parentView
{
    [self initWithFrame:CGRectMake(CGRectGetWidth([parentView bounds]) - 250, 0, 250, CGRectGetHeight([parentView bounds]))];

    m_TabView = [[CPTabView alloc] initWithFrame:CGRectMake(CGRectGetMinX([self bounds]), CGRectGetMinY([self bounds]) + 10, 250, CGRectGetHeight([self bounds]) - 10)];
	[m_TabView setTabViewType:CPTopTabsBezelBorder];
	[m_TabView setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];
	    //Map Options
	    var mapOptionsTabItem = [[CPTabViewItem alloc] initWithIdentifier:@"OverlayOptTab"];
	    [mapOptionsTabItem setLabel:"Overlay Options"];
        //depending on the type of overlay selected This will change. TODO
                m_PolyOptionsView = [[PolygonOverlayOptionsView alloc] initWithFrame:[m_TabView bounds]];
        [mapOptionsTabItem setView:m_PolyOptionsView];
    [m_TabView addTabViewItem:mapOptionsTabItem];

    [self addSubview:m_TabView];
}

@end