@import "GiseduFilter.j"

@implementation SchoolConnectivityFilter : GiseduFilter
{
    CPInteger m_nMinimum           @accessors(property=min);
    CPInteger m_nMaximum           @accessors(property=max);
}

- (id)init
{
    self = [super init];

    if(self)
    {
        m_nMinimum = 0;
        m_nMaximum = 1000;
        
        m_szType = "org";
    }

    return self;
}

- (CPString)name
{
    if(m_szOrganizationType == "All")
        return "All Organizations Filter";
    else if(m_szOrganization == "All")
        return "All " + m_szOrganizationType + " Filter";
    else
        return m_szOrganization + " Organization Filter";
}

- (CPString)requestUrl
{
    if(m_szOrganization == "All")
        return "http://127.0.0.1:8000/filter/org_by_connectivity/" + m_szOrganizationType;
    else
        return "http://127.0.0.1:8000/filter/org_by_name/" + m_szOrganization;
}

- (void)onError
{
    alert('Organization Filter failed to load filter data! ' + anError);
}

@end