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
    return {
        "type" : m_FilterType,
        "value" : m_FilterValue,
        "request_option" : m_FilterRequestOption,
        "point_display_options" : [m_PointDisplayOptions rawOptions],
        "polygon_display_options" : [m_PolygonDisplayOptions rawOptions]
    };
}

@end
