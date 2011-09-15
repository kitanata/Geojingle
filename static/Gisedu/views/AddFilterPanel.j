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

- (id)initWithParentFilter:(GiseduFilter)parentFilter
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
        parentType = [parentFilter type];

        var filterDescriptions = [filterManager filterDescriptions];

        var excludedFilterIds = [CPArray array];

        if(parentFilter && parentType)
        {
            parentTypes = [];
            parentIter = parentFilter;

            while(parentIter != nil)
            {
                var parentDesc = [parentIter description];

                console.log("parentDesc excludedFilters ="); console.log([parentDesc excludeFilters]);

                [excludedFilterIds addObjectsFromArray:[parentDesc excludeFilters]];

                parentIter = [parentIter parentNode];
            }
        }

        console.log("excludedFilterIds = "); console.log(excludedFilterIds);

        var itemList = [CPArray arrayWithArray:[filterDescriptions allKeys]];
        for(var i=0; i < [excludedFilterIds count]; i++)
        {
            var excludedId = [excludedFilterIds objectAtIndex:i].toString();

            console.log("excludedId = "); console.log(excludedId);
            
            [itemList removeObject:excludedId];

            console.log("itemList ="); console.log(itemList);
        }

        if(itemList.length == 0)
            return null;

        for(var i=0; i < [itemList count]; i++)
        {
            var filterName = [[filterDescriptions objectForKey:[itemList objectAtIndex:i]] name];
            [m_FilterType addItemWithTitle:filterName];
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

    var filterDescriptions = [[filterManager filterDescriptions] allValues];

    var newFilterType = nil;

    for(var i=0; i < [filterDescriptions count]; i++)
    {
        var curDesc = [filterDescriptions objectAtIndex:i];

        if([curDesc name] == curSelFilterName)
        {
            newFilterType = [curDesc id];
            break;
        }
    }

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