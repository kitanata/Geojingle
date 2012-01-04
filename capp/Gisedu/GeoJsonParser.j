@import <Foundation/CPObject.j>

@import "PointOverlay.j"
@import "PolygonOverlay.j"
@import "MapKit/MKLocation.j"
@import "MapKit/MKMapView.j"

@implementation GeoJsonParser : CPObject
{
}

- (id)parse:(CPString)geoJson
{
    var objectData = JSON.parse(geoJson);

    if(objectData['type'] == 'MultiPolygon')
    {
        return [self parsePolygon:objectData];
    }
    else if(objectData['type'] == 'Point')
    {
        return [self parsePoint:objectData];
    }
}

- (id)parsePolygon:(id)objectData
{
    overlay = [[PolygonOverlay alloc] init];

    polygons = objectData['coordinates'];

    var gm = [MKMapView gmNamespace];

    for(var i =0; i < polygons.length; i++)
    {
        var polygon = polygons[i];

        for(var j=0; j < polygon.length; j++)
        {
            var coords = polygon[j];

            var locarray = new Array();

            for(var k=0; k < coords.length; k++)
            {
                locarray[k] = new gm.LatLng(coords[k][1], coords[k][0]);
            }

            var locations = [CPArray arrayWithObjects:locarray count:locarray.length];

            [overlay addPolygonPath:locations];
        }
    }

    return overlay;
}

- (id)parsePoint:(id)objectData
{
    var overlay = [[PointOverlay alloc] init];

    var point = objectData['coordinates'];

    var location = [[MKLocation alloc] initWithLatitude:point[1] andLongitude:point[0] ];

    [overlay initFromLocation:location];

    return overlay;
}

@end
