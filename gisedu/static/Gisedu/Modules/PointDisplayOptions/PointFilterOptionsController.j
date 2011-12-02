@import "PointOptionsController.j"
@import "/static/Gisedu/FilterManager.j"

@implementation PointFilterOptionsController : PointOptionsController
{
    FilterManager m_FilterManager;
    GiseduPointFilter m_FilterTarget     @accessors(property=filter);
}

- (id)initWithFilter:(GiseduPointFilter)filter
{
    if([[filter description] dataType] == "REDUCE")
        self = [super initWithOptions:[filter pointDisplayOptions]];
    else
        self = [super initWithOptions:[filter displayOptions]];

    if(self)
    {
        m_FilterManager = [FilterManager getInstance];
        m_FilterTarget = filter;
    }

    return self;
}

- (void)update
{
    var filterChains = [m_FilterManager filterChainsWithFilter:m_FilterTarget];

    for(var i=0; i < [filterChains count]; i++)
    {
        var curChain = [filterChains objectAtIndex:i];

        [curChain updateOverlays];
    }
}

+ (id)controllerWithFilter:(GiseduFilter)filter
{
    return [[PointFilterOptionsController alloc] initWithFilter:filter];
}

@end
