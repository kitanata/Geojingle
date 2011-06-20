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
        m_szType = "County";
    }

    return self;
}

- (CPSet)filter
{
    overlayManager = [OverlayManager getInstance];
    
    if(m_szCounty == "All")
    {
        var typeIds = [CPArray array];
        var countyIds = [[overlayManager counties] allValues];
        var numCountyIds = [countyIds count];

        for(var i=0; i < numCountyIds; i++)
        {
            [typeIds addObject:("county:"+[countyIds objectAtIndex:i])];
        }

        return [CPSet setWithArray:typeIds];
    }
    else
    {
        counties = [overlayManager counties];

        if([counties containsKey:m_szCounty])
        {
            return [CPSet setWithObject:("county:"+[counties objectForKey:m_szCounty])];
        }
    }

    return [CPSet set];
}

- (CPSet)intersect:(CPSet)childFilters
{
    
}

@end