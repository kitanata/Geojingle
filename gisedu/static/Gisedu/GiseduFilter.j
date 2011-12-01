@import <AppKit/CPTreeNode.j>

/* CPTreeNode does not allow us to reassign a new object to the same node without
recreating the node. This gets around that."*/

@implementation GiseduFilter : CPTreeNode
{
    CPString m_FilterType           @accessors(property=type);
    id m_FilterValue                @accessors(property=value);
    CPString m_FilterRequestOption  @accessors(property=requestOption); //optional argument to request_modifier
    id m_FilterDescription          @accessors(property=description);
}

- (id)initWithValue:(id)value
{
    self = [super initWithRepresentedObject:"Gisedu Filter"];

    if(self)
    {
        m_FilterValue = value;
        m_FilterRequestOption = "";
    }

    return self;
}

@end
