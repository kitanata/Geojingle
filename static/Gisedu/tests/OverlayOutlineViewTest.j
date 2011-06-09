@import "../views/OverlayOutlineView.j"

//NOTE: The class name MUST be the same as the filename(minus the ext) for ojtest to work.

@implementation OverlayOutlineViewTest : OJTestCase
{
    CPView m_ContentView;
    OverlayOutlineView m_OutlineView;
}

- (void)setUp
{
    m_ContentView = [[CPView alloc] initWithFrame:CGRectMakeZero()];
    m_OutlineView = [[OverlayOutlineView alloc] initWithContentView:m_ContentView];
}

- (void)testInitSuccessful
{
    [self assertNotNull:m_OutlineView];
}

- (void)testSetArrayForItem
{
    orgItems = ["Item 1", "Item 2", "Item 3"];
    
    [m_OutlineView setArray:orgItems forItem:@"Items"];

    [self assertNotNull:[[m_OutlineView items] objectForKey:@"Items"]];
}

@end