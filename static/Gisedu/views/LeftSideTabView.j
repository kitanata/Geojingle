@import <Foundation/CPObject.j>
@import "OverlayOutlineView.j"
@import "OverlayFiltersView.j"

@implementation LeftSideTabView : CPTabView
{
    CPTabViewItem m_OverlayFiltersTabItem;
    OverlayFiltersView m_OverlayFiltersView @accessors(property=filtersView);

    CPTabViewItem m_OverlayOutlineTabItem;
    OverlayOutlineView m_OverlayOutlineView @accessors(property=outlineView);
}

- (id) initWithContentView:(CPView)contentView
{
    self = [self initWithFrame:CGRectMake(CGRectGetMinX([contentView bounds]), 10, 300, CGRectGetHeight([contentView bounds]) - 10)];
    [self setTabViewType:CPTopTabsBezelBorder];
    [self setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];

    if(self)
    {
        m_OverlayFiltersView = [[OverlayFiltersView alloc] initWithFrame:[self bounds]];

        //Overlay Filters
        m_OverlayFiltersTabItem = [[CPTabViewItem alloc] initWithIdentifier:@"FiltersTab"];
        [m_OverlayFiltersTabItem setLabel:"Filter Engine"];
        [m_OverlayFiltersTabItem setView:m_OverlayFiltersView];

        //Overlay Features
        m_OverlayOutlineTabItem = [[CPTabViewItem alloc] initWithIdentifier:@"OutlineTab"];
        [m_OverlayOutlineTabItem setLabel:"Feature Outline"];

        [self addTabViewItem:m_OverlayFiltersTabItem];
        [self addTabViewItem:m_OverlayOutlineTabItem];
    }

    return self;
}

- (void)mapViewIsReady:(MKMapView)mapView
{
    m_OverlayOutlineView = [[OverlayOutlineView alloc] initWithFrame:[self bounds]];
    [m_OverlayOutlineTabItem setView:m_OverlayOutlineView];
}

@end