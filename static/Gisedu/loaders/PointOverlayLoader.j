@import <Foundation/CPObject.j>

@import "../GeoJsonParser.j"

@implementation PointOverlayLoader : CPControl
{
    id m_DisplayOptions             @accessors(property=displayOptions);

    PointOverlay m_PointOverlay     @accessors(property=overlay);

    CPURLConnection m_Connection; //To pull data from django
    CPString m_ConnectionURL        @accessors(property=url);
}

- (id)initWithRequestUrl:(CPString)connectionUrl
{
    m_szName = "Undefined";
    m_Polygon = nil;
    m_ConnectionURL = connectionUrl;

    return self;
}

- (void)loadWithDisplayOptions:(id)displayOptions
{
    m_DisplayOptions = displayOptions;

    [m_Connection cancel];
    m_Connection = [CPURLConnection connectionWithRequest:[CPURLRequest requestWithURL:m_ConnectionURL] delegate:self];
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
            if(m_DisplayOptions)
                [m_PointOverlay setDisplayOptions:m_DisplayOptions];
        }

        if(_action != nil && _target != nil)
        {
            [self sendAction:_action to:_target];
        }
    }
}

@end