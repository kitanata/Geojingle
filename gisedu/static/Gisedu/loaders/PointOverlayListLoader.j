@import <Foundation/CPObject.j>

@import "../GeoJsonParser.j"

@implementation PointOverlayListLoader : CPControl
{
    id m_DisplayOptions             @accessors(property=displayOptions);
    CPArray m_PointIdList           @accessors(property=idList);
    CPString m_DataType             @accessors(property=dataType);
    CPDictionary m_PointOverlays    @accessors(property=pointOverlays);

    CPURLConnection m_Connection; //To pull data from django
    CPString m_ConnectionURL        @accessors(property=url);
}

- (id)initWithRequestUrl:(CPString)connectionUrl
{
    m_ConnectionURL = connectionUrl;
    m_PointOverlays = [CPDictionary dictionary];

    return self;
}

- (void)loadWithDisplayOptions:(id)displayOptions
{
    m_DisplayOptions = displayOptions;

    [m_Connection cancel];

    var request         = [CPURLRequest requestWithURL:m_ConnectionURL];
    
    var pointIds = [];
    for(var i=0; i < [m_PointIdList count]; i++)
        pointIds.push([m_PointIdList objectAtIndex:i]);

    var requestJson     = {'point_ids' : pointIds};

    console.log(requestJson);

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
            var pointOverlay = [geoJsonParser parsePoint:objectData[id]];

            if(pointOverlay != nil)
            {
                if(m_DisplayOptions)
                    [[pointOverlay displayOptions] enchantOptionsFrom:m_DisplayOptions];
            }

            [m_PointOverlays setObject:pointOverlay forKey:id];
        }

        if(_action != nil && _target != nil)
        {
            [self sendAction:_action to:_target];
        }
    }
}

@end
