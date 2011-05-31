@import <Foundation/CPObject.j>

@import "MultiPolygonOverlay.j"

@import "GeoJson.j"

@implementation CountyOverlay : CPObject
{
    CPString m_szName;      //The name associated with this county
    MKMapView m_MapView;    //The MapView this overlay sits in

    MultiPolygonOverlay m_Polygon @accessors(property=polygon);
    
    CPInteger m_nDataId;    //The Database ID for this county(Used to pull additional info)

    CPURLConnection m_CountyConnection; //To pull data from django
}

- (id)initWithIdentifier:(CPInteger)identifier andMapView:(MKMapView)mapview
{
    m_MapView = mapview;
    m_nDataId = identifier;
    m_szName = "Undefined";
    m_Polygon = nil;

    [self loadCounty:identifier];

    return self;
}

- (void)loadCounty:(CPInteger)identifier
{
    m_nDataId = identifier;
    
    [m_CountyConnection cancel];
    m_CountyConnection = [CPURLConnection connectionWithRequest:[CPURLRequest requestWithURL:"http://127.0.0.1:8000/county/" + identifier] delegate:self];
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

                [m_Polygon addToMapView:m_MapView];
            }
        }
    }
}

- (void)showPolygons
{
    polygons = [m_Polygon polygons];

    for(var i=0; i < [polygons count]; i++)
    {
        polygon = [polygons objectAtIndex:i];

        [polygon addToMapView:m_MapView];
    }
}

- (void)hidePolygons
{
    polygons = [m_Polygon polygons];

    for(var i=0; i < [polygons count]; i++)
    {
        polygon = [polygons objectAtIndex:i];

        if(![polygon visible])
        {
            [polygon removeFromMapView:m_MapView];
        }
    }
}

@end