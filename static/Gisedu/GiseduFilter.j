@import <AppKit/CPTreeNode.j>

/* CPTreeNode does not allow us to reassign a new object to the same node without
recreating the node. This gets around that."*/

@implementation GiseduFilter : CPTreeNode
{
    CPString m_FilterType   @accessors(property=type);
    id m_FilterValue        @accessors(property=value);
    id m_DisplayOptions     @accessors(property=displayOptions); //regular javascript map
}

- (id)initWithValue:(id)value
{
    self = [super initWithRepresentedObject:"Gisedu Filter"];

    if(self)
        m_FilterValue = value;

    return self;
}

@end