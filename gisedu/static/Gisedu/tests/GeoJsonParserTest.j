//You need ojunit installed to run the test suite
//The command once installed is: ojtest tests/*Test.j

@import "../GeoJsonParser.j"

//NOTE: The class name MUST be the same as the filename(minus the ext) for ojtest to work.

@implementation GeoJsonParserTest : OJTestCase

- (void)testOneEqualsOne
{
    [self assert:1 equals:1];
}

- (void)testParseGeoJsonPoint
{
    var geoJson = '{"type": "Point", "coordinates": [-84.163285999999999, 40.718463]}';

    theParser = [GeoJsonParser alloc];

    var result = [theParser parse:geoJson];

    [self assertNotNull:result];
    [self assertNotNull:[result point]];
}

- (void)testParseGeoJsonMultiPolygon
{
    var geoJson = '{"type": "MultiPolygon", "coordinates": [[[[-83.386, 39.055], [-83.379, 39.055], [-83.375, 39.0545], [-83.386, 39.055]]]]}';

    theParser = [GeoJsonParser alloc];

    var result = [theParser parse:geoJson];

    [self assertNotNull:result];
    [self assertTrue:([[result paths] count] > 0)];
}

@end