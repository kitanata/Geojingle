@import <Foundation/CPObject.j>

@import "PolygonOverlayOptionsView.j"
@import "PointOverlayOptionsView.j"

@import "../PointOverlayOptionsController.j"
@import "../PointFilterOptionsController.j"

@import "../PolygonOverlayOptionsController.j"
@import "../PolygonFilterOptionsController.j"

@implementation OverlayOptionsView : CPView
{
    PolygonOverlayOptionsView m_PolyOptionsView @accessors(property=polyOptionsView);
    PointOverlayOptionsView m_PointOptionsView @accessors(property=pointOptionsView);

    CPTabView m_TabView;

    CPTabViewItem m_PolyTabItem;
    CPTabViewItem m_PointTabItem;
}

- (id) initWithParentView:(CPView)parentView
{
    self = [self initWithFrame:CGRectMake(CGRectGetWidth([parentView bounds]) - 280, 0, 280, CGRectGetHeight([parentView bounds]))];
    [self setAutoresizingMask:CPViewHeightSizable | CPViewMinXMargin];

    if(self)
    {
        m_TabView = [[CPTabView alloc] initWithFrame:CGRectMake(CGRectGetMinX([self bounds]), CGRectGetMinY([self bounds]) + 10, 280, CGRectGetHeight([self bounds]) - 10)];
        [m_TabView setTabViewType:CPTopTabsBezelBorder];
        [m_TabView setAutoresizingMask:CPViewHeightSizable | CPViewMinXMargin];

        m_PolyOptionsView = [[PolygonOverlayOptionsView alloc] initWithFrame:[m_TabView bounds]];
        m_PointOptionsView = [[PointOverlayOptionsView alloc] initWithFrame:[m_TabView bounds]];

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
    var optionsController = [PolygonOverlayOptionsController controllerWithOverlay:overlayTarget];

    [m_PolyOptionsView setOptionsController:optionsController];

    [m_TabView selectTabViewItem:m_PolyTabItem];
}

- (void)setPolygonFilterTarget:(PolygonFilter)filterTarget
{
    var optionsController = [PolygonFilterOptionsController controllerWithFilter:filterTarget];

    [m_PolyOptionsView setOptionsController:optionsController];

    [m_TabView selectTabViewItem:m_PolyTabItem];
}

- (void) setPointOverlayTarget: (PointOverlay)overlayTarget
{
    var optionsController = [PointOverlayOptionsController controllerWithOverlay:overlayTarget];

    [m_PointOptionsView setOptionsController:optionsController];

    [m_TabView selectTabViewItem:m_PointTabItem];
}

- (void) setPointFilterTarget: (PointFilter)filterTarget
{
    var optionsController = [PointFilterOptionsController controllerWithFilter:filterTarget];

    [m_PointOptionsView setOptionsController:optionsController];

    [m_TabView selectTabViewItem:m_PointTabItem];
}

@end