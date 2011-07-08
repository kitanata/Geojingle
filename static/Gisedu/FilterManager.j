@import <Foundation/CPObject.j>

@import "filters/CountyFilter.j"

@import "filters/GiseduFilterRequest.j"

var g_FilterManagerInstance = nil;

@implementation FilterManager : CPObject
{
    OverlayManager m_OverlayManager;

    CPArray m_UserFilters       @accessors(property=userFilters); //Filters that the user declares
    CPArray m_ProcessedFilters;                                   //Filters that the filter engine optimizes for

    id m_Delegate         @accessors(property=delegate);
}

- (void)init
{
    self = [super init];

    if(self)
    {
        m_OverlayManager = [OverlayManager getInstance];
        m_UserFilters = [CPArray array];
        m_ProcessedFilters = [CPArray array];

        [self addFilter:[[CountyFilter alloc] init] parent:nil];
    }

    return self;
}

- (BOOL)containsFilter:(GiseduFilter)filter
{
    if(!filter)
        return NO;

    return [self containsFilter:filter withNodes:m_UserFilters];
}

- (BOOL)containsFilter:(GiseduFilter)filter withNodes:(CPArray)nodes
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

- (void)addFilter:(GiseduFilter)filter parent:(GiseduFilter)parent
{
    if(!parent)
    {
        [m_UserFilters addObject:filter];
    }
    else if([self containsFilter:parent])
    {
        [parent insertObject:filter inChildNodesAtIndex:0];
    }
}

- (void)deleteFilter:(GiseduFilter)filter
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
    [m_ProcessedFilters removeAllObjects];
    [m_OverlayManager removeAllOverlaysFromMapView];

    [self _triggerFilters:m_UserFilters];
}

- (void)_triggerFilters:(CPArray)filters
{
    for(var i=0; i < [filters count]; i++)
    {
        curFilter = [filters objectAtIndex:i];
        console.log("triggerFilters curFilter is " + curFilter);

        if(![curFilter isLeaf])
        {
            console.log("curFilter is not a leaf");
            [self _triggerFilters:[curFilter childNodes]];
        }
        else if(![curFilter parentNode])
        {
            console.log("curFilter is a root filter without children");

            if([curFilter type] == "county")
                url = "http://127.0.0.1:8000/filter/county_by_name:" + [curFilter county];
            else if([curFilter type] == "school_district")
                url = "http://127.0.0.1:8000/filter/school_district_by_name:" + [curFilter schoolDistrict];
            else if([curFilter type] == "school")
                url = "http://127.0.0.1:8000/filter/school_by_type:" + [curFilter schoolType];
            else if([curFilter type] == "org")
                url = "http://127.0.0.1:8000/filter/organization_by_type:" + [curFilter organizationType];

            if(url)
            {
                var newFilterRequest = [GiseduFilterRequest requestWithUrl:url];
                [m_ProcessedFilters addObject:newFilterRequest];
                [newFilterRequest trigger];
            }
        }
        else//leaf and has a parent
        {
            console.log("Current Filter is leaf and has parent");
            var requestUrl = [self _buildRequestUrlFromFilter:curFilter];

            if(requestUrl)
            {
                var newFilterRequest = [GiseduFilterRequest requestWithUrl:requestUrl];
                [m_ProcessedFilters addObject:newFilterRequest];
                [newFilterRequest trigger];
            }
        }
    }
}

- (CPString)_buildRequestUrlFromFilter:(id)leaf
{
    console.log("Building Request URL");
    
    //First build the filter chain (leaf to parent)
    var filterChain = [CPArray array];
    [self _buildFilterChain:leaf withArray:filterChain];

    console.log(filterChain);

    //Find the "key" filter (org or school)
    var keyFilter = [self _extractKeyFilter:filterChain];
    var keyFilterRequest = [self _buildKeyFilterRequest:keyFilter];

    console.log("The Key Filter is " + keyFilter);
    console.log("The Rest of the Filters are " + filterChain);

    var requestUrl = "http://127.0.0.1:8000/filter" + keyFilterRequest;

    for(var i=0; i < [filterChain count]; i++)
    {
        var curFilter = [filterChain objectAtIndex:i];
        requestUrl += [self _buildFilterRequestModifier:curFilter];
    }

    console.log("Resulting Request URL is: " + requestUrl);

    return requestUrl;
}

- (void)_buildFilterChain:(id)filter withArray:(CPArray)filterChain
{
    if([filter parentNode])
        [self _buildFilterChain:[filter parentNode] withArray:filterChain];

    [filterChain addObject:filter];
}

- (id)_extractKeyFilter:(CPArray)filterChain
{
    for(var i=0; i < [filterChain count]; i++)
    {
        var curFilter = [filterChain objectAtIndex:i];

        if([curFilter type] == "org" || [curFilter type] == "school")
        {
            [filterChain removeObject:curFilter];

            return curFilter;
        }
    }
}

- (CPString)_buildKeyFilterRequest:(id)keyFilter
{
    if([keyFilter type] == "org")
        return "/organization_by_type:" + [keyFilter organizationType];
    else if([keyFilter type] == "school")
        return "/school_by_type:" + [keyFilter schoolType];
}

- (CPString)_buildFilterRequestModifier:(id)filter
{
    if([filter type] == "county")
        return "/in_county:" + [filter county];
    else if([filter type] == "school_district")
        return "/in_school_district:" + [filter schoolDistrict];
}

- (void)onFilterLoaded:(id)filter
{
    console.log("onFilterLoaded called");

    if([self filtersAreFinished])
    {
        if([m_Delegate respondsToSelector:@selector(onFilterManagerFiltered:)])
            [m_Delegate onFilterManagerFiltered:[self processFilters]];
    }
}

- (BOOL)filtersAreFinished
{
    return [self filtersAreFinished:m_ProcessedFilters];
}

- (BOOL)filtersAreFinished:(CPArray)filters
{
    for(var i=0; i < [filters count]; i++)
    {
        curFilter = [filters objectAtIndex:i];

        console.log("FiltersAreFinished curFilter is " + curFilter);

        if(![curFilter finished])
            return NO;
    }

    return YES;
}

- (CPSet)processFilters
{
    console.log(m_ProcessedFilters);

    return [self _processFilters:m_ProcessedFilters];
}


- (CPSet)_processFilters:(CPArray)filters
{
    resultSet = [CPSet set];

    for(var i=0; i < [filters count]; i++)
    {
        curFilter = [filters objectAtIndex:i];

        resultSet = [resultSet setByAddingObjectsFromArray:[curFilter resultSet]];
    }

    return resultSet;
}

@end