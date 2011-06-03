@import <Foundation/CPObject.j>

@import "PointOverlay.j"
@import "PolygonOverlay.j"
@import "MultiPolygonOverlay.j"
@import "../MapKit/MKLocation.j"

@implementation GeoJsonParser : CPObject
{
}

- (id)parse:(CPString)geoJson
{
    var objectData = JSON.parse(geoJson);

    if(objectData['type'] == 'MultiPolygon')
    {
        overlay = [[MultiPolygonOverlay alloc] init];

        polygons = objectData['coordinates'];

        for(var i =0; i < polygons.length; i++)
        {
            var polygon = polygons[i];

            for(var j=0; j < polygon.length; j++)
            {
                var coords = polygon[j];

                var locarray = new Array();

                for(var k=0; k < coords.length; k++)
                {
                    locarray[k] = [[MKLocation alloc] initWithLatitude:coords[k][1] andLongitude:coords[k][0] ];
                }

                var locations = [[CPArray alloc] initWithArray:locarray];

                [overlay addPolygonOverlay:[[PolygonOverlay alloc] initWithLocations:locations]];
            }
        }

        return overlay;
    }
    else if(objectData['type'] == 'Point')
    {
        var overlay = [[PointOverlay alloc] init];

        var point = objectData['coordinates'];

        var location = [[MKLocation alloc] initWithLatitude:point[1] andLongitude:point[0] ];

        [overlay initFromLocation:location];

        return overlay;
    }
}

@end
