@import <Foundation/CPObject.j>

@import "../FilterManager.j"

@implementation AddFilterPanel : CPPanel
{
    CPButton m_CancelButton;
    CPButton m_AddFilterButton;

    CPPopUpButton m_FilterType;

    CPTreeNode m_ParentFilter;
    id m_Delegate   @accessors(property=delegate);

    var m_ExclusionFilterMap;
    var m_FilterNameToTypeMap;
    var m_FilterTypeToNameMap;
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
        parentType = [filterManager typeFromFilter:parentFilter]

        m_ExclusionFilterMap = {
                               'county': ['county', 'school_district', 'house_district', 'senate_district'],
                               'school_district': ['county', 'school_district', 'house_district', 'senate_district'],
                               'house_district': ['county', 'school_district', 'house_district', 'senate_district', 'comcast_coverage'],
                               'senate_district' : ['county', 'school_district', 'house_district', 'senate_district', 'comcast_coverage'],
                               'comcast_coverage' : ['comcast_coverage', 'county', 'house_district', 'senate_district'],
                               'school_itc' : ['school_itc', 'organization'],
                               'ode_class' : ['ode_class', 'organization'],
                               'school' : ['school', 'organization'],
                               'connectivity_less' : ['connectivity_less', 'connectivity_greater', 'organization'],
                               'connectivity_greater' : ['connectivity_less', 'connectivity_greater', 'organization'],
                               'organization' : ['organization', 'school_itc', 'ode_class', 'school', 'connectivity_less', 'connectivity_greater']
                               }

        m_FilterNameToTypeMap = {
                                'County' : 'county',
                                'School District' : 'school_district',
                                'House District' : 'house_district',
                                'Senate District' : 'senate_district',
                                'School ITC' : 'school_itc',
                                'ODE Income Classification' : 'ode_class',
                                'Public School' : 'school',
                                'Organization' : 'organization',
                                'Connectivity Greater Than' : 'connectivity_greater',
                                'Connectivity Less Than' : 'connectivity_less',
                                'Comcast Coverage' : 'comcast_coverage'
                                }

        m_FilterTypeToNameMap = {}

        for(var key in m_FilterNameToTypeMap)
            m_FilterTypeToNameMap[m_FilterNameToTypeMap[key]] = key;

        var itemList = ['county', 'school_district', 'house_district', 'senate_district', 'organization', 'school_itc',
                        'ode_class', 'school', 'connectivity_greater', 'connectivity_less', 'comcast_coverage'];

        if(parentFilter && parentType)
        {
            parentTypes = [];
            parentIter = parentFilter;

            while(parentIter != nil)
            {
               parentType = [filterManager typeFromFilter:parentIter];

               var itemsExcluded = m_ExclusionFilterMap[parentType];

               console.log("Item List is " + itemList);
               console.log("Items excluded from parent type " + parentType + " items: " + itemsExcluded);

               for(var i=0; i < itemsExcluded.length; i++)
               {
                    itemListIndex = itemList.indexOf(itemsExcluded[i]);

                    if(itemListIndex != -1)
                        itemList.splice(itemListIndex, 1);
               }

               console.log("New Item List is " + itemList);

               parentIter = [parentIter parentNode];
            }
        }

        console.log("Final Item List is " + itemList);

        if(itemList.length == 0)
            return null;

        for(var i=0; i < itemList.length; i++)
        {
            [m_FilterType addItemWithTitle:m_FilterTypeToNameMap[itemList[i]]];
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

    var newFilterType = m_FilterNameToTypeMap[curSelFilterName];

    console.log("CurSelFilterName is " + curSelFilterName);
    console.log("New Filter Type is " + newFilterType);

    console.log("FilterNameToTypeMap is " + m_FilterNameToTypeMap);

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