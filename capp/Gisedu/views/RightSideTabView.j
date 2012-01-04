@import <Foundation/CPObject.j>

@implementation RightSideTabView : CPView
{
    CPTabView m_TabView;
}

- (id) initWithParentView:(CPView)parentView
{
    self = [self initWithFrame:CGRectMake(CGRectGetWidth([parentView bounds]) - 280, 0, 280, CGRectGetHeight([parentView bounds]))];
    [self setAutoresizingMask:CPViewHeightSizable | CPViewMinXMargin];

    if(self)
    {
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
    
    [m_TabView addTabViewItem:newTabItem];

    return newTabItem;
}

- (void)enableModuleTabItem:(CPTabViewItem)item
{
    if(![[m_TabView tabViewItems] containsObject:item])
        [m_TabView addTabViewItem:item];
}

//Due to a bug in Cappucinno when we remove tab items dynamically we have to recreate the 
//entire damn view from scratch. This bug applied as recently as version 0.9.5
- (void)disableModuleTabItem:(CPTabViewItem)item
{
    var curTabItems = [m_TabView tabViewItems];
    [curTabItems removeObject:item];
    [m_TabView removeFromSuperview];//kill it

    m_TabView = [[CPTabView alloc] initWithFrame:CGRectMake(CGRectGetMinX([self bounds]), CGRectGetMinY([self bounds]) + 10, 280, CGRectGetHeight([self bounds]) - 10)];
    [m_TabView setTabViewType:CPTopTabsBezelBorder];
    [m_TabView setAutoresizingMask:CPViewHeightSizable | CPViewMinXMargin];

    for(var i=0; i < [curTabItems count]; i++)
        [m_TabView addTabViewItem:[curTabItems objectAtIndex:i]];

    [self addSubview:m_TabView];
}

- (id)selectTabItem:(CPTabViewitem)item
{
    if([[m_TabView tabViewItems] containsObject:item])
        [m_TabView selectTabViewItem:item];
}

@end
