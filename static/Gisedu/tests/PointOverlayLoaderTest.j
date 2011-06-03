@import "../PointOverlayLoader.j"

@implementation PointOverlayLoaderTest : OJTestCase
{

}

- (void)testInitWithIdentifier
{
    item = [[PointOverlayLoader alloc] initWithIdentifier:1 andUrl:"http://127.0.0.1/"];

    [self assert:"http://127.0.0.1/" equals:[item url]];
    [self assert:1 equals:[item identifier]];
}

@end