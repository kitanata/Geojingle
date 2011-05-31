@import <Foundation/CPObject.j>
@import <MapKit/MKMapView.j>
@import <MapKit/MKMapItem.j>
@import <MapKit/MKLocation.j>

@implementation PolygonOverlay : MKMapItem
{
    Polygon m_GooglePolygon    @accessors(property=googlePolygon);

    CPArray     m_Locations     @accessors(property=locations);
    CPString    m_LineColorCode @accessors(property=lineColorCode);
    CPString    m_FillColorCode @accessors(property=fillColorCode);
    int         m_LineStroke    @accessors(property=lineStroke);
    float       m_FillOpacity   @accessors(property=fillOpacity);
    float       m_LineOpacity   @accessors(property=lineOpacity);

    BOOL m_Visible @accessors(property=visible);
}

- (id)init 
{
    return [self initWithLocations:nil];
}

- (id)initWithLocations:(CPArray)someLocations
{
    if (self = [super init])
    {
        m_Locations = someLocations;
        m_LineColorCode = @"#ff0000";
        m_FillColorCode = @"#000000";
        m_FillOpacity = 0.3;
        m_LineOpacity = 1;
        m_LineStroke = 3;

        m_Visible = NO;
    }

    [self createGooglePolygon];

    return self;
}

- (void)createGooglePolygon
{
    if (m_Locations)
    {
        var gm = [MKMapView gmNamespace];
        var locEnum = [m_Locations objectEnumerator];

        var loc = nil
        var lineCoordinates = [];
        while (loc = [locEnum nextObject])
        {
            lineCoordinates.push([loc googleLatLng]);
        }

        m_GooglePolygon = new gm.Polygon(lineCoordinates, m_LineColorCode, m_LineStroke,  m_LineOpacity, m_FillColorCode, m_FillOpacity);
    }
}

- (void)setVisible:(BOOL)visible
{
    m_Visible = visible;
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

- (void)setLineColorCode:(CPString)colorCode
{
    m_LineColorCode = colorCode;

    [self createGooglePolygon];
}

- (void)setFillColorCode:(CPString)colorCode
{
    m_FillColorCode = colorCode;

    [self createGooglePolygon];
}

- (void)setLineStroke:(int)stroke
{
    m_LineStroke = stroke;

    [self createGooglePolygon];
}

- (void)setFillOpacity:(float)opacity
{
    m_FillOpacity = opacity;

    [self createGooglePolygon];
}

- (void)setLineOpacity:(float)opacity
{
    m_LineOpacity = opacity;

    [self createGooglePolygon];
}

@end