@import <Foundation/CPObject.j>

@import "MultiPolygonOverlay.j"

@implementation MultiPolygonOverlay : CPObject
{
    CPArray m_PolygonOverlays @accessors(property=polygons);
}

- (id)init
{
    m_PolygonOverlays = [CPArray array];

    return self;
}

- (id)initFromGeoJson:(CPObject)geoJson
{
    m_PolygonOverlays = [CPArray array];
    [self fromGeoJson:geoJson];

    return self;
}

- (void)addPolygonOverlay:(PolygonOverlay)polygonOverlay
{
    m_PolygonOverlays = [m_PolygonOverlays arrayByAddingObject:polygonOverlay];
}

- (void)addToMapView:(MKMapView)mapView
{
    var googleMap = [mapView gMap];

    for(var i=0; i < [m_PolygonOverlays count]; i++)
    {
        [[m_PolygonOverlays objectAtIndex:i] addToMapView:mapView];
    }
}

- (void)removeFromMapView:(MKMapView)mapView
{
    for(var i=0; i < [m_PolygonOverlays count]; i++)
    {
        [[m_PolygonOverlays objectAtIndex:i] removeFromMapView:mapView];
    }
}

- (void)fromGeoJson:(CPObject)geoJson
{
    polygons = geoJson['coordinates'];

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

            [self addPolygonOverlay:[[PolygonOverlay alloc] initWithLocations:locations]];
        }
    }
}

- (String)typeName
{
    return "MultiPolygonOverlay";
}

@end