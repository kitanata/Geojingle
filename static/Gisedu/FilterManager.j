@import <Foundation/CPObject.j>

@import "filters/CountyFilter.j"

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
    for(var i=0; i < [filters count]; i++)
    {
        curFilter = [filters objectAtIndex:i];

        if([curFilter isLeaf])
        {
            if([curFilter parentNode])
            {
                //Build Intersection Filter
            }
            else
            {
                //Trigger Unary Filter
                [curFilter trigger];
            }
        }
    }
}

- (void)onFilterLoaded:(id)filter
{
    if([self filtersAreFinished])
    {
        if([m_Delegate respondsToSelector:@selector(onFilterManagerFiltered:)])
            [m_Delegate onFilterManagerFiltered:[self processFilters]];
    }
}

- (BOOL)filtersAreFinished
{
    return [self filtersAreFinished:m_UserFilters];
}

- (BOOL)filtersAreFinished:(CPArray)filters
{
    for(var i=0; i < [filters count]; i++)
    {
        curFilter = [filters objectAtIndex:i];

        if(![curFilter finished])
            return NO;

        if(![self filtersAreFinished:[curFilter childNodes]])
            return NO;
    }

    return YES;
}

- (CPSet)processFilters
{
    return [self processFilters:m_UserFilters];
}


- (CPSet)processFilters:(CPArray)filters
{
    resultSet = [CPSet set];

    for(var i=0; i < [filters count]; i++)
    {
        curFilter = [filters objectAtIndex:i];

        if([curFilter parentNode])
            resultSet = [resultSet setByAddingObjectsFromSet:[[curFilter parentNode] intersect:[curFilter filter]]];
        else
            resultSet = [resultSet setByAddingObjectsFromSet:[curFilter filter]];
    }

    return resultSet;
}

@end