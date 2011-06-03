@import <Foundation/CPObject.j>

@import "MultiPolygonOverlay.j"

@implementation MultiPolygonOverlay : CPObject
{
    CPInteger m_nIdentifier @accessors(property=pk);
    CPString m_szName @accessors(property=name);

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

- (String)typeName
{
    return "MultiPolygonOverlay";
}

@end