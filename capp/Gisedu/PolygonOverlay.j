@import <Foundation/CPObject.j>

@import "MapOverlay.j"
@import "MapKit/MKMapView.j"
@import "MapKit/MKMapItem.j"
@import "MapKit/MKLocation.j"

@import "PolygonDisplayOptions.j"

@implementation PolygonOverlay : MapOverlay
{
    CPInteger m_nPk                         @accessors(property=pk);
    CPString m_szName                       @accessors(property=name);

    Polygon m_GooglePolygon                 @accessors(property=googlePolygon);

    CPArray     m_Paths                     @accessors(property=paths);
    PolygonDisplayOptions m_DisplayOptions   @accessors(getter=displayOptions); // JS object representing additional options for the icon (used with circles and rects)
    PolygonDisplayOptions m_FilterDisplayOptions @accessors(setter=setFilterDisplayOptions:);

    BOOL m_bActive                          @accessors(property=active); //Is this polygon currently being edited?
}

- (id)init 
{
    if (self = [super init])
    {
        m_Paths = [CPArray array];
        m_szName = "Unknown";

        m_DisplayOptions = [PolygonDisplayOptions defaultOptions];
        m_FilterDisplayOptions = [PolygonDisplayOptions defaultOptions];
    }

    return self;
}

- (void)addPolygonPath:(CPArray)pathLocations
{
    m_Paths = [m_Paths arrayByAddingObject:pathLocations];
}

- (void)createGooglePolygon:(PolygonDisplayOptions)displayOptions
{
    if (m_Paths)
    {
        var gm = [MKMapView gmNamespace];

        m_GooglePolygon = new gm.Polygon();

        [self updateGooglePolygon:displayOptions];

        gm.event.addListener(m_GooglePolygon, 'click', function() { [self onClick]; });
    }
}

- (void)updateGooglePolygon:(PolygonDisplayOptions)displayOptions
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
        
        var polyOptions = [displayOptions rawOptions];

        polyOptions.paths = linePaths;
        polyOptions.zIndex = 1;

        m_GooglePolygon.setOptions(polyOptions);

        if([displayOptions getDisplayOption:'visible'])
            [self addToMapView];
        else
            [self removeFromMapView];
    }
}

- (void)addToMapView
{
    m_GooglePolygon.setMap([[MKMapView getInstance] gMap]);
}

- (void)removeFromMapView
{
    m_GooglePolygon.setMap(null);
}

- (void)update
{
    var displayOptions = [PolygonDisplayOptions defaultOptions];
    [displayOptions enchantOptionsFrom:m_FilterDisplayOptions];
    [displayOptions enchantOptionsFrom:m_DisplayOptions];

    if(m_GooglePolygon == nil)
    {
        [self createGooglePolygon:displayOptions];
    }
    else
    {
        [self updateGooglePolygon:displayOptions];
    }
}

// EVENTS

- (void)onClick
{
    if([m_Delegate respondsToSelector:@selector(onPolygonOverlaySelected:)])
        [m_Delegate onPolygonOverlaySelected:self];
}

@end
