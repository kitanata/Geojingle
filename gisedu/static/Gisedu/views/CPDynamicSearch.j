@import <Foundation/CPObject.j>

@implementation CPDynamicSearch : CPSearchField
{
    CPMenu m_SearchMenu;

    CPArray m_SearchItems           @accessors(property=searchStrings);
    CPString m_DefaultSearch;
    CPInteger m_SearchSensitivity   @accessors(property=searchSensitivity);
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if(self)
    {
        m_SearchItems = [CPArray array];
        m_DefaultSearch = "Type To Search";
        m_SearchSensitivity = 4;
       
        [self setAction:@selector(onSearchFieldTextChanged:)];
        [self setTarget:self];
    }

    return self;
}

- (void)addSearchString:(CPString)searchString
{
    [m_SearchItems addObject:searchString];
}

- (void)setDefaultSearch:(CPString)defaultSearch
{
    m_DefaultSearch = defaultSearch;
    [self setStringValue:defaultSearch];
}

- (void)onSearchFieldTextChanged:(id)sender
{
    var searchString = [[self stringValue] lowercaseString];

    if([searchString length] >= m_SearchSensitivity)
    {
        var menuItems = [CPArray array];

        for(var i=0; i < [m_SearchItems count]; i++)
        {
            var testString = [[m_SearchItems objectAtIndex:i] lowercaseString];

            if(testString.indexOf(searchString) != -1)
            {
                [menuItems addObject:[m_SearchItems objectAtIndex:i]];
            }
        }

        m_SearchMenu = [[CPMenu alloc] initWithTitle:"Search"];
        [m_SearchMenu setAutoenablesItems:YES];

        for(var i=0; i < [menuItems count]; i++)
        {
            var item = [m_SearchMenu addItemWithTitle:[menuItems objectAtIndex:i] action:@selector(onSearchMenuItemSelected:) keyEquivalent:""];
            [item setTarget:self];
        }

        if([menuItems count] > 0)
        {
            [self setSearchMenuTemplate:m_SearchMenu];
        }
    }
    else
    {
        [self setSearchMenuTemplate:nil];
    }
}

- (void)onSearchMenuItemSelected:(id)sender
{
    if(m_SearchMenu)
    {
        [self setStringValue:[sender title]];

        if([_delegate respondsToSelector:@selector(onSearchMenuItemSelected:)])
            [_delegate onSearchMenuItemSelected:self];
    }
}

- (void)cancelOperation:(id)sender
{
    [self setObjectValue:m_DefaultSearch];
    [self _sendPartialString];
    [self _updateCancelButtonVisibility];
}

@end