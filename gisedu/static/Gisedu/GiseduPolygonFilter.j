@import "GiseduFilter.j"
@import "PolygonDisplayOptions.j"

/* CPTreeNode does not allow us to reassign a new object to the same node without
recreating the node. This gets around that."*/

@implementation GiseduPolygonFilter : GiseduFilter
{
    PolygonDisplayOptions m_DisplayOptions   @accessors(getter=displayOptions);
}

- (id)initWithValue:(id)value
{
    self = [super initWithValue:value];

    if(self)
    {
        m_DisplayOptions = [PolygonDisplayOptions defaultOptions];
    }

    return self;
}

@end
