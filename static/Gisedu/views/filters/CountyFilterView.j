@import <Foundation/CPObject.j>

@import "../../OverlayManager.j"
@import "../CPDynamicSearch.j"

@implementation CountyFilterView : CPControl
{
    OverlayManager m_OverlayManager;

    CPDynamicSearch m_CountySearchField;

    CPButton m_UpdateButton;

    CountyFilter m_Filter @accessors(property=filter);
}

- (id)initWithFrame:(CGRect)aFrame andFilter:(CountyFilter)filter
{
    self = [super initWithFrame:aFrame];

    if(self)
    {
        m_Filter = filter;
        
        m_OverlayManager = [OverlayManager getInstance];

        m_CountySearchField = [[CPDynamicSearch alloc] initWithFrame:CGRectMake(20, 40, 260, 30)];
        [m_CountySearchField setSearchStrings:[[m_OverlayManager counties] allKeys]];
        [m_CountySearchField addSearchString:"All"];
        [m_CountySearchField setDefaultSearch:"All"];
        [m_CountySearchField setSearchSensitivity:1];
        [m_CountySearchField setStringValue:[m_Filter county]];
        [m_CountySearchField sizeToFit];

        countyTypeLabel = [CPTextField labelWithTitle:"County Selection"];
        [countyTypeLabel sizeToFit];
        [countyTypeLabel setFrameOrigin:CGPointMake(20, 20)];

        m_UpdateButton = [CPButton buttonWithTitle:"Update Filter"];
        [m_UpdateButton sizeToFit];
        [m_UpdateButton setFrameOrigin:CGPointMake(20, 85)];
        [m_UpdateButton setAction:@selector(onFilterUpdateButton:)];
        [m_UpdateButton setTarget:self];

        [self addSubview:countyTypeLabel];
        [self addSubview:m_CountySearchField];

        [self addSubview:m_UpdateButton];
    }

    return self;
}

- (void)onFilterUpdateButton:(id)sender
{
    [m_Filter setCounty:[m_CountySearchField stringValue]];

    if(_action && _target)
    {
        [self sendAction:_action to:_target];
    }
}

@end