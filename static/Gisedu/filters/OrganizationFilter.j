@import "GiseduFilter.j"

@implementation OrganizationFilter : GiseduFilter
{
    CPString m_szOrganizationType   @accessors(property=organizationType);
    CPString m_szOrganization       @accessors(property=organization);
}

- (id)initWithName:(CPString)name
{
    self = [super initWithName:name];

    if(self)
    {
        m_szOrganizationType = "All";
        m_szOrganization = "All";
        m_szType = "org";
    }

    return self;
}

- (CPString)requestUrl
{
    if(m_szOrganization == "All")
        return "http://127.0.0.1:8000/filter/org_by_type/" + m_szOrganizationType;
    else
        return "http://127.0.0.1:8000/filter/org_by_name/" + m_szOrganization;
}

- (void)onError
{
    alert('Organization Filter failed to load filter data! ' + anError);
}

@end