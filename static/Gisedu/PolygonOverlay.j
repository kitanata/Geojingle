@import <Foundation/CPObject.j>
@import "../MapKit/MKMapView.j"
@import "../MapKit/MKMapItem.j"
@import "../MapKit/MKLocation.j"

@implementation PolygonOverlay : CPControl
{
    CPString m_szName           @accessors(property=name);
    CPInteger m_nPk            @accessors(property=pk);

    Polygon m_GooglePolygon    @accessors(property=googlePolygon);

    CPArray     m_Paths         @accessors(property=paths);
    CPString    m_LineColorCode @accessors(property=lineColorCode);
    CPString    m_FillColorCode @accessors(property=fillColorCode);
    int         m_LineStroke    @accessors(property=lineStroke);
    float       m_FillOpacity   @accessors(property=fillOpacity);
    float       m_LineOpacity   @accessors(property=lineOpacity);

    BOOL m_Visible @accessors(property=visible);
    BOOL m_bActive @accessors(property=active); //Is this polygon currently being edited?

    SEL m_OnClickAction         @accessors(property=onClickAction);
    id m_EventTarget            @accessors(property=eventTarget);
}

- (id)init 
{
    if (self = [super init])
    {
        m_Paths = [CPArray array];
        m_LineColorCode = @"#ff0000";
        m_FillColorCode = @"#000000";
        m_FillOpacity = 0.3;
        m_LineOpacity = 1;
        m_LineStroke = 3;

        m_Visible = NO;
    }

    return self;
}

- (void)addPolygonPath:(CPArray)pathLocations
{
    m_Paths = [m_Paths arrayByAddingObject:pathLocations];
}

- (void)createGooglePolygon
{
    if (m_Paths)
    {
        var gm = [MKMapView gmNamespace];

        var loc = nil
        var linePaths = [];

        for(var i=0; i < [m_Paths count]; i++)
        {
            var locations = [m_Paths objectAtIndex:i];

            var lineCoordinates = [];

            for(var k=0; k < [locations count]; k++)
            {
                loc = [locations objectAtIndex:k];

                lineCoordinates.push([loc googleLatLng]);
            }

            linePaths.push(lineCoordinates);
        }

        var zIndex = 0;

        if(m_bActive)
        {
            zIndex = 1;
        }

        m_GooglePolygon = new gm.Polygon({
            paths: linePaths,
            strokeColor: m_LineColorCode,
            strokeOpacity: m_LineOpacity,
            strokeWeight: m_LineStroke,
            fillColor: m_FillColorCode,
            fillOpacity: m_FillOpacity,
            zIndex: 1
        });

        gm.event.addListener(m_GooglePolygon, 'click', function() { [self onClick]; });
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

    console.log("Adding Polygon to Map");

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

// EVENTS

- (void)onClick
{
    if(m_EventTarget && m_OnClickAction)
    {
        [self sendAction:m_OnClickAction to:m_EventTarget];
    }
}

@end