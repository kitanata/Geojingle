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

- (id)toJson 
{
    json = [super toJson];
    json.min_color = [m_MinimumColorValue components];
    json.max_color = [m_MaximumColorValue components];
    return json;
}

- (void)fromJson:(id)json
{
    [super fromJson:json];

    m_MinimumColorValue = [CPColor colorWithCalibratedRed:json.min_color[0] green:json.min_color[1]
        blue:json.min_color[2] alpha:json.min_color[3]];
    m_MaximumColorValue = [CPColor colorWithCalibratedRed:json.max_color[0] green:json.max_color[1]
        blue:json.max_color[2] alpha:json.max_color[3]];
}

@end
