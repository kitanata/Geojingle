@import <Foundation/CPObject.j>

@implementation AddFilterPanel : CPPanel
{
    CPButton m_CancelButton;
    CPButton m_AddFilterButton;

    CPTextField m_FilterName;
    CPPopUpButton m_FilterType;
}

- (id)init
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
        [m_AddFilterButton setAction:@selector(onAddFilter:)];
        [m_AddFilterButton sizeToFit];

        m_FilterName = [CPTextField roundedTextFieldWithStringValue:"Filter Name" placeholder:"What What" width:260];

        m_FilterType = [[CPPopUpButton alloc] initWithFrame:CGRectMake(20, 68, 260, 24)];
        [m_FilterType setTitle:"Filter Type"];
        [m_FilterType addItemWithTitle:"County Contains"];
        [m_FilterType addItemWithTitle:"County Intersects"];
        [m_FilterType addItemWithTitle:"School District Contains"];
        [m_FilterType addItemWithTitle:"School District Intersects"];

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

- (void)onCancel:(id)sender
{
    [self close];
}

+ (id)makePanel
{
    return [[AddFilterPanel alloc] init];
}

@end