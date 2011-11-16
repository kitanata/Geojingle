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

- (id)initWithFilterNames:(CPArray)filterNames
{
    self = [super initWithContentRect:CGRectMake(0,276,300,150) styleMask:CPClosableWindowMask];

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

        [m_FilterType addItemsWithTitles:filterNames];

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
    var filterManager = [FilterManager getInstance];

    var curSelFilterName = [[m_FilterType selectedItem] title];
    var newFilterType = [filterManager filterIdFromName:curSelFilterName];

    console.log("CurSelFilterName is " + curSelFilterName);
    console.log("New Filter Type is " + newFilterType);

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