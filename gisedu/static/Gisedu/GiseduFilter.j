@import <AppKit/CPTreeNode.j>

/* CPTreeNode does not allow us to reassign a new object to the same node without
recreating the node. This gets around that."*/

@implementation GiseduFilter : CPTreeNode
{
    CPString m_FilterType           @accessors(property=type);
    id m_FilterValue                @accessors(property=value);
    CPString m_FilterRequestOption  @accessors(property=requestOption); //optional argument to request_modifier
    id m_FilterDescription          @accessors(property=description);

    id m_DisplayOptions             @accessors(property=displayOptions); //regular javascript map
}

- (id)initWithValue:(id)value
{
    self = [super initWithRepresentedObject:"Gisedu Filter"];

    if(self)
    {
        m_FilterValue = value;
        m_FilterRequestOption = "";

        m_DisplayOptions = {
            "icon" : "circle",
            "iconColor" : "red",
            "strokeColor" : "#000000",
            "strokeOpacity" : 1.0,
            "strokeWeight" : 1.5,
            "fillColor" : "#000000",
            "fillOpacity" : 0.3,
            "radius" : 1000,
            "visible" : YES
        };
    }

    return self;
}

- (void)setDisplayOption:(CPString)option value:(id)value
{
    m_DisplayOptions[option] = value;
}

- (id)getDisplayOption:(CPString)option
{
    return m_DisplayOptions[option];
}

@end
