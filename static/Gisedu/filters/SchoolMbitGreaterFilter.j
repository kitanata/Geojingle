@import "GiseduFilter.j"

@implementation SchoolConnectivityFilter : GiseduFilter
{
    CPInteger m_nThreshold         @accessors(property=threshold);
}

- (id)init
{
    self = [super init];

    if(self)
    {
        m_nThreshold = 100;
        
        m_szType = "school_bit_greater";
    }

    return self;
}

- (CPString)name
{
    return "School Connectivity >= " + m_nThreshold;
}

@end