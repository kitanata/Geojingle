@import "../GiseduModule.j"

@import "PointDisplayOptionsView.j"
@import "PointOverlayOptionsController.j"
@import "PointFilterOptionsController.j"

@implementation PointDisplayOptionsModule : GiseduModule
{
    CPMenuItem m_MenuItem;
    PointDisplayOptionsView m_OptionsView;

    CPView m_RightSideTabView;
    CPTabViewItem m_PointOptionsTab;
}

- (id)initFromApp:(CPObject)app
{
    self = [super initFromApp:app];

    if(self)
    {
        m_RightSideTabView = [m_AppController rightSideTabView];
        m_OptionsView = [[PointDisplayOptionsView alloc] initWithFrame:[m_RightSideTabView tabViewBounds]];
        m_PointOptionsTab = [m_RightSideTabView addModuleView:m_OptionsView withTitle:@"Point Options"];
    }

    return self;
}

- (void)loadIntoMenu:(CPMenu)theMenu
{
    m_MenuItem = [[CPMenuItem alloc] initWithTitle:@"Point Display Options" 
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
    [m_RightSideTabView selectTabItem:m_PointOptionsTab];
}

- (void)enable
{
    [m_RightSideTabView enableModuleTabItem:m_PointOptionsTab]; 
}

- (void)disable
{
    [m_RightSideTabView disableModuleTabItem:m_PointOptionsTab];
}

- (void) setOverlayTarget: (PointOverlay)overlayTarget
{
    var optionsController = [PointOverlayOptionsController controllerWithOverlay:overlayTarget];

    [m_OptionsView setOptionsController:optionsController];
    [self onMenuItem:self];
}

- (void) setFilterTarget: (PointFilter)filterTarget
{
    var optionsController = [PointFilterOptionsController controllerWithFilter:filterTarget];

    [m_OptionsView setOptionsController:optionsController];
    [self onMenuItem:self];
}

@end
