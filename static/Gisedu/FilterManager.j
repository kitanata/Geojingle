@import <Foundation/CPObject.j>

@import "filters/CountyFilter.j"

var g_FilterManagerInstance = nil;

@implementation FilterManager : CPObject
{
    OverlayManager m_OverlayManager;
    CPArray m_RootFilters @accessors(property=rootFilters);
}

- (void)init
{
    self = [super init];

    if(self)
    {
        m_OverlayManager = [OverlayManager getInstance];
        m_RootFilters = [CPArray array];

        [self addFilter:[[CountyFilter alloc] initWithName:"Default"] parent:nil];
    }

    return self;
}

- (BOOL)containsFilter:(GiseduFilter)filter
{
    if(!filter)
        return NO;

    return [self containsFilter:filter withNodes:m_RootFilters];
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
        [m_RootFilters addObject:filter];
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
            [m_RootFilters removeObject:filter];
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

- (CPSet)processFilters
{
    return [self processFilters:m_RootFilters];
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


//TODO: Below
// Each Set is a set of the type GiseduTypeIdPair (i.e. county/4 school/18)
// A GiseduTypeIdPair is the following JSON {"type":"County", "id":1}

- (CPSet)intersectFilterSet:(CPSet)firstSet withFilterSet:(CPSet)secondSet
{
    //based on the type of firstSet and type of SecondSet build a query for intersection
    //for example with "county/4" and "organization/18" they query would be "gisedu.ohio.gov/org/18/in_county/4"

    //As a dummy just unionize them TODO: Make this work correctly
    return [firstSet setByAddingObjectsFromSet:secondSet];
}

@end