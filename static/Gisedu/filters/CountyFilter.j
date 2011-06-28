@import "GiseduFilter.j"

@import "../OverlayManager.j"

@implementation CountyFilter : GiseduFilter
{
    CPString m_szCounty @accessors(property=county);
}

- (id)initWithName:(CPString)name
{
    self = [super initWithName:name];

    if(self)
    {
        m_szCounty = "All";
        m_szType = "county";
    }

    return self;
}

- (CPString)requestUrl
{
    return "http://127.0.0.1:8000/filter/county_by_name/" + m_szCounty;
}

- (void)onError
{
    alert('County Filter failed to load filter data! ' + anError);
}

@end