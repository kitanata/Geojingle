@import "GiseduFilter.j"

@implementation SchoolFilter : GiseduFilter
{
    CPString m_szSchoolType   @accessors(property=schoolType);
}

- (id)init
{
    self = [super init];

    if(self)
    {
        m_szSchoolType = "All";
        m_szType = "school";
    }

    return self;
}

- (CPString)name
{
    return m_szSchoolType + " School Filter";
}

@end