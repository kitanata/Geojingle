@import "GiseduFilter.j"

@implementation CountyFilter : GiseduFilter
{

}

- (id)init
{
    self = [super init];

    if(self)
        m_szType = "County";

    return self;
}

- (id)initWithName:(CPString)name
{
    self = [self init];

    if(self)
        m_szName = name;

    return self;
}

@end