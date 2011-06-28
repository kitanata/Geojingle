@import <Foundation/CPObject.j>

@import "../MapKit/MKLocation.j"
@import "../MapKit/MKMarker.j"

@import "loaders/InfoWindowOverlayLoader.j"

@implementation PointOverlay : CPControl
{
    Marker m_GoogleMarker @accessors(property=marker);

    MKLocation m_Point @accessors(property=point);

    CPInteger m_nIdentifier @accessors(property=pk);
    CPString m_szTitle      @accessors(property=title);
    BOOL m_bVisible @accessors(property=visible);

    id m_Delegate   @accessors(property=delegate);
}

- (id)init
{
    self = [super init];

    if(self)
    {
        m_Point = nil;
        m_bVisible = NO;
    }

    return self;
}

- (id)initFromLocation:(MKLocation)location
{
    self = [self init];

    if(self)
    {
        m_Point = location;
        m_bVisible = NO;
    }
    
    return self;
}

- (void)createGoogleMarker
{
    var gm = [MKMapView gmNamespace];
    var latLng = [m_Point googleLatLng];

    var markerOptions =
    {
        position: latLng,
        clickable: true,
        draggable: false,
        title: m_szTitle
     };

    m_GoogleMarker = new gm.Marker(markerOptions);

    gm.event.addListener(m_GoogleMarker, 'click', function() {[self onClick];});
}

- (void)addToMapView:(MKMapView)mapView
{
    if(m_GoogleMarker == nil)
    {
        [self createGoogleMarker];
    }

    m_GoogleMarker.setMap([mapView gMap]);
}

- (void)removeFromMapView
{
    m_GoogleMarker.setMap(null);
}

// EVENTS

- (void)onClick
{
    console.log("On Click Called");
    console.log("Delegate is " + m_Delegate);
    
    if([m_Delegate respondsToSelector:@selector(onClick)])
        [m_Delegate onClick];
}

@end