@import "GiseduFilter.j"

/* CPTreeNode does not allow us to reassign a new object to the same node without
recreating the node. This gets around that."*/

@implementation GiseduPostFilter : GiseduFilter
{
    int m_ReduceFilterId                @accessors(property=reduceFilterId);
}

- (id)initWithValue:(id)value
{
    self = [super initWithValue:value];

    if(self)
    {
        m_ReduceFilterId = -1;
    }

    return self;
}

@end
