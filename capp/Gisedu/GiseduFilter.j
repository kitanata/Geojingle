@import <AppKit/CPTreeNode.j>

/* CPTreeNode does not allow us to reassign a new object to the same node without
recreating the node. This gets around that."*/

@implementation GiseduFilter : CPTreeNode
{
    CPString m_FilterType           @accessors(property=type);
    id m_FilterValue                @accessors(property=value);
    CPString m_FilterRequestOption  @accessors(property=requestOption); //optional argument to request_modifier
    id m_FilterDescription          @accessors(property=description);

    BOOL m_bDirty                   @accessors(property=dirty);
}

- (id)initWithValue:(id)value
{
    self = [super initWithRepresentedObject:"Gisedu Filter"];

    if(self)
    {
        m_FilterValue = value;
        m_FilterRequestOption = "";

        m_bDirty = YES;
    }

    return self;
}

- (void)setDirty
{
    m_bDirty = YES;
}

- (void)enchantChildren
{
    var children = [self childNodes];

    //Do not refactor. This is correct. We to apply our properties to all our children.
    //THEN have our children apply their properties to their children. and so on...
    [self _enchantChildren:children];

    for(var i=0; i < [children count]; i++)
        [[children objectAtIndex:i] enchantChildren];
}

- (void)_enchantChildren:(CPArray)children
{
    for(var i=0; i < [children count]; i++)
    {
        var curChild = [children objectAtIndex:i];
        var curFilterType = [[curChild description] dataType];

        [curChild enchantFromFilter:self];

        [self _enchantChildren:[curChild childNodes]];
    }
}

- (void)enchantFromParents
{
    [self _enchantFromParents:[self parentNode]];
}

- (void)_enchantFromParents:(GiseduFilter)parentFilter
{
    //recurse to root then propegate down to this
    if([parentFilter parentNode])
        [self _enchantFromParents:[parentFilter parentNode]];

    [self enchantFromFilter:parentFilter];
}

- (void)enchantFromFilter:(GiseduFilter)filter { }

- (id)toJson
{
    json = {};
    json.type = m_FilterType
    json.value = m_FilterValue
    json.request_option = m_FilterRequestOption
    return json;
}

- (void)fromJson:(id)json
{
    m_FilterType = json.type;
    m_FilterValue = json.value;
    m_FilterRequestOption = json.request_option;
}

@end