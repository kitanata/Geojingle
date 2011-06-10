@import <Foundation/CPObject.j>
@import "OverlayOutlineView.j"
@import "OverlayFiltersView.j"

@implementation LeftSideTabView : CPView
{
    CPTabView m_TabView;

    CPTabViewItem m_OverlayOutlineTabItem;
    OverlayOutlineView m_OverlayOutlineView @accessors(property=outlineView);

    CPTabViewItem m_OverlayFiltersTabItem;
    OverlayFiltersView m_OverlayFiltersView;
}

- (id) initWithContentView:(CPView)contentView
{
    self = [self initWithFrame:CGRectMake(0, 0, 300, CGRectGetHeight([contentView bounds]))];
    [self setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];

    if(self)
    {
        m_TabView = [[CPTabView alloc] initWithFrame:CGRectMake(CGRectGetMinX([self bounds]), CGRectGetMinY([self bounds]) + 10, 300, CGRectGetHeight([self bounds]) - 10)];
        [m_TabView setTabViewType:CPTopTabsBezelBorder];
        [m_TabView setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];

        m_OverlayOutlineView = [[OverlayOutlineView alloc] initWithFrame: [m_TabView bounds]];
        m_OverlayFiltersView = [[OverlayFiltersView alloc] initWithFrame: [m_TabView bounds]];

        //Overlay Features
        m_OverlayOutlineTabItem = [[CPTabViewItem alloc] initWithIdentifier:@"OutlineTab"];
        [m_OverlayOutlineTabItem setLabel:"Overlay Features"];
        [m_OverlayOutlineTabItem setView:m_OverlayOutlineView];
        [m_TabView addTabViewItem:m_OverlayOutlineTabItem];

        //Overlay Filters
        m_OverlayFiltersTabItem = [[CPTabViewItem alloc] initWithIdentifier:@"FiltersTab"];
        [m_OverlayFiltersTabItem setLabel:"Overlay Filters"];
        [m_OverlayFiltersTabItem setView:m_OverlayFiltersView];
        [m_TabView addTabViewItem:m_OverlayFiltersTabItem];

        [self addSubview:m_TabView];
    }

    return self;
}

- (void)mapViewIsReady:(MKMapView)mapView
{
    [m_OverlayOutlineView loadOutline];
}

@end