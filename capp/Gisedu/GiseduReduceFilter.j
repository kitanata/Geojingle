@import "GiseduFilter.j"
@import "PointOverlay.j"
@import "PointDisplayOptions.j"
@import "PolygonDisplayOptions.j"

/* CPTreeNode does not allow us to reassign a new object to the same node without
recreating the node. This gets around that."*/

@implementation GiseduReduceFilter : GiseduFilter
{
    PointDisplayOptions m_PointDisplayOptions       @accessors(getter=pointDisplayOptions);
    PolygonDisplayOptions m_PolygonDisplayOptions   @accessors(getter=polygonDisplayOptions);
}

- (id)initWithValue:(id)value
{
    self = [super initWithValue:value];

    if(self)
    {
        m_PointDisplayOptions = [PointDisplayOptions defaultOptions];
        m_PolygonDisplayOptions = [PolygonDisplayOptions defaultOptions];
    }

    return self;
}

- (void)enchantFromFilter:(GiseduFilter)filter
{
    var filterType = [[filter description] dataType];

    if(filterType == "POINT")
        [m_PointDisplayOptions enchantOptionsFrom:[filter displayOptions]];
    else if(filterType == "POLYGON")
        [m_PolygonDisplayOptions enchantOptionsFrom:[filter displayOptions]];
    else if(filterType == "REDUCE")
    {
        [m_PointDisplayOptions enchantOptionsFrom:[filter pointDisplayOptions]];
        [m_PolygonDisplayOptions enchantOptionsFrom:[filter polygonDisplayOptions]];
    }
}

- (id)toJson 
{
    json = [super toJson];
    json.point_display_options = [m_PointDisplayOptions rawOptions];
    json.polygon_display_options = [m_PolygonDisplayOptions rawOptions];
    return json;
}

- (void)fromJson:(id)json
{
    [super fromJson:json];
    console.log("Json Display Options = "); console.log(json.point_display_options);
    [m_PointDisplayOptions enchantOptionsFromJson:json.point_display_options];
    [m_PolygonDisplayOptions enchantOptionsFromJson:json.polygon_display_options];
}

@end
