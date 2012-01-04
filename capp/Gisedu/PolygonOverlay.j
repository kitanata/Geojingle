@import <Foundation/CPObject.j>
@import "MapKit/MKMapView.j"
@import "MapKit/MKMapItem.j"
@import "MapKit/MKLocation.j"

@import "PolygonDisplayOptions.j"

@implementation PolygonOverlay : CPControl
{
    CPInteger m_nPk                         @accessors(property=pk);
    CPString m_szName                       @accessors(property=name);

    Polygon m_GooglePolygon                 @accessors(property=googlePolygon);

    CPArray     m_Paths                     @accessors(property=paths);
    PolygonDisplayOption m_DisplayOptions   @accessors(getter=displayOptions); // JS object representing additional options for the icon (used with circles and rects)

    BOOL m_bActive                          @accessors(property=active); //Is this polygon currently being edited?

    id m_Delegate                           @accessors(property=delegate);
}

- (id)init 
{
    if (self = [super init])
    {
        m_Paths = [CPArray array];
        m_szName = "Unknown";

        m_DisplayOptions = [PolygonDisplayOptions defaultOptions];
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
        
        var polyOptions = [m_DisplayOptions rawOptions];

        polyOptions.paths = linePaths;
        polyOptions.zIndex = 1;

        m_GooglePolygon.setOptions(polyOptions);

        if([m_DisplayOptions getDisplayOption:'visible'])
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

// EVENTS

- (void)onClick
{
    if([m_Delegate respondsToSelector:@selector(onPolygonOverlaySelected:)])
        [m_Delegate onPolygonOverlaySelected:self];
}

@end
