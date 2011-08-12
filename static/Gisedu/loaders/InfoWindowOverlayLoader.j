@import <Foundation/CPObject.j>

@import "../InfoWindowOverlay.j"

@implementation InfoWindowOverlayLoader : CPControl
{
    InfoWindowOverlay m_InfoOverlay @accessors(property=overlay);

    CPURLConnection m_Connection; //To pull data from django
    CPString m_ConnectionURL @accessors(property=url);
}

- (id)initWithRequestUrl:(CPString)connectionUrl
{
    m_ConnectionURL = connectionUrl;

    return self;
}

- (void)load
{
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
        m_InfoOverlay = [[InfoWindowOverlay alloc] initWithContent:aData];

        if(_action != nil && _target != nil)
        {
            [self sendAction:_action to:_target];
        }
    }
}

@end