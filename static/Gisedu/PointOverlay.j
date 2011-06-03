@import <Foundation/CPObject.j>

@import "../MapKit/MKLocation.j"
@import "../MapKit/MKMarker.j"

@implementation PointOverlay : CPObject
{
    MKMarker m_GoogleMarker @accessors(property=marker);

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

//Note: This function cannot be tested because of the nature
//of the google maps loading. TODO: Prove me wrong.
- (id)createGoogleMarker
{
    m_GoogleMarker = [[MKMarker alloc] initAtLocation:m_Point];

    return m_GoogleMarker;
}

- (void)addToMapView:(MKMapView)mapView
{
    if(m_GoogleMarker == nil)
    {
        [self createGoogleMarker];
    }

    [m_GoogleMarker addToMapView:mapView];
}

- (void)removeFromMapView:(MKMapView)mapView
{
    [m_GoogleMarker removeFromMapView:mapView];
}

@end