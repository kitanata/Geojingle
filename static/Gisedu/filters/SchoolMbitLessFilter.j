@import "GiseduFilter.j"

@implementation SchoolMbitLessFilter : GiseduFilter
{
    CPInteger m_nThreshold         @accessors(property=threshold);
}

- (id)init
{
    self = [super init];

    if(self)
    {
        m_nThreshold = 100;
        
        m_szType = "school_mbit_less";
    }

    return self;
}

- (CPString)name
{
    return "School Connectivity <= " + m_nThreshold;
}

@end