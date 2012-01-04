@import "PolygonOptionsController.j"
@import "../../FilterManager.j"

@implementation PolygonFilterOptionsController : PolygonOptionsController
{
    FilterManager m_FilterManager;
    GiseduFilter m_FilterTarget     @accessors(property=filter);
}

- (id)initWithFilter:(GiseduPolygonFilter)filter
{
    if([[filter description] dataType] == "REDUCE")
        self = [super initWithOptions:[filter polygonDisplayOptions]];
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
    return [[PolygonFilterOptionsController alloc] initWithFilter:filter];
}

@end
