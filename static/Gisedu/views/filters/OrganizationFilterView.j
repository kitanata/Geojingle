@import <Foundation/CPObject.j>

@import "../../OverlayManager.j"

@implementation OrganizationFilterView : CPControl
{
    OverlayManager m_OverlayManager;
    
    CPPopUpButton m_OrganizationType;
    CPPopUpButton m_Organization;

    CPButton m_UpdateButton;

    OrganizationFilter m_Filter @accessors(property=filter);
}

- (id)initWithFrame:(CGRect)aFrame andFilter:(OrganizationFilter)filter
{
    self = [super initWithFrame:aFrame];

    if(self)
    {
        m_Filter = filter;
        
        m_OverlayManager = [OverlayManager getInstance];

        m_OrganizationType = [[CPPopUpButton alloc] initWithFrame:CGRectMakeZero()];
        [m_OrganizationType addItemWithTitle:"All"];

        orgTypes = [[m_OverlayManager orgTypes] allKeys];
        if([orgTypes count] < 100)
            [m_OrganizationType addItemsWithTitles:orgTypes];

        m_Organization = [[CPPopUpButton alloc] initWithFrame:CGRectMakeZero()];

        orgTypeLabel = [CPTextField labelWithTitle:"Organization Type"];
        [orgTypeLabel sizeToFit];
        [orgTypeLabel setFrameOrigin:CGPointMake(20, 0)];

        [m_OrganizationType sizeToFit];
        [m_OrganizationType setFrameOrigin:CGPointMake(20, 20)];
        [m_OrganizationType setFrameSize:CGSizeMake(260, CGRectGetHeight([m_OrganizationType bounds]))];
        [m_OrganizationType selectItemWithTitle:[m_Filter organizationType]];

        m_UpdateButton = [CPButton buttonWithTitle:"Update Filter"];
        [m_UpdateButton sizeToFit];
        [m_UpdateButton setFrameOrigin:CGPointMake(20, 80)];
        [m_UpdateButton setAction:@selector(onFilterUpdateButton:)];
        [m_UpdateButton setTarget:self];

        [m_OrganizationType selectItemWithTitle:[m_Filter organizationType]];

        [self addSubview:orgTypeLabel];
        [self addSubview:m_OrganizationType];

        [self addSubview:m_UpdateButton];
    }

    return self;
}

- (void)onFilterUpdateButton:(id)sender
{
    [m_Filter setOrganizationType:[m_OrganizationType titleOfSelectedItem]];

    if(_action && _target)
    {
        [self sendAction:_action to:_target];
    }
}

@end