@import <Foundation/CPObject.j>

@implementation InfoWindowOverlay : CPObject
{
    InfoWindow m_InfoWindow;
}

- (id) initWithContent:(CPString)contentString
{
    self = [super init];

    if(self)
    {
        var gm = [MKMapView gmNamespace];
        m_InfoWindow = new gm.InfoWindow({content: contentString});
    }

    return self;
}

- (CPString)content
{
    if(m_InfoWindow)
    {
        return m_InfoWindow.getContent();
    }

    return "Error";
}

- (void)open:(JSObject)marker
{
    m_InfoWindow.open(marker.getMap(), marker);
}

@end