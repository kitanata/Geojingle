@import <AppKit/CPTreeNode.j>

///////////////////////////////////////////////////////////////////
//Class: GiseduFilter
//Purpose: A base class for the filtering system
///////////////////////////////////////////////////////////////////
@implementation GiseduFilter : CPTreeNode
{
}

- (id)init
{
    self = [super initWithRepresentedObject:"Filter"];

    return self;
}

@end