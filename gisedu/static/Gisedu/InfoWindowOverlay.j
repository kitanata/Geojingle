@import <Foundation/CPObject.j>

@implementation InfoWindowOverlay : CPObject
{
    InfoWindow m_InfoWindow;
    
    BOOL m_bOpened @accessors(property=opened);
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
    if(!m_bOpened)
    {
        m_InfoWindow.open(marker.getMap(), marker);
    }

    m_bOpened = YES;
}

- (void)close
{
    if(m_bOpened)
    {
        m_InfoWindow.close();
    }

    m_bOpened = NO;
}

@end