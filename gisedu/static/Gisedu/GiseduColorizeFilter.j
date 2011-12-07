@import "GiseduFilter.j"

/* CPTreeNode does not allow us to reassign a new object to the same node without
recreating the node. This gets around that."*/

@implementation GiseduColorizeFilter : GiseduFilter
{
    int m_ReduceFilterId                @accessors(property=reduceFilterId);

    CPColor m_MinimumColorValue         @accessors(property=minimumColor);
    CPColor m_MaximumColorValue         @accessors(property=maximumColor);
}

- (id)initWithValue:(id)value
{
    self = [super initWithValue:value];

    if(self)
    {
        m_ReduceFilterId = -1;

        m_MinimumColorValue = [CPColor whiteColor];
        m_MaximumColorValue = [CPColor blackColor];
    }

    return self;
}

@end
