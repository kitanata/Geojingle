@import <Foundation/CPObject.j>
@import "../MapKit/MKMapView.j"
@import "../MapKit/MKMapItem.j"
@import "../MapKit/MKLocation.j"

@import "PointOverlay.j"

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

    id m_Delegate               @accessors(property=delegate);
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

        m_GooglePolygon = new gm.Polygon();

        [self updateGooglePolygon];

        gm.event.addListener(m_GooglePolygon, 'click', function() { [self onClick]; });
    }
}

- (void)updateGooglePolygon
{
    if(m_GooglePolygon)
    {
        var loc = nil
        var linePaths = [];

        for(var i=0; i < [m_Paths count]; i++)
        {
            linePaths.push([m_Paths objectAtIndex:i]);
        }

        var zIndex = 0;

        if(m_bActive)
        {
            zIndex = 1;
        }
        
        var polyOptions = {
            paths: linePaths,
            strokeColor: m_LineColorCode,
            strokeOpacity: m_LineOpacity,
            strokeWeight: m_LineStroke,
            fillColor: m_FillColorCode,
            fillOpacity: m_FillOpacity,
            zIndex: 1
        };

        m_GooglePolygon.setOptions(polyOptions);
    }
}

- (void)setVisible:(BOOL)visible
{
    m_Visible = visible;
}

- (void)addToMapView
{
    if(m_GooglePolygon == nil)
    {
        [self createGooglePolygon];
    }

    console.log("Adding Polygon to Map");

    m_GooglePolygon.setMap([[MKMapView getInstance] gMap]);
}

- (void)removeFromMapView
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

- (BOOL)containsPoint:(PointOverlay)point
{
    //Note: This algorithm is called the simple ray casting algorithm for polygon point detection.
    // It employs some pretty basic liner algebra but it will likely make your head hurt if you
    // haven't been exposed to matrixs, determinants, and vectors. If this is the case turn away before
    // you get hurt.

    var point3 = [point point];
    var point4 = [MKLocation locationWithLatitude:90.0 andLongitude:180.0];

    //O (n^2)
    for(var i=0; i < [m_Paths count]; i++)
    {
        var curPath = [m_Paths objectAtIndex:i];

        var pathsCrossed = 0;

        point1 = [curPath objectAtIndex:0];
        for(var j=1; j < [curPath count]; j++)
        {
            point2 = [curPath objectAtIndex:i];

            //test to see if the ray from the test point to the top left of the world crosses this path
            //if it does increase the number of pathsCrossed by one

            var point4latMinPoint3Lat = [point4 latitude] - [point3 latitude];
            var point4longMinPoint3Long = [point4 longitude] - [point3 longitude];
            var point2latMinPoint1Lat = [point2 latitude] - [point1 latitude];
            var point2longMinPoint1Long = [point2 longitude] - [point1 longitude];

            var point1LatMinPoint3Lat = [point1 latitude] - [point3 latitude];
            var point1LongMinPoint3Long = [point1 longitude] - [point3 longitude];

            denom = (point4latMinPoint3Lat * point2longMinPoint1Long) - (point4longMinPoint3Long * point2latMinPoint1Lat);

            if(denom == 0) //lines are coincident or parallel
                continue;

            aNumer = (point4longMinPoint3Long * point1LatMinPoint3Lat) - (point4latMinPoint3Lat * point1LongMinPoint3Long)

            if(aNumer - denom > 1 || aNumer - denom < 0)
                continue;

            bNumer = (point2longMinPoint1Long * point1LatMinPoint3Lat) - (point2latMinPoint1Lat * point1LongMinPoint3Long)

            if(bNumer - denom > 1 || bNumer - denom < 0)
                continue;

            pathsCrossed++;
        }

        if(pathsCrossed % 2 == 1) //http://en.wikipedia.org/wiki/Point_in_polygon
            return YES;
    }
}

// EVENTS

- (void)onClick
{
    if([m_Delegate respondsToSelector:@selector(onPolygonOverlaySelected:)])
        [m_Delegate onPolygonOverlaySelected:self];
}

@end