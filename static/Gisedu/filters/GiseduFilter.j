@import <AppKit/CPTreeNode.j>

///////////////////////////////////////////////////////////////////
//Class: GiseduFilter
//Purpose: A base class for the filtering system
///////////////////////////////////////////////////////////////////
@implementation GiseduFilter : CPTreeNode
{
    CPString m_szType @accessors(property=type);

    CPArray m_ObjectIds @accessors(property=objects);
}

- (id)init
{
    self = [super initWithRepresentedObject:"Filter"];

    if(self)
    {
        m_szType = "Gisedu Filter";
    }

    return self;
}

- (CPString)name
{
    return m_szType;
}

@end