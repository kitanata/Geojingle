@import <Foundation/CPObject.j>

@import "GiseduFilter.j"
@import "GiseduFilterDescription.j"
@import "GiseduFilterRequest.j"
@import "GiseduFilterChain.j"

var g_FilterManagerInstance = nil;

@implementation FilterManager : CPObject
{
    OverlayManager m_OverlayManager;

    CPArray m_UserFilters           @accessors(property=userFilters);   //Filters that the user declares
    CPArray m_FilterChains;                                             //Cached Filter Chains

    id m_Delegate                       @accessors(property=delegate);

    CPDictionary m_FilterDescriptions   @accessors(getter=filterDescriptions);

    CPURLConnection m_FilterDescriptionConn;
}

- (void)init
{
    self = [super init];

    if(self)
    {
        m_OverlayManager = [OverlayManager getInstance];
        m_UserFilters = [CPArray array];
        m_FilterChains = [CPArray array];

        m_FilterDescriptions = [CPDictionary dictionary];

        //[self addFilter:[self createFilter:'county'] parent:nil];
    }

    return self;
}

- (void)loadFilterDescriptions
{
    m_FilterDescriptionConn = [CPURLConnection connectionWithRequest:[CPURLRequest requestWithURL:g_UrlPrefix + "/filter_list"] delegate:self];
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError
{
    if (aConnection == m_FilterDescriptionConn)
    {
        alert('Could not load filter list from server! ' + anError);
        m_FilterListConnection = nil;
    }
    else
    {
        alert('Save failed! ' + anError);
    }
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)aData
{
    if (aConnection == m_FilterDescriptionConn)
    {
        var aData = aData.replace('while(1);', '');

        filterList = JSON.parse(aData);

        for(var filterId in filterList)
        {
            var newDescription = [[GiseduFilterDescription alloc] init];

            [newDescription fromJson:filterList[filterId]];

            [m_FilterDescriptions setObject:newDescription forKey:filterId];
        }

        if(m_Delegate && [m_Delegate respondsToSelector:@selector(onFilterDescriptionsLoaded)])
                [m_Delegate onFilterDescriptionsLoaded];

        console.log(filterList);
    }

    console.log("Finished loading filter list");
}

- (id)filterFlagMap
{
    var flagMap = {};
    var allFilters = [[self filterDescriptions] allKeys];

    for(var i=0; i < [allFilters count]; i++)
    {
        flagMap[[allFilters objectAtIndex:i]] = YES;
    }

    return flagMap;
}

- (BOOL)containsFilter:(CPTreeNode)filter
{
    if(!filter)
        return NO;

    return [self containsFilter:filter withNodes:m_UserFilters];
}

- (BOOL)containsFilter:(CPTreeNode)filter withNodes:(CPArray)nodes
{
    if([nodes indexOfObject:filter] != CPNotFound)
        return YES;

    for(var i=0; i < [nodes count]; i++)
    {
        if([self containsFilter:filter withNodes:[[nodes objectAtIndex:i] childNodes]])
        {
            return YES;
        }
    }

    return NO;
}

- (CPArray)filterChainsWithFilter:(GiseduFilter)filter
{
    var results = [CPArray array];

    for(var i=0; i < [m_FilterChains count]; i++)
    {
        var curChain = [m_FilterChains objectAtIndex:i];
        if([curChain containsFilter:filter])
            [results addObject:curChain];
    }

    return results;
}

- (CPTreeNode)createFilter:(CPString)type
{
    console.log("FilterManager::createFilter called");
    var newFilter = nil;
    var filterDesc = [m_FilterDescriptions objectForKey:type];

    if([filterDesc filterType] == "LIST")
        newFilter = [[GiseduFilter alloc] initWithValue:'All'];
    else if([filterDesc filterType] == "DICT")
        newFilter = [[GiseduFilter alloc] initWithValue:'All'];
    else if([filterDesc filterType] == "INTEGER")
        newFilter = [[GiseduFilter alloc] initWithValue:'All'];
    else if([filterDesc filterType] == "CHAR")
        newFilter = [[GiseduFilter alloc] initWithValue:'All'];
    else if([filterDesc filterType] == "BOOL")
        newFilter = [[GiseduFilter alloc] initWithValue:YES];

    console.log("FilterManager Created New Filter: " + newFilter + " of Type: " + type);
    [newFilter setType:type];
    [newFilter setDescription:filterDesc];

    return newFilter;
}

- (void)addFilter:(CPTreeNode)filter parent:(CPTreeNode)parent
{
    console.log("Adding Filter = "); console.log(filter);
    
    if(!parent)
    {
        [m_UserFilters addObject:filter];
    }
    else if([self containsFilter:parent])
    {
        [parent insertObject:filter inChildNodesAtIndex:0];
    }
}

- (void)deleteFilter:(CPTreeNode)filter
{
    if([self containsFilter:filter])
    {
        var parent = [filter parentNode];

        if(!parent)
        {
            [m_UserFilters removeObject:filter];
        }
        else
        {
            [parent removeObjectFromChildNodesAtIndex:[[parent childNodes] indexOfObject:filter]];
        }
    }
}

+ (FilterManager)getInstance
{
    if(g_FilterManagerInstance == nil)
    {
        g_FilterManagerInstance = [[FilterManager alloc] init];
    }

    return g_FilterManagerInstance;
}

- (void)triggerFilters
{
    [m_FilterChains removeAllObjects];
    [m_OverlayManager removeAllOverlaysFromMapView];

    [self _triggerFilters:m_UserFilters];
}

- (void)_triggerFilters:(CPArray)filters
{
    console.log("Trigger Filters Called");

    console.log("Filters count = "); console.log([filters count]);

    console.log("Filters = "); console.log(filters);

    console.log("Filters at 0 = "); console.log([filters objectAtIndex:0]);
    
    for(var i=0; i < [filters count]; i++)
    {
        var curFilter = [filters objectAtIndex:i];
        console.log("triggerFilters curFilter = "); console.log(curFilter);

        if(![curFilter isLeaf])
        {
            console.log("curFilter is not a leaf");
            [self _triggerFilters:[curFilter childNodes]];
        }
        else//leaf and has a parent
        {
            console.log("Current Filter is leaf and has parent");

            var filterChain = [GiseduFilterChain filterChain];
            [self _buildFilterChain:curFilter withChain:filterChain];
            [filterChain setDelegate:m_Delegate];
            [m_FilterChains addObject:filterChain];

            [filterChain sendFilterRequest];
        }
    }
}

- (void)_buildFilterChain:(id)filter withChain:(GiseduFilterChain)filterChain
{
    if([filter parentNode])
        [self _buildFilterChain:[filter parentNode] withChain:filterChain];

    [filterChain addFilter:filter];

    console.log("Filter Chain = " + filterChain);
}

- (void)updateAllFilterChains
{
    for(var i=0; i < [m_FilterChains count]; i++)
    {
        var curChain = [m_FilterChains objectAtIndex:i];
        [curChain updateOverlays];
    }
}

- (id)toJson
{
    var filterJson = [];

    for(var i=0; i < [m_UserFilters count]; i++)
    {
        var curFilter = [m_UserFilters objectAtIndex:i];

        filterJson.push([self _buildFilterJson:curFilter]);
        //[{'type': theType, 'value': theValue, 'children' : [filter, filter, filter]}]
    }

    console.log(filterJson);

    return filterJson;
}

- (id) _buildFilterJson:(id)curFilter
{
    var curFilterType = [curFilter type];
    var curFilterValue = [curFilter value];
    var curFilterDisplayOptions = [curFilter displayOptions];

    var childNodes = [curFilter childNodes];

    var childJson = [];

    for(var i=0; i < [childNodes count]; i++)
    {
        childJson.push([self _buildFilterJson:[childNodes objectAtIndex:i]]);
    }

    return {"type" : curFilterType, "value" : curFilterValue, "display_options" : curFilterDisplayOptions, "children" : childJson};
}

- (void)fromJson:(id)jsonObject
{
    [m_UserFilters removeAllObjects];

    for(var i=0; i < jsonObject.length; i++)
    {
        var curJsonFilter = jsonObject[i];

        [self _buildFilterFromJson:curJsonFilter parent:nil];
    }

    console.log("New User Filters are " + m_UserFilters);
}

- (void)_buildFilterFromJson:(id)jsonFilter parent:(id)parentFilter
{
    var newFilter = [self createFilter:jsonFilter['type']];
    [newFilter setValue:jsonFilter['value']];
    [self addFilter:newFilter parent:parentFilter];

    var displayOptions = jsonFilter['display_options'];

    if(displayOptions)
        [newFilter setDisplayOptions:displayOptions];

    var children = jsonFilter['children'];

    for(var i=0; i < children.length; i++)
    {
        [self _buildFilterFromJson:children[i] parent:newFilter];
    }
}

@end