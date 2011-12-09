@import "GiseduPostFilter.j"

/* CPTreeNode does not allow us to reassign a new object to the same node without
recreating the node. This gets around that."*/

@implementation GiseduScaleFilter : GiseduPostFilter
{
    int m_MinimumScale                  @accessors(property=minimumScale);
    int m_MaximumScale                  @accessors(property=maximumScale);
}

- (id)initWithValue:(id)value
{
    self = [super initWithValue:value];

    if(self)
    {
        m_MinimumScale = 1000;
        m_MaximumScale= 1000;
    }

    return self;
}

@end
