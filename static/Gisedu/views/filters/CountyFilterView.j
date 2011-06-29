@import <Foundation/CPObject.j>

@import "../../OverlayManager.j"
@import "../CPDynamicSearch.j"

@implementation CountyFilterView : CPControl
{
    OverlayManager m_OverlayManager;

    CPTextField m_FilterName;
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

        m_CountySearchField = [[CPDynamicSearch alloc] initWithFrame:CGRectMake(20, 85, 260, 30)];
        [m_CountySearchField setSearchStrings:[[m_OverlayManager counties] allKeys]];
        [m_CountySearchField addSearchString:"All"];
        [m_CountySearchField setDefaultSearch:"All"];
        [m_CountySearchField setSearchSensitivity:1];
        [m_CountySearchField setStringValue:[m_Filter county]];
        [m_CountySearchField sizeToFit];

        filterNameLabel = [CPTextField labelWithTitle:"Filter Name"];
        [filterNameLabel sizeToFit];
        [filterNameLabel setFrameOrigin:CGPointMake(20, 0)];

        m_FilterName = [CPTextField roundedTextFieldWithStringValue:[m_Filter name] placeholder:"Filter Name" width:260];
        [m_FilterName setFrameOrigin:CGPointMake(20, 20)];

        countyTypeLabel = [CPTextField labelWithTitle:"County Selection"];
        [countyTypeLabel sizeToFit];
        [countyTypeLabel setFrameOrigin:CGPointMake(20, 60)];

        m_UpdateButton = [CPButton buttonWithTitle:"Update Filter"];
        [m_UpdateButton sizeToFit];
        [m_UpdateButton setFrameOrigin:CGPointMake(20, 125)];
        [m_UpdateButton setAction:@selector(onFilterUpdateButton:)];
        [m_UpdateButton setTarget:self];

        [self addSubview:filterNameLabel];
        [self addSubview:m_FilterName];

        [self addSubview:countyTypeLabel];
        [self addSubview:m_CountySearchField];

        [self addSubview:m_UpdateButton];
    }

    return self;
}

- (void)onFilterUpdateButton:(id)sender
{
    if([m_Filter county] != [m_CountySearchField stringValue])
        [m_Filter setCached:NO];
        
    [m_Filter setName:[m_FilterName stringValue]];
    [m_Filter setCounty:[m_CountySearchField stringValue]];

    if(_action && _target)
    {
        [self sendAction:_action to:_target];
    }
}

@end