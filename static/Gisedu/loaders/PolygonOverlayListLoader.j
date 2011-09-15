@import <Foundation/CPObject.j>

@import "../GeoJsonParser.j"

@implementation PolygonOverlayListLoader : CPControl
{
    id m_DisplayOptions             @accessors(property=displayOptions);
    id m_PolygonIdList              @accessors(property=idList);
    CPString m_DataType             @accessors(property=dataType);
    CPDictionary m_PolygonOverlays  @accessors(property=polygonOverlays);

    CPURLConnection m_Connection; //To pull data from django
    CPString m_ConnectionURL        @accessors(property=url);
}

- (id)initWithRequestUrl:(CPString)connectionUrl
{
    m_ConnectionURL = connectionUrl;
    m_PolygonOverlays = [CPDictionary dictionary];

    return self;
}

- (void)loadWithDisplayOptions:(id)displayOptions
{
    m_DisplayOptions = displayOptions;

    [m_Connection cancel];

    var request         = [CPURLRequest requestWithURL:m_ConnectionURL];
    var requestJson     = {'polygon_ids' : m_PolygonIdList};

    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[CPString JSONFromObject:requestJson]];

    m_Connection = [CPURLConnection connectionWithRequest:request delegate:self];
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
        var objectData = JSON.parse(aData);

        var geoJsonParser = [GeoJsonParser alloc];

        for(id in objectData)
        {
            var polygonOverlay = [geoJsonParser parsePolygon:objectData[id]];

            if(polygonOverlay != nil)
            {
                if(m_DisplayOptions)
                    [polygonOverlay setDisplayOptions:m_DisplayOptions];
            }

            [m_PolygonOverlays setObject:polygonOverlay forKey:id];
        }

        if(_action != nil && _target != nil)
        {
            [self sendAction:_action to:_target];
        }
    }
}

@end