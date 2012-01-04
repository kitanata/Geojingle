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

- (id)toJson 
{
    json = [super toJson];
    json.min_scale = m_MinimumScale;
    json.max_scale = m_MaximumScale;
    return json;
}

- (void)fromJson:(id)json
{
    [super fromJson:json];

    m_MinimumScale = json.min_scale;
    m_MaximumScale = json.max_scale;
}

@end
