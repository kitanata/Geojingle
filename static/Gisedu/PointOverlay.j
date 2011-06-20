@import <Foundation/CPObject.j>

@import "../MapKit/MKLocation.j"
@import "../MapKit/MKMarker.j"

@import "loaders/InfoWindowOverlayLoader.j"

@implementation PointOverlay : CPControl
{
    Marker m_GoogleMarker @accessors(property=marker);

    MKLocation m_Point @accessors(property=point);

    CPInteger m_nIdentifier @accessors(property=pk);
    CPString m_szName @accessors(property=name);
    BOOL m_bVisible @accessors(property=visible);

    InfoWindowOverlayLoader m_InfoLoader;
    InfoWindowOverlay m_InfoWindow;

    SEL m_OnClickAction         @accessors(property=onClickAction);
    id m_EventTarget            @accessors(property=eventTarget);
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

    gm.event.addListener(m_GoogleMarker, 'click', function() {[self onClick];});
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
    if(m_InfoWindow)
    {
        [m_InfoWindow open:m_GoogleMarker];
    }
    else if(m_InfoLoader)
    {
        [m_InfoLoader load];
    }
}

- (void)closeInfoWindow
{
    if(m_InfoWindow)
    {
        [m_InfoWindow close];
    }
}

- (void)toggleInfoWindow
{
    if([m_InfoWindow opened])
    {
        [self closeInfoWindow];
    }
    else
    {
        [self openInfoWindow];
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

- (void)removeFromMapView
{
    m_GoogleMarker.setMap(null);
}

// EVENTS

- (void)onClick
{
    [self toggleInfoWindow];
    
    if(m_EventTarget && m_OnClickAction)
    {
        [self sendAction:m_OnClickAction to:m_EventTarget];
    }
}

@end