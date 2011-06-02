@import <Foundation/CPObject.j>

@import "MultiPolygonOverlay.j"

@import "GeoJson.j"

@implementation PolygonOverlayItem : CPControl
{
    CPString m_szName;      //The name associated with this county
    CPInteger m_nIdentifier;
    BOOL m_bVisibleOnLoad;  //To mark visible(Not related to ShowAll)

    MultiPolygonOverlay m_Polygon @accessors(property=polygon);

    CPURLConnection m_CountyConnection; //To pull data from django
    CPString m_ConnectionURL;
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

        for(key in aData)
        {
            if(key == 'gid')
            {
                m_nDataId = aData[key];
            }
            else if(key == 'name')
            {
                m_szName = aData[key];
            }
            else if(key == 'the_geom')
            {
                m_Polygon = [[GeoJson alloc] initWithGeoJson:aData[key]];

                if(m_bVisibleOnLoad)
                {
                    var polys = [m_Polygon polygons];

                    for(var i=0; i < [polys count]; i++)
                    {
                        [[polys objectAtIndex:i] setVisible:m_bVisibleOnLoad];
                    }
                }
            }
        }

        if(_action != nil && _target != nil)
        {
            [self sendAction:_action to:_target];
        }
    }
}

- (void)showPolygons:(MKMapView)mapView
{
    polygons = [m_Polygon polygons];

    for(var i=0; i < [polygons count]; i++)
    {
        polygon = [polygons objectAtIndex:i];

        [polygon addToMapView:mapView];
    }
}

- (void)hidePolygons:(MKMapView)mapView
{
    polygons = [m_Polygon polygons];

    for(var i=0; i < [polygons count]; i++)
    {
        polygon = [polygons objectAtIndex:i];

        if(![polygon visible])
        {
            [polygon removeFromMapView:mapView];
        }
    }
}

@end