@import <Foundation/CPObject.j>
@import "../MapKit/MKMapView.j"
@import "../MapKit/MKMapItem.j"
@import "../MapKit/MKLocation.j"

@implementation PolygonOverlay : MKMapItem
{
    CPString m_szName           @accessors(property=name);
    CPInteger m_nPk            @accessors(property=pk);

    Polygon m_GooglePolygon    @accessors(property=googlePolygon);

    CPArray     m_Locations     @accessors(property=locations);
    CPString    m_LineColorCode @accessors(property=lineColorCode);
    CPString    m_FillColorCode @accessors(property=fillColorCode);
    int         m_LineStroke    @accessors(property=lineStroke);
    float       m_FillOpacity   @accessors(property=fillOpacity);
    float       m_LineOpacity   @accessors(property=lineOpacity);

    BOOL m_Visible @accessors(property=visible);
    BOOL m_bActive @accessors(property=active); //Is this polygon currently being edited?
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

    //[self createGooglePolygon];

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

        var zIndex = 0;

        if(m_bActive)
        {
            zIndex = 1;
        }

        m_GooglePolygon = new gm.Polygon({
            paths: lineCoordinates,
            strokeColor: m_LineColorCode,
            strokeOpacity: m_LineOpacity,
            strokeWeight: m_LineStroke,
            fillColor: m_FillColorCode,
            fillOpacity: m_FillOpacity,
            zIndex: 1
        });
    }
}

- (void)setVisible:(BOOL)visible
{
    m_Visible = visible;
}

- (void)addToMapView:(MKMapView)mapView
{
    if(m_GooglePolygon == nil)
    {
        [self createGooglePolygon];
    }

    m_GooglePolygon.setMap([mapView gMap]);
}

- (void)removeFromMapView:(MKMapView)mapView
{
    m_GooglePolygon.setMap(null);
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