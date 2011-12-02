@import "../GiseduModule.j"

@import "PolygonDisplayOptionsView.j"
@import "PolygonOverlayOptionsController.j"
@import "PolygonFilterOptionsController.j"

@implementation PolygonDisplayOptionsModule : GiseduModule
{
    CPMenuItem m_MenuItem;
    PolygonDisplayOptionsView m_OptionsView;

    CPView m_RightSideTabView;
    CPTabViewItem m_PolygonOptionsTab;
}

- (id)initFromApp:(CPObject)app
{
    self = [super initFromApp:app];

    if(self)
    {
        m_RightSideTabView = [m_AppController rightSideTabView];
        m_OptionsView = [[PolygonDisplayOptionsView alloc] initWithFrame:[m_RightSideTabView tabViewBounds]];
        m_PolygonOptionsTab = [m_RightSideTabView addModuleView:m_OptionsView withTitle:@"Polygon Options"];
    }

    return self;
}

- (void)loadIntoMenu:(CPMenu)theMenu
{
    m_MenuItem = [[CPMenuItem alloc] initWithTitle:@"Polygon Display Options" 
        action:@selector(onMenuItem:) keyEquivalent:nil];

    [m_MenuItem setTarget:self];
    [theMenu addItem:m_MenuItem];
}

- (void)updateMenuItems:(BOOL)sessionActive
{
    [m_MenuItem setHidden:NO];
}

- (void)onMenuItem:(id)sender
{
    [m_AppController showRightSideTabView];
    [m_RightSideTabView selectTabItem:m_PolygonOptionsTab];
}

- (void)enable
{
    [m_RightSideTabView enableModuleTabItem:m_PolygonOptionsTab]; 
}

- (void)disable
{
    [m_RightSideTabView disableModuleTabItem:m_PolygonOptionsTab];
}

- (void) setOverlayTarget: (PointOverlay)overlayTarget
{
    var optionsController = [PolygonOverlayOptionsController controllerWithOverlay:overlayTarget];

    [m_OptionsView setOptionsController:optionsController];
    [self onMenuItem:self];
}

- (void) setFilterTarget: (PointFilter)filterTarget
{
    var optionsController = [PolygonFilterOptionsController controllerWithFilter:filterTarget];

    [m_OptionsView setOptionsController:optionsController];
    [self onMenuItem:self];
}

@end
