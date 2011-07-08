@import <Foundation/CPObject.j>

@import "../GeoJsonParser.j"

@implementation PointOverlayLoader : CPControl
{
    CPInteger m_nIdentifier @accessors(property=identifier);
    BOOL m_bVisibleOnLoad @accessors(property=showOnLoad);

    PointOverlay m_PointOverlay @accessors(property=overlay);

    CPURLConnection m_Connection; //To pull data from django
    CPString m_ConnectionURL @accessors(property=url);
}

- (id)initWithIdentifier:(CPInteger)identifier andUrl:(CPString)connectionUrl
{
    m_szName = "Undefined";
    m_nIdentifier = identifier;
    m_Polygon = nil;
    m_ConnectionURL = connectionUrl;

    return self;
}

- (void)loadAndShow:(BOOL)showOnLoad
{
    m_bVisibleOnLoad = showOnLoad;

    [m_Connection cancel];
    m_Connection = [CPURLConnection connectionWithRequest:[CPURLRequest requestWithURL:m_ConnectionURL + m_nIdentifier] delegate:self];
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError
{
    if (aConnection == m_Connection)
    {
        alert('Load failed! ' + anError);
        m_Connection = nil;
    }
    else
    {
        alert('Save failed! ' + anError);
    }
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)aData
{
    if (aConnection == m_Connection)
    {
        var aData = aData.replace('while(1);', '');

        m_PointOverlay = [[GeoJsonParser alloc] parse:aData];

        if(m_PointOverlay != nil)
        {
            [m_PointOverlay setPk:m_nIdentifier];
            [m_PointOverlay setVisible:m_bVisibleOnLoad];
        }

        if(_action != nil && _target != nil)
        {
            [self sendAction:_action to:_target];
        }
    }
}

@end