@import <Foundation/CPObject.j>

@import "filters/CountyFilter.j"

@import "filters/CountyOrgIntersectionFilter.j"
@import "filters/SchoolDistrictOrgIntersectionFilter.j"

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

        [self addFilter:[[CountyFilter alloc] initWithName:"All Counties"] parent:nil];
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
    [self triggerFilters:m_UserFilters];
}

- (void)triggerFilters:(CPArray)filters
{
    [m_ProcessedFilters removeAllObjects];
    
    for(var i=0; i < [filters count]; i++)
    {
        curFilter = [filters objectAtIndex:i];

        if(![curFilter isLeaf])
        {
            [self triggerFilters:[curFilter childNodes]];
        }
        else if(![curFilter parentNode])
        {
            [m_ProcessedFilters addObject:curFilter];
            [curFilter trigger];
        }
        else
        {
            var parentFilter = [curFilter parentNode];

            if([parentFilter type] == "county")
            {
                if([curFilter type] == "org")
                {
                    //build org in county filter
                    var newFilter = [[CountyOrgIntersectionFilter alloc] initWithCountyFilter:parentFilter orgFilter:curFilter];
                    [m_ProcessedFilters addObject:newFilter];
                    [newFilter trigger];
                }

                [m_ProcessedFilters addObject:parentFilter];
                [parentFilter trigger];
            }
            else if([parentFilter type] == "school_district")
            {
                if([curFilter type] == "org")
                {
                    //build org in school_district filter
                    var newFilter = [[SchoolDistrictOrgIntersectionFilter alloc] initWithSchoolDistrictFilter:parentFilter orgFilter:curFilter];
                    [m_ProcessedFilters addObject:newFilter];
                    [newFilter trigger];
                }

                [m_ProcessedFilters addObject:parentFilter];
                [parentFilter trigger];
            }
            else if([parentFilter type] == "org")
            {
                if([curFilter type] == "county")
                {
                    //build org in county filter
                    var newFilter = [[CountyOrgIntersectionFilter alloc] initWithCountyFilter:curFilter orgFilter:parentFilter];
                    [m_ProcessedFilters addObject:newFilter];
                    [newFilter trigger];

                    [m_ProcessedFilters addObject:curFilter];
                    [curFilter trigger];
                 }
                else if([curFilter type] == "school_district")
                {
                    //build org in school_district filter
                    var newFilter = [[SchoolDistrictOrgIntersectionFilter alloc] initWithSchoolDistrictFilter:curFilter orgFilter:parentFilter];
                    [m_ProcessedFilters addObject:newFilter];
                    [newFilter trigger];
                    [m_ProcessedFilters addObject:curFilter];
                    [curFilter trigger];
                }
            }
        }
    }
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

    return [self processFilters:m_ProcessedFilters];
}


- (CPSet)processFilters:(CPArray)filters
{
    resultSet = [CPSet set];

    for(var i=0; i < [filters count]; i++)
    {
        curFilter = [filters objectAtIndex:i];

        resultSet = [resultSet setByAddingObjectsFromSet:[curFilter filter]];
    }

    return resultSet;
}

@end