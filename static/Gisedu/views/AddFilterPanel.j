@import <Foundation/CPObject.j>

@import "../FilterManager.j"

@implementation AddFilterPanel : CPPanel
{
    CPButton m_CancelButton;
    CPButton m_AddFilterButton;

    CPPopUpButton m_FilterType;

    CPTreeNode m_ParentFilter;
    id m_Delegate   @accessors(property=delegate);
}

- (id)initWithParentFilter:(id)parentFilter
{
    self = [super initWithContentRect:CGRectMake(150,150,300,150) styleMask:CPClosableWindowMask];

    if(self)
    {
        [self setFloatingPanel:YES];
        [self setTitle:"Add New Filter"];
        [self setBackgroundColor:[CPColor whiteColor]];

        m_CancelButton = [CPButton buttonWithTitle:"Cancel"];
        [m_CancelButton setTarget:self];
        [m_CancelButton setAction:@selector(onCancel:)];
        [m_CancelButton sizeToFit];

        m_AddFilterButton = [CPButton buttonWithTitle:"Add Filter"];
        [m_AddFilterButton setTarget:self];
        [m_AddFilterButton setAction:@selector(onAddFilterConfirm:)];
        [m_AddFilterButton sizeToFit];

        m_FilterType = [[CPPopUpButton alloc] initWithFrame:CGRectMake(20, 48, 260, 24)];
        [m_FilterType setTitle:"Select Filter Here"];

        filterManager = [FilterManager getInstance];
        parentType = [filterManager typeFromFilter:parentFilter]

        if(!parentFilter || !parentType) //can be root filter
        {
            [m_FilterType addItemWithTitle:"County"];
            [m_FilterType addItemWithTitle:"School District"];
            [m_FilterType addItemWithTitle:"Public School"];
            [m_FilterType addItemWithTitle:"Organization"];
            [m_FilterType addItemWithTitle:"School ITC"];
            [m_FilterType addItemWithTitle:"ODE Income Classification"];
        }
        else if(parentType == 'county' || parentType == 'school_district')
        {
            [m_FilterType addItemWithTitle:"Public School"];
            [m_FilterType addItemWithTitle:"Organization"];
            [m_FilterType addItemWithTitle:"School ITC"];
            [m_FilterType addItemWithTitle:"ODE Income Classification"];
        }
        else if(parentType == 'school_itc' || parentType == 'ode_class')
        {
            [m_FilterType addItemWithTitle:"Public School"];
        }
        else if(parentType == 'school') // Can be combined with Schools
        {
            [m_FilterType addItemWithTitle:"Connectivity Less Than"];
            [m_FilterType addItemWithTitle:"Connectivity Greater Than"];
            [m_FilterType addItemWithTitle:"School ITC"];
            [m_FilterType addItemWithTitle:"ODE Income Classification"];
        }
        else if(parentType == 'organization')
        {
            [m_FilterType addItemWithTitle:"County"];
            [m_FilterType addItemWithTitle:"School District"];
        }
        else
        {
            [m_FilterType addItemWithTitle:"County"];
            [m_FilterType addItemWithTitle:"School District"];
            [m_FilterType addItemWithTitle:"Public School"];
            [m_FilterType addItemWithTitle:"Organization"];
            [m_FilterType addItemWithTitle:"School ITC"];
            [m_FilterType addItemWithTitle:"ODE Income Classification"];
        }

        var cancelWidth = CGRectGetWidth([m_CancelButton bounds]);
        var addWidth = CGRectGetWidth([m_AddFilterButton bounds]);

        [m_CancelButton setFrameOrigin:CGPointMake(300 - (addWidth + cancelWidth + 30), 115)];
        [m_AddFilterButton setFrameOrigin:CGPointMake(300 - (addWidth + 15), 115)];

        contentView = [self contentView];
        [contentView addSubview:m_FilterType];
        [contentView addSubview:m_CancelButton];
        [contentView addSubview:m_AddFilterButton];
    }

    return self;
}

- (void)onAddFilterConfirm:(id)sender
{
    var curSelFilterName = [[m_FilterType selectedItem] title];

    var newFilterType = nil;

    if(curSelFilterName == "County")
        newFilterType = 'county';
    else if(curSelFilterName == "School District")
        newFilterType = 'school_district';
    else if(curSelFilterName == "Organization")
        newFilterType = 'organization';
    else if(curSelFilterName == "Public School")
        newFilterType = 'school';
    else if(curSelFilterName == "Connectivity Less Than")
        newFilterType = 'connectivity_less';
    else if(curSelFilterName == "Connectivity Greater Than")
        newFilterType = 'connectivity_greater';
    else if(curSelFilterName == "School ITC")
        newFilterType = 'school_itc';
    else if(curSelFilterName == "ODE Income Classification")
        newFilterType = 'ode_class';

    if(newFilterType && [m_Delegate respondsToSelector:@selector(onAddFilterConfirm:)])
        [m_Delegate onAddFilterConfirm:newFilterType];

    [m_FilterType selectItemAtIndex:0];
    [self close];
}

- (void)onCancel:(id)sender
{
    [m_FilterType selectItemAtIndex:0];
    [self close];
}

@end