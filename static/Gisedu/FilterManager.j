@import <Foundation/CPObject.j>

@import "GiseduFilter.j"

@import "GiseduFilterRequest.j"

var g_FilterManagerInstance = nil;

@implementation FilterManager : CPObject
{
    OverlayManager m_OverlayManager;

    CPArray m_UserFilters       @accessors(property=userFilters); //Filters that the user declares
    CPArray m_ProcessedFilters;                                   //Filters that the filter engine optimizes for

    id m_Delegate         @accessors(property=delegate);

    CPDictionary m_FilterMap    @accessors(property=filterMap);   //Maps Filter to Filter Type Name (ListFilter -> 'org', IntegerFilter -> 'mbit_less')

    var m_FilterRequestModifierMap;
    var m_FilterRequestBaseMap;
}

- (void)init
{
    self = [super init];

    if(self)
    {
        m_OverlayManager = [OverlayManager getInstance];
        m_UserFilters = [CPArray array];
        m_ProcessedFilters = [CPArray array];
        m_FilterMap = [CPDictionary dictionary];

        [self addFilter:[self createFilter:'county'] parent:nil];

        m_FilterRequestModifierMap = {
                                        'county' : "county",
                                        'house_district' : "house_district",
                                        'senate_district' : "senate_district",
                                        'school_district' : "school_district",
                                        'connectivity_less' : "broadband_less",
                                        'connectivity_greater' : "broadband_greater",
                                        'school_itc' : "itc",
                                        'ode_class' : "ode_class",
                                        'organization' : "organization_by_type",
                                        'school' : "school_by_type",
                                        'comcast_coverage' : "comcast",
                                    }

        m_FilterOptionsMap = {
                                'school' : ['school_itc', 'ode_class', 'connectivity_less', 'connectivity_greater'],
                                'school_district' : ['comcast_coverage']
                             }

        m_FilterRequestBaseMap = {
                                    'county' : "/filter/county_by_name=",
                                    'house_district' : "/filter/house_district=",
                                    'senate_district' : "/filter/senate_district=",
                                    'school_district' : "/filter/school_district=",
                                    'school' : "/filter/school_by_type=",
                                    'organization' : "/filter/organization_by_type="
                                }
    }

    return self;
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

- (CPTreeNode)createFilter:(CPString)type
 {
    var newFilter = nil;

    if(type == 'county' || type == 'school_district' || type == 'organization'
        || type == 'school' || type == 'school_itc' || type == 'ode_class'
        || type == 'house_district' || type == 'senate_district')
        newFilter = [[GiseduFilter alloc] initWithValue:'All'];
    else if(type == 'connectivity_less' || type == 'connectivity_greater')
        newFilter = [[GiseduFilter alloc] initWithValue:100];
    else if(type == 'comcast_coverage')
        newFilter = [[GiseduFilter alloc] initWithValue:YES];

    console.log("FilterManager Created New Filter: " + newFilter + " of Type: " + type);
    [m_FilterMap setObject:type forKey:newFilter];

    return newFilter;
 }

 - (CPString)typeFromFilter:(CPTreeNode)filter
 {
    return [m_FilterMap objectForKey:filter];
 }

- (void)addFilter:(CPTreeNode)filter parent:(CPTreeNode)parent
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

    console.log("Final Filter Chain = " + filterChain);

    var baseFilterItemList = ['county', 'house_district', 'senate_district', 'school_district', 'school', 'organization'];
    var keyFilterItemList = ['school', 'organization'];

    var keyFilterType = nil;
    var filterChainBuffer = [CPArray array];
    var filterRequestStrings = {}

    //Pop Item off FilterChain
    //Is the item a filter base?
        //Is the item the "key" filter (org or school)?
            //If so remember it in keyFilter variable
        //if so build the filter base
        //add to a list of filter base request strings
    //else: Is the item an option of a current filter base?
        //if so add to the filter base request string for that filter base
    //else:
        //Push back onto FilterChain
    //Remove the keyFilter from the filterBase list
    //Start with the keyFilter add the other filterbases onto it (concatenate them together)
    while(true)
    {
        var curFilter = [filterChain lastObject];
        [filterChain removeLastObject];

        console.log("Current Filter is " + curFilter);

        if(!curFilter)
            break;

        var curFilterType = [self typeFromFilter:curFilter];

        console.log("Current Filter Type is " + curFilterType);

        if(baseFilterItemList.indexOf(curFilterType) != -1)
        {
            //curFilter is a base for a filter query

            if(keyFilterItemList.indexOf(curFilterType) != -1)
            {
                //curFilter is a key base filter
                keyFilterType = curFilterType;
                filterRequestStrings[curFilterType] = "/" + m_FilterRequestModifierMap[curFilterType] + "=" + [curFilter value];

                console.log("Built KeyFilter Request String: " + filterRequestStrings[curFilterType]);
            }
            else
            {
                filterRequestStrings[curFilterType] = "/" + m_FilterRequestModifierMap[curFilterType] + "=" + [curFilter value];

                console.log("Built BaseFilter Request String: " + filterRequestStrings[curFilterType]);
            }

            [filterChain addObjectsFromArray:filterChainBuffer];
            [filterChainBuffer removeAllObjects];
        }
        else
        {
            var bNoBase = true;

            for(baseFilterType in filterRequestStrings)
            {
                if(baseFilterType in m_FilterOptionsMap)
                {
                    var filterOptions = m_FilterOptionsMap[baseFilterType];
                
                    console.log("filterOptions = " + filterOptions);

                    if(filterOptions.indexOf(curFilterType) != -1)
                    {
                        //add to the base filter
                        filterRequestStrings[baseFilterType] += ":" + m_FilterRequestModifierMap[curFilterType] + "=" + [curFilter value];

                        console.log("Updated BaseFilter Request String To: " + filterRequestStrings[curFilterType]);
                        bNoBase = false;
                    }
                }
            }

            if(bNoBase)
            {
                [filterChainBuffer addObject:curFilter];
            }
        }
    }

    var requestUrl = g_UrlPrefix + "/filter";

    if(keyFilterType in filterRequestStrings)
        requestUrl += filterRequestStrings[keyFilterType]

    for(filterString in filterRequestStrings)
    {
        if(filterRequestStrings[filterString] != filterRequestStrings[keyFilterType])
            requestUrl += filterRequestStrings[filterString];
    }

    console.log("Resulting Request URL is: " + requestUrl);

    return requestUrl;
}

- (void)_buildFilterChain:(id)filter withArray:(CPArray)filterChain
{
    if([filter parentNode])
        [self _buildFilterChain:[filter parentNode] withArray:filterChain];

    [filterChain addObject:filter];

    console.log("Filter Chain = " + filterChain);
}

- (id)_extractKeyFilter:(CPArray)filterChain
{
    for(var i=0; i < [filterChain count]; i++)
    {
        var curFilter = [filterChain objectAtIndex:i];
        var curFilterType = [self typeFromFilter:curFilter];

        if(curFilterType == "organization" || curFilterType == "school")
        {
            [filterChain removeObject:curFilter];

            return curFilter;
        }
    }
}

- (CPString)_buildFilterRequestModifier:(id)filter
{
    var filterType = [self typeFromFilter:filter];

    return m_FilterRequestModifierMap[filterType] + [filter value];
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