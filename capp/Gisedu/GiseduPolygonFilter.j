@import "GiseduFilter.j"
@import "PolygonDisplayOptions.j"

/* CPTreeNode does not allow us to reassign a new object to the same node without
recreating the node. This gets around that."*/

@implementation GiseduPolygonFilter : GiseduFilter
{
    PolygonDisplayOptions m_DisplayOptions   @accessors(getter=displayOptions);
}

- (id)initWithValue:(id)value
{
    self = [super initWithValue:value];

    if(self)
    {
        m_DisplayOptions = [PolygonDisplayOptions defaultOptions];
    }

    return self;
}

- (void)enchantFromFilter:(GiseduFilter)filter
{
    var filterType = [[filter description] dataType];

    if(filterType == "POLYGON")
        [m_DisplayOptions enchantOptionsFrom:[filter displayOptions]];
    else if(filterType == "REDUCE")
        [m_DisplayOptions enchantOptionsFrom:[filter polygonDisplayOptions]];
}

- (id)toJson 
{
    json = [super toJson];
    json.display_options = [m_DisplayOptions rawOptions];
    return json;
}

- (void)fromJson:(id)json
{
    [super fromJson:json];
    [m_DisplayOptions enchantOptionsFromJson:json.display_options];
}

@end
