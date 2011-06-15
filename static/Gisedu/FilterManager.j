@import <Foundation/CPObject.j>

@import "filters/CountyFilter.j"

var g_FilterManagerInstance = nil;

@implementation FilterManager : CPObject
{
    CPArray m_RootFilters @accessors(property=rootFilters);
}

- (void)init
{
    self = [super init];

    if(self)
    {
        m_RootFilters = [CPArray array];
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

@end