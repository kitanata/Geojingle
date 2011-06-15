@import <AppKit/CPTreeNode.j>

///////////////////////////////////////////////////////////////////
//Class: GiseduFilter
//Purpose: A base class for the filtering system
///////////////////////////////////////////////////////////////////
@implementation GiseduFilter : CPTreeNode
{
    CPString m_szType @accessors(property=type);
    CPString m_szName @accessors(property=name);
}

- (id)init
{
    self = [super initWithRepresentedObject:"Filter"];

    if(self)
    {
        m_szType = "Gisedu Filter";
        m_szName = "Gisedu Filter";
    }

    return self;
}

///////////////////////////////////////////////////////////////////
//Function: filter
//Purpose: Queries the server for a list of Type/ID pairs that meet
//          the descriptive requirements of this filter
//In:
//Return: CPSet - a set of Type/ID pairs
//Note: All deriving classes should override / implement this function
///////////////////////////////////////////////////////////////////
- (CPSet)filter
{

}

@end