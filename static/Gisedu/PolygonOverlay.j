@import <Foundation/CPObject.j>
@import <MapKit/MKMapView.j>
@import <MapKit/MKMapItem.j>
@import <MapKit/MKLocation.j>

@implementation PolygonOverlay : MKMapItem
{
    Polygon m_GooglePolygon    @accessors(property=googlePolygon);

    CPArray     _locations     @accessors(property=locations);
    CPString    _lineColorCode @accessors(property=lineColorCode);
    int         _lineStroke    @accessors(property=lineStroke);
    int         _fillColorCode @accessors(property=fillColorCode);
    float       _fillOpacity   @accessors(property=fillOpacity);
    float       _lineOpacity   @accessors(property=lineOpacity);
}

- (id)init 
{
    return [self initWithLocations:nil];
}

- (id)initWithLocations:(CPArray)someLocations
{
    if (self = [super init])
    {
        _locations = someLocations;
        _lineColorCode = @"#ff0000";
        _fillColorCode = @"#000000";
        _fillOpacity = 0.3;
        _lineOpacity = 1;
        _lineStroke = 3;
    }

    if (_locations)
    {

        var gm = [MKMapView gmNamespace];
        var locEnum = [_locations objectEnumerator];

        var loc = nil
        var lineCoordinates = [];
        while (loc = [locEnum nextObject])
        {
            lineCoordinates.push([loc googleLatLng]);
        }

        m_GooglePolygon = new gm.Polygon(lineCoordinates, _lineColorCode, _lineStroke,  _lineOpacity, _fillColorCode, _fillOpacity);
    }

    return self;
}

- (void)addToMapView:(MKMapView)mapView
{
    var googleMap = [mapView gMap];
    googleMap.addOverlay([self googlePolygon]);
}

- (void)removeFromMapView:(MKMapView)mapView
{
    var googleMap = [mapView gMap];
    googleMap.removeOverlay([self googlePolygon]);
}

@end