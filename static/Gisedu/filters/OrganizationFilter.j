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

@end