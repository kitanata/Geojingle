@import <Foundation/CPObject.j>
@import "OverlayOutlineView.j"
@import "OverlayFiltersView.j"

@implementation LeftSideTabView : CPTabView
{
    CPTabViewItem m_OverlayOutlineTabItem;
    OverlayOutlineView m_OverlayOutlineView @accessors(property=outlineView);

    CPTabViewItem m_OverlayFiltersTabItem;
    OverlayFiltersView m_OverlayFiltersView @accessors(property=filtersView);
}

- (id) initWithContentView:(CPView)contentView
{
    self = [self initWithFrame:CGRectMake(CGRectGetMinX([contentView bounds]), 10, 300, CGRectGetHeight([contentView bounds]) - 10)];
    [self setTabViewType:CPTopTabsBezelBorder];
    [self setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];

    if(self)
    {
        m_OverlayOutlineView = [[OverlayOutlineView alloc] initWithFrame:[self bounds]];
        m_OverlayFiltersView = [[OverlayFiltersView alloc] initWithFrame:[self bounds]];

        //Overlay Features
        m_OverlayOutlineTabItem = [[CPTabViewItem alloc] initWithIdentifier:@"OutlineTab"];
        [m_OverlayOutlineTabItem setLabel:"Overlay Features"];
        [m_OverlayOutlineTabItem setView:m_OverlayOutlineView];
        [self addTabViewItem:m_OverlayOutlineTabItem];

        //Overlay Filters
        m_OverlayFiltersTabItem = [[CPTabViewItem alloc] initWithIdentifier:@"FiltersTab"];
        [m_OverlayFiltersTabItem setLabel:"Overlay Filters"];
        [m_OverlayFiltersTabItem setView:m_OverlayFiltersView];
        [self addTabViewItem:m_OverlayFiltersTabItem];
    }

    return self;
}

- (void)mapViewIsReady:(MKMapView)mapView
{
    [m_OverlayOutlineView loadOutline];
}

@end