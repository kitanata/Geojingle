@import <Foundation/CPObject.j>

@import "../MapKit/MKLocation.j"
@import "../MapKit/MKMarker.j"

@implementation PointOverlay : CPObject
{
    Marker m_GoogleMarker @accessors(property=marker);

    MKLocation m_Point @accessors(property=point);

    CPInteger m_nIdentifier @accessors(property=pk);
    CPString m_szName @accessors(property=name);
    BOOL m_bVisible @accessors(property=visible);
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
        title: m_szName
     };

    m_GoogleMarker = new gm.Marker(markerOptions);
}

- (void)addToMapView:(MKMapView)mapView
{
    if(m_GoogleMarker == nil)
    {
        [self createGoogleMarker];
    }

    m_GoogleMarker.setMap([mapView gMap]);
}

- (void)removeFromMapView:(MKMapView)mapView
{
    m_GoogleMarker.setMap(null);
}

@end