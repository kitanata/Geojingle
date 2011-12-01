@import "GiseduFilter.j"
@import "PointDisplayOptions.j"

/* CPTreeNode does not allow us to reassign a new object to the same node without
recreating the node. This gets around that."*/

@implementation GiseduPointFilter : GiseduFilter
{
    PointDisplayOptions m_DisplayOptions   @accessors(getter=displayOptions);
}

- (id)initWithValue:(id)value
{
    self = [super initWithValue:value];

    if(self)
    {
        m_DisplayOptions = [PointDisplayOptions defaultOptions];
    }

    return self;
}

@end
