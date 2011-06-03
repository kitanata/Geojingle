@import "../PolygonOverlay.j"

@implementation PolygonOverlayTest : OJTestCase
{

}

- (void)testSetName
{
    overlay = [[PolygonOverlay alloc] init]

    [overlay setName:"Test"];
    
    [self assert:"Test" equals:[overlay name]];
}

@end