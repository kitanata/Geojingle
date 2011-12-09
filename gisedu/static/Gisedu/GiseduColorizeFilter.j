@import "GiseduPostFilter.j"

/* CPTreeNode does not allow us to reassign a new object to the same node without
recreating the node. This gets around that."*/

@implementation GiseduColorizeFilter : GiseduPostFilter
{
    CPColor m_MinimumColorValue         @accessors(property=minimumColor);
    CPColor m_MaximumColorValue         @accessors(property=maximumColor);
}

- (id)initWithValue:(id)value
{
    self = [super initWithValue:value];

    if(self)
    {
        m_MinimumColorValue = [CPColor whiteColor];
        m_MaximumColorValue = [CPColor blackColor];
    }

    return self;
}

@end
