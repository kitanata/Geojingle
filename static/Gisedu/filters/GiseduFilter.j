@import <Foundation/CPObject.j>

///////////////////////////////////////////////////////////////////
//Class: GiseduFilter
//Purpose: A base class for the filtering system
///////////////////////////////////////////////////////////////////
@implementation GiseduFilter : CPObject
{

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