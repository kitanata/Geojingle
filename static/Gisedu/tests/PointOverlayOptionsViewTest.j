@import "../PointOverlayOptionsView.j"

//NOTE: The class name MUST be the same as the filename(minus the ext) for ojtest to work.

@implementation PointOverlayOptionsViewTest : OJTestCase
{
    CPView m_ContentView;
    PointOverlayOptionsView m_OptionsView;
}

- (void)setUp
{
    m_ContentView = [[CPView alloc] initWithFrame:CGRectMakeZero()];
    m_OptionsView = [[PointOverlayOptionsView alloc] initWithFrame:[m_ContentView bounds] andMapView:nil];
}

- (void)testInitSuccessful
{
    [self assertNotNull:m_OptionsView];
}

- (void)testSetPointOverlay
{
    overlay = [[PointOverlay alloc] init];

    [m_OptionsView setOverlay:overlay];

    [self assertNotNull:[m_OptionsView overlay]];
}

@end