@import <Foundation/CPObject.j>

@implementation AddFilterPanel : CPPanel
{
    CPButton m_CancelButton;
    CPButton m_AddFilterButton;

    CPTextField m_FilterName;
    CPPopUpButton m_FilterType;
}

- (id)initWithTarget:(id)target andAction:(SEL)action
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
        [m_AddFilterButton setTarget:target];
        [m_AddFilterButton setAction:action];
        [m_AddFilterButton sizeToFit];

        m_FilterName = [CPTextField roundedTextFieldWithStringValue:"Filter Name" placeholder:"What What" width:260];

        m_FilterType = [[CPPopUpButton alloc] initWithFrame:CGRectMake(20, 68, 260, 24)];
        [m_FilterType setTitle:"Filter Type"];
        [m_FilterType addItemWithTitle:"County"];
        [m_FilterType addItemWithTitle:"School District"];
        [m_FilterType addItemWithTitle:"Organization"];

        var cancelWidth = CGRectGetWidth([m_CancelButton bounds]);
        var addWidth = CGRectGetWidth([m_AddFilterButton bounds]);

        [m_FilterName setFrameOrigin:CGPointMake(20, 20)];
        [m_CancelButton setFrameOrigin:CGPointMake(300 - (addWidth + cancelWidth + 30), 115)];
        [m_AddFilterButton setFrameOrigin:CGPointMake(300 - (addWidth + 15), 115)];

        contentView = [self contentView];
        [contentView addSubview:m_FilterName];
        [contentView addSubview:m_FilterType];
        [contentView addSubview:m_CancelButton];
        [contentView addSubview:m_AddFilterButton];
    }

    return self;
}

- (CPString)filterName
{
    return [m_FilterName stringValue];
}

- (CPString)filterType
{
    return [[m_FilterType selectedItem] title];
}

- (void)onCancel:(id)sender
{
    [m_FilterType selectItemAtIndex:0];
    [m_FilterName setStringValue:"Filter Name"];
    [self close];
}

@end