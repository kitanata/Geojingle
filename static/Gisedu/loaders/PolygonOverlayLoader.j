@import <Foundation/CPObject.j>

@import "../MultiPolygonOverlay.j"

@import "../GeoJsonParser.j"

@implementation PolygonOverlayLoader : CPControl
{
    CPURLConnection m_CountyConnection; //To pull data from django
    CPString m_ConnectionURL;

    CPInteger m_nIdentifier;
    BOOL m_bVisibleOnLoad;  //To mark visible(Not related to ShowAll)

    MultiPolygonOverlay m_Polygon @accessors(property=overlay);
}

- (id)initWithIdentifier:(CPInteger)identifier andUrl:(CPString)connectionUrl
{
    m_nIdentifier = identifier;
    m_ConnectionURL = connectionUrl;

    m_Polygon = nil;

    return self;
}

- (void)loadAndShow:(BOOL)showOnLoad
{
    m_bVisibleOnLoad = showOnLoad;

    [m_CountyConnection cancel];
    m_CountyConnection = [CPURLConnection connectionWithRequest:[CPURLRequest requestWithURL:m_ConnectionURL + m_nIdentifier] delegate:self];
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError
{
    if (aConnection == m_CountyConnection) {
        alert('Load failed! ' + anError);
        m_CountyConnection = nil;
    } else {
        alert('Save failed! ' + anError);
    }
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)aData
{
    if (aConnection == m_CountyConnection)
    {
        var aData = aData.replace('while(1);', '');
        var aData = JSON.parse(aData);

        var nPk = 0;
        var szName = "";

        for(key in aData)
        {
            if(key == 'gid')
            {
                nPk = aData[key];
            }
            else if(key == 'name')
            {
                szName = aData[key];
            }
            else if(key == 'the_geom')
            {
                geoJson = JSON.stringify(aData[key]);
                
                m_Polygon = [[GeoJsonParser alloc] parse:geoJson];
            }
        }

        if(m_Polygon != nil)
        {
            [m_Polygon setName:szName];
            [m_Polygon setPk:nPk];

            for(var i=0; i < [[m_Polygon polygons] count]; i++)
            {
                [[[m_Polygon polygons] objectAtIndex:i] setVisible:m_bVisibleOnLoad];
            }

        }

        if(_action != nil && _target != nil)
        {
            [self sendAction:_action to:_target];
        }
    }
}

@end