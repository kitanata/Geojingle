@import "GiseduFilter.j"

@implementation RadiusFilter : GiseduFilter
{
    CPFloat m_Latitude  @accessors(property=latitude);
    CPFloat m_Longitude @accessors(property=longitude);
    CPDistance m_Distance @accessors(property=distance);

    CPString m_ConnectionUrl @accessors(property=url);
    CPURLConnection m_Connection;
}

- (id)initWithUrl:(CPString)url
{
    self = [super init];

    if(self)
    {
        m_ConnectionUrl = url;
    }

    return self;
}

- (CPSet)filter
{
    
}

@end