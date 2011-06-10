@import <Foundation/CPObject.j>

@import "../MapKit/MKLocation.j"
@import "../MapKit/MKMarker.j"

@import "loaders/InfoWindowOverlayLoader.j"

@implementation PointOverlay : CPObject
{
    Marker m_GoogleMarker @accessors(property=marker);

    MKLocation m_Point @accessors(property=point);

    CPInteger m_nIdentifier @accessors(property=pk);
    CPString m_szName @accessors(property=name);
    BOOL m_bVisible @accessors(property=visible);

    InfoWindowOverlayLoader m_InfoLoader;
    InfoWindowOverlay m_InfoWindow;
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

    gm.event.addListener(m_GoogleMarker, 'click', function() {[self openInfoWindow];});
}

- (void)setInfoLoader:(InfoWindowOverlayLoader)infoLoader
{
    m_InfoLoader = infoLoader;
    [m_InfoLoader setTarget:self];
    [m_InfoLoader setAction:@selector(OnInfoLoaded:)];
}

- (void)OnInfoLoaded:(id)sender
{
    m_InfoWindow = [sender overlay];

    [m_InfoWindow open:m_GoogleMarker];
}

- (void)openInfoWindow
{
    var gm = [MKMapView gmNamespace];

    if(m_InfoLoader)
    {
        if(m_InfoWindow)
        {
            [m_InfoWindow open:m_GoogleMarker];
        }
        else
        {
            [m_InfoLoader load];
        }
    }
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