@import <Foundation/CPObject.j>
@import <MapKit/MKMapView.j>

@import "MultiPolygonOverlay.j"
@import "PolygonOverlay.j"

@implementation GeoJson : CPObject
{
}

- (id)initWithGeoJson:(CPObject)geoJson
{
    if(typeof geoJson['type'] == 'object')
    {
        [self parseGeoJson:geoJson['type']];
    }
    if(geoJson['type'] == 'MultiPolygon')
    {
        return [[MultiPolygonOverlay alloc] initFromGeoJson:geoJson];
    }
}

@end