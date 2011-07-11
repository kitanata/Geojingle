@import "GiseduFilter.j"

@import "../OverlayManager.j"

@implementation SchoolDistrictFilter : GiseduFilter
{
    CPString m_szSchoolDistrict     @accessors(property=schoolDistrict);
}

- (id)init
{
    self = [super init];

    if(self)
    {
        m_szSchoolDistrict = "All";
        m_szType = "school_district";
    }

    return self;
}

- (CPString)name
{
    if(m_szSchoolDistrict == "All")
        return "All School Districts Filter";
    else
        return m_szSchoolDistrict + " Filter";
}

@end