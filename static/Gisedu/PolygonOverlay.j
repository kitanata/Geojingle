@import <Foundation/CPObject.j>
@import "../MapKit/MKMapView.j"
@import "../MapKit/MKMapItem.j"
@import "../MapKit/MKLocation.j"

@import "PointOverlay.j"

@implementation PolygonOverlay : CPControl
{
    CPString m_szName               @accessors(property=name);
    CPInteger m_nPk                 @accessors(property=pk);

    Polygon m_GooglePolygon         @accessors(property=googlePolygon);

    CPArray     m_Paths             @accessors(property=paths);
    id          m_DisplayOptions;                                       // JS object representing additional options for the icon (used with circles and rects)

    BOOL m_bActive                  @accessors(property=active); //Is this polygon currently being edited?

    id m_Delegate                   @accessors(property=delegate);
}

- (id)init 
{
    if (self = [super init])
    {
        m_Paths = [CPArray array];

        m_DisplayOptions = {
            strokeColor: "#ff0000",
            strokeOpacity: 1.0,
            strokeWeight: 3.0,
            fillColor: "#000000",
            fillOpacity: 0.3,
            visible: NO
        };
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
        
        var polyOptions = m_DisplayOptions;

        polyOptions.paths = linePaths;
        polyOptions.zIndex = 1;

        m_GooglePolygon.setOptions(polyOptions);

        if(m_DisplayOptions.visible)
            [self addToMapView];
        else
            [self removeFromMapView];
    }
}

- (void)addToMapView
{
    if(m_GooglePolygon == nil)
    {
        [self createGooglePolygon];
    }

    m_GooglePolygon.setMap([[MKMapView getInstance] gMap]);
}

- (void)removeFromMapView
{
    m_GooglePolygon.setMap(null);
}

- (void)setDisplayOptions:(id)displayOptions
{
    //Note to losers. This is a necessary psuedo-deep copy.
    m_DisplayOptions.strokeColor    = displayOptions.strokeColor;
    m_DisplayOptions.strokeOpacity  = displayOptions.strokeOpacity;
    m_DisplayOptions.strokeWeight   = displayOptions.strokeWeight;
    m_DisplayOptions.fillColor      = displayOptions.fillColor;
    m_DisplayOptions.fillOpacity    = displayOptions.fillOpacity;
    m_DisplayOptions.visible        = displayOptions.visible;
}

- (void)setDisplayOption:(CPString)option value:(id)value
{
    m_DisplayOptions[option] = value;
}

- (id)getDisplayOptions:(CPString)option
{
    return m_DisplayOptions[option];
}

// EVENTS

- (void)onClick
{
    if([m_Delegate respondsToSelector:@selector(onPolygonOverlaySelected:)])
        [m_Delegate onPolygonOverlaySelected:self];
}

@end