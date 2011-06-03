//NOTE: The class name MUST be the same as the filename(minus the ext) for ojtest to work.

@import "../PointOverlay.j"
@import "../../MapKit/MKLocation.j"

@implementation PointOverlayTest : OJTestCase
{

}

- (void)testInitFromLocation
{
    var location = [[MKLocation alloc] initWithLatitude:"0.0" andLongitude:"0.0"];

    var result = [[PointOverlay alloc] initFromLocation:location];

    [self assertNotNull:result];

    [self assertNotNull:[result point]];
}

- (void)testSetVisibleIsVisible
{
    result = [[PointOverlay alloc] init];

    [self assert:NO equals:[result visible]];
    [result setVisible:YES];
    [self assert:YES equals:[result visible]];
}

@end