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
        m_szType = "County";
    }

    return self;
}

- (id)initWithName:(CPString)name
{
    self = [self init];

    if(self)
        m_szName = name;

    return self;
}

- (CPSet)filter
{
    filterSet = [CPSet set];
    
    overlayManager = [OverlayManager getInstance];
    
    if(m_szCounty == "All")
    {
        countyIds = [[overlayManager counties] allValues];

        for(var i=0; i < [countyIds count]; i++)
        {
            curId = [countyIds objectAtIndex:i];

            typeIdPair = "county:"+curId;

            filterSet = [filterSet setByAddingObject:typeIdPair];
        }
    }
    else
    {
        counties = [overlayManager counties];

        if([counties containsKey:m_szCounty])
        {
            curId = [counties objectForKey:m_szCounty];

            typeIdPair = "county:"+curId;

            filterSet = [filterSet setByAddingObject:typeIdPair];
        }
    }

    return filterSet;
}

@end