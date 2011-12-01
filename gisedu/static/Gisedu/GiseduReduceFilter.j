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
        m_PointDisplayOptions = [PointDisplayOptions displayOptions];
        m_PolygonDisplayOptions = [PolygonDisplayOptions displayOptions];
    }

    return self;
}

@end
