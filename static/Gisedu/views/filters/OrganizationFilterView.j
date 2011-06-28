@import <Foundation/CPObject.j>

@import "../../OverlayManager.j"

@implementation OrganizationFilterView : CPControl
{
    OverlayManager m_OverlayManager;

    CPTextField m_FilterName;
    
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

        for(var i=0; i < [orgTypes count]; i++)
        {
            [m_OrganizationType addItemWithTitle:[orgTypes objectAtIndex:i]];
        }

        m_Organization = [[CPPopUpButton alloc] initWithFrame:CGRectMakeZero()];

        filterNameLabel = [CPTextField labelWithTitle:"Filter Name"];
        [filterNameLabel sizeToFit];
        [filterNameLabel setFrameOrigin:CGPointMake(20, 0)];

        m_FilterName = [CPTextField roundedTextFieldWithStringValue:[m_Filter name] placeholder:"Filter Name" width:260];
        [m_FilterName setFrameOrigin:CGPointMake(20, 20)];

        orgTypeLabel = [CPTextField labelWithTitle:"Organization Type"];
        [orgTypeLabel sizeToFit];
        [orgTypeLabel setFrameOrigin:CGPointMake(20, 60)];

        [m_OrganizationType sizeToFit];
        [m_OrganizationType setFrameOrigin:CGPointMake(20, 85)];
        [m_OrganizationType setFrameSize:CGSizeMake(260, CGRectGetHeight([m_OrganizationType bounds]))];
        [m_OrganizationType selectItemWithTitle:[m_Filter organizationType]];
        [m_OrganizationType setAction:@selector(onOrganizationTypeChanged:)];
        [m_OrganizationType setTarget:self];

        orgLabel = [CPTextField labelWithTitle:"Organization"];
        [orgLabel sizeToFit];
        [orgLabel setFrameOrigin:CGPointMake(20, 125)];

        [m_Organization sizeToFit];
        [m_Organization setFrameOrigin:CGPointMake(20, 150)];
        [m_Organization setFrameSize:CGSizeMake(260, CGRectGetHeight([m_Organization bounds]))];
        [m_Organization selectItemWithTitle:[m_Filter organization]];

        m_UpdateButton = [CPButton buttonWithTitle:"Update Filter"];
        [m_UpdateButton sizeToFit];
        [m_UpdateButton setFrameOrigin:CGPointMake(20, 190)];
        [m_UpdateButton setAction:@selector(onFilterUpdateButton:)];
        [m_UpdateButton setTarget:self];

        [m_OrganizationType selectItemWithTitle:[m_Filter organizationType]];
        [self onOrganizationTypeChanged:self];
        [m_Organization selectItemWithTitle:[m_Filter organization]];

        [self addSubview:filterNameLabel];
        [self addSubview:m_FilterName];

        [self addSubview:orgTypeLabel];
        [self addSubview:m_OrganizationType];

        [self addSubview:orgLabel];
        [self addSubview:m_Organization];

        [self addSubview:m_UpdateButton];
    }

    return self;
}

- (void)onOrganizationTypeChanged:(id)sender
{
    console.log("Organization Type Changed");
    
    [m_Organization removeAllItems];

    var orgType = [m_OrganizationType titleOfSelectedItem];

    [m_Organization addItemWithTitle:"All"];

    if(orgType != "All")
    {
        orgIds = [m_OverlayManager getOrganizationsOfType:[m_OrganizationType titleOfSelectedItem]];

        for(var i=0; i < [orgIds count]; i++)
        {
            var curOrg = [m_OverlayManager getOrganization:[orgIds objectAtIndex:i]];
            [m_Organization addItemWithTitle:[curOrg name]];
        }
    }
}

- (void)onFilterUpdateButton:(id)sender
{
    [m_Filter setName:[m_FilterName stringValue]];

    [m_Filter setOrganizationType:[m_OrganizationType titleOfSelectedItem]];
    [m_Filter setOrganization:[m_Organization titleOfSelectedItem]];

    if(_action && _target)
    {
        [self sendAction:_action to:_target];
    }
}

@end