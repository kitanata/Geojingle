@import "GiseduFilter.j"

@import "../OverlayManager.j"

@implementation CountyFilter : GiseduFilter
{
    CPString m_szCounty @accessors(property=county);
}

- (id)init
{
    self = [super init];

    if(self)
    {
        m_szCounty = "All";
        m_szType = "county";
    }

    return self;
}

- (CPString)name
{
    if(m_szCounty == "All")
        return "All Counties Filter";
    else
        return m_szCounty + " County Filter";
}

- (CPString)requestUrl
{
    return "http://127.0.0.1:8000/filter/county_by_name:" + m_szCounty;
}

- (void)onError
{
    alert('County Filter failed to load filter data! ' + anError);
}

@end