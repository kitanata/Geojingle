@import <Foundation/CPObject.j>

@import "../../OverlayManager.j"
@import "../CPDynamicSearch.j"

@implementation SchoolDistrictFilterView : CPControl
{
    OverlayManager m_OverlayManager;

    CPDynamicSearch m_SchoolDistrictSearch;

    CPButton m_UpdateButton;

    SchoolDistrictFilter m_Filter @accessors(property=filter);
    CPMenu m_SearchMenu;
}

- (id)initWithFrame:(CGRect)aFrame andFilter:(CountyFilter)filter
{
    self = [super initWithFrame:aFrame];

    if(self)
    {
        m_Filter = filter;
        
        m_OverlayManager = [OverlayManager getInstance];

        m_SchoolDistrictSearch = [[CPDynamicSearch alloc] initWithFrame:CGRectMake(20, 20, 260, 30)];
        [m_SchoolDistrictSearch setSearchStrings:[[m_OverlayManager schoolDistricts] allKeys]];
        [m_SchoolDistrictSearch addSearchString:"All"];
        [m_SchoolDistrictSearch setDefaultSearch:"All"];
        [m_SchoolDistrictSearch setStringValue:[m_Filter schoolDistrict]];
        [m_SchoolDistrictSearch sizeToFit];

        schoolDistrictNameLabel = [CPTextField labelWithTitle:"School District"];
        [schoolDistrictNameLabel sizeToFit];
        [schoolDistrictNameLabel setFrameOrigin:CGPointMake(20, 0)];

        m_UpdateButton = [CPButton buttonWithTitle:"Update Filter"];
        [m_UpdateButton sizeToFit];
        [m_UpdateButton setFrameOrigin:CGPointMake(20, 60)];
        [m_UpdateButton setAction:@selector(onFilterUpdateButton:)];
        [m_UpdateButton setTarget:self];

        [self addSubview:schoolDistrictNameLabel];
        [self addSubview:m_SchoolDistrictSearch];

        [self addSubview:m_UpdateButton];
    }

    return self;
}

- (void)onFilterUpdateButton:(id)sender
{
    [m_Filter setSchoolDistrict:[m_SchoolDistrictSearch stringValue]];

    if(_action && _target)
    {
        [self sendAction:_action to:_target];
    }
}

@end