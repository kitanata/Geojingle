@import <Foundation/CPObject.j>

@implementation RightSideTabView : CPView
{
    CPTabView m_TabView;
    CPArray m_TabViewItems;
}

- (id) initWithParentView:(CPView)parentView
{
    self = [self initWithFrame:CGRectMake(CGRectGetWidth([parentView bounds]) - 280, 0, 280, CGRectGetHeight([parentView bounds]))];
    [self setAutoresizingMask:CPViewHeightSizable | CPViewMinXMargin];

    if(self)
    {
        m_TabViewItems = [CPArray array];

        m_TabView = [[CPTabView alloc] initWithFrame:CGRectMake(CGRectGetMinX([self bounds]), CGRectGetMinY([self bounds]) + 10, 280, CGRectGetHeight([self bounds]) - 10)];
        [m_TabView setTabViewType:CPTopTabsBezelBorder];
        [m_TabView setAutoresizingMask:CPViewHeightSizable | CPViewMinXMargin];

        [self addSubview:m_TabView];
    }

    return self;
}

- (CGSize)tabViewBounds
{
    return [m_TabView bounds];
}

- (id)addModuleView:(CPView)theView withTitle:(CPString)title
{
    var newTabItem = [[CPTabViewItem alloc] initWithIdentifier:title];
    [newTabItem setLabel:title];
    [newTabItem setView:theView];
    
    [m_TabViewItems addObject:newTabItem];
    [m_TabView addTabViewItem:newTabItem];

    return newTabItem;
}

- (id)selectTabItem:(CPTabViewitem)tabItem
{
    [m_TabView selectTabViewItem:tabItem];
}

@end
