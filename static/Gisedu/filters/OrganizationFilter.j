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
        m_szType = "Organization";
    }

    return self;
}

- (CPSet)filter
{
    filterSet = [CPSet set];

    overlayManager = [OverlayManager getInstance];

    if(m_szOrganizationType == "All")
    {
        orgIds = [[overlayManager organizations] allKeys];

        var typeIds = [CPArray array];

        for(var i=0; i < [orgIds count]; i++)
        {
            [typeIds addObject:("org:"+[orgIds objectAtIndex:i])];
        }

        return [CPSet setWithArray:typeIds];
    }
    else if(m_szOrganization == "All")
    {
        var orgIds = [[overlayManager orgTypes] objectForKey:m_szOrganizationType];

        var typeIds = [CPArray array];

        for(var i=0; i < [orgIds count]; i++)
        {
            [typeIds addObject:("org:"+[orgIds objectAtIndex:i])];
        }

        return [CPSet setWithArray:typeIds];
    }
    else
    {
        var orgNames = [overlayManager orgNames];

        if([orgNames containsKey:m_szOrganization])
        {
            return [CPSet setWithObject:("org:"+[orgNames objectForKey:m_szOrganization])];
        }
    }

    return [CPSet set];
}

- (CPSet)intersect:(CPSet)childFilters
{

}

@end