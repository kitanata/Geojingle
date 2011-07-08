@import "GiseduFilter.j"

@implementation OrganizationFilter : GiseduFilter
{
    CPString m_szOrganizationType   @accessors(property=organizationType);
}

- (id)init
{
    self = [super init];

    if(self)
    {
        m_szOrganizationType = "All";
        m_szType = "org";
    }

    return self;
}

- (CPString)name
{
    if(m_szOrganizationType == "All")
        return "All Organizations Filter";
    else
        return "All " + m_szOrganizationType + " Filter";
}

- (CPString)requestUrl
{
    return "http://127.0.0.1:8000/filter/org_by_type/" + m_szOrganizationType;
}

- (void)onError
{
    alert('Organization Filter failed to load filter data! ' + anError);
}

@end