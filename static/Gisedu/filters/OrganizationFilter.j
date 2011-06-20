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
        orgIds = [[overlayManager orgs] allValues];

        var numOrgs = [orgIds count];
        var typeIds = [CPArray array];

        for(var i=0; i < numOrgs; i++)
        {
            [typeIds addObject:("org:"+[orgIds objectAtIndex:i])];
        }

        return [CPSet setWithArray:typeIds];
    }
    else if(m_szOrganization == "All")
    {
        var orgNames = [[overlayManager orgTypes] objectForKey:m_szOrganizationType];
        
        var numOrgs = [orgNames count];

        var typeIds = [CPArray array];

        for(var i=0; i < numOrgs; i++)
        {
            [typeIds addObject:("org:"+[[overlayManager orgs] objectForKey:[orgNames objectAtIndex:i]])];
        }

        return [CPSet setWithArray:typeIds];
    }
    else
    {
        var orgs = [overlayManager orgs];

        if([orgs containsKey:m_szOrganization])
        {
            return [CPSet setWithObject:("org:"+[orgs objectForKey:m_szOrganization])];
        }
    }

    return [CPSet set];
}

- (CPSet)intersect:(CPSet)childFilters
{

}

@end