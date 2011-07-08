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

- (CPString)typeIdPrefix
{
    return "org";
}

- (CPString)requestUrl
{
    return "http://127.0.0.1:8000/filter/schools_by_type/" + m_szSchoolType;
}

- (void)onError
{
    alert('School Filter failed to load filter data! ' + anError);
}

@end