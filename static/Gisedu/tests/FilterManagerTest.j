@import <Foundation/CPObject.j>

@import "../FilterManager.j"
@import "../filters/CountyFilter.j"

@implementation FilterManagerTest : OJTestCase

- (void)testInitGiseduFilter
{
    filter = [[GiseduFilter alloc] init];

    [self assertNotNull:filter];
    //this will be null if the init method is changed.
    [self assertNotNull:[filter childNodes]];
}

- (void)testGetInstance
{
    instance = [FilterManager getInstance];

    [self assertNotNull:instance];
}

- (void)testFilterManagerInit
{
    instance = [[FilterManager alloc] init];

    [self assertNotNull:[instance rootFilters]];
}

- (void)testAddFilterNilParent_CountyFilter
{
    instance = [[FilterManager alloc] init];

    countyFilter = [[CountyFilter alloc] initWithName:"Test"];

    [instance addFilter:countyFilter parent:nil];

    [self assert:1 equals:[[instance rootFilters] count]];
}

- (void)testAddFilterValidParent_CountyFilter
{
    instance = [[FilterManager alloc] init];

    countyFilterParent = [[CountyFilter alloc] initWithName:"Parent"];
    countyFilterChild = [[CountyFilter alloc] initWithName:"Child"];

    [instance addFilter:countyFilterParent parent:nil];
    [instance addFilter:countyFilterChild parent:countyFilterParent];

    [self assert:1 equals:[[instance rootFilters] count]];
    [self assert:1 equals:[[countyFilterParent childNodes] count]];
}

- (void)testDeleteFilterNilParent_CountyFilter
{
    instance = [[FilterManager alloc] init];

    countyFilter = [[CountyFilter alloc] initWithName:"Test"];

    [instance deleteFilter:countyFilter];

    [self assert:0 equals:[[instance rootFilters] count]];
}

- (void)testDeleteFilterValidParent_CountyFilter
{
    instance = [[FilterManager alloc] init];

    countyFilterParent = [[CountyFilter alloc] initWithName:"Parent"];
    countyFilterChild = [[CountyFilter alloc] initWithName:"Child"];

    [instance addFilter:countyFilterParent parent:nil];
    [instance addFilter:countyFilterChild parent:countyFilterParent];

    [instance deleteFilter:countyFilterChild];

    [self assert:1 equals:[[instance rootFilters] count]];
    [self assert:0 equals:[[countyFilterParent childNodes] count]];
}

- (void)testHasFilterWithNil
{
    instance = [[FilterManager alloc] init];

    [self assert:NO equals:[instance containsFilter:nil]];
}

- (void)testHasFilterWithInvalidRoot
{
    instance = [[FilterManager alloc] init];

    countyFilter = [[CountyFilter alloc] initWithName:"Test"];

    [self assert:NO equals:[instance containsFilter:countyFilter]];
}

- (void)testContainsFilterWithValidRoot
{
    instance = [[FilterManager alloc] init];

    countyFilter = [[CountyFilter alloc] initWithName:"Test"];

    [instance addFilter:countyFilter parent:nil];
    [self assert:YES equals:[instance containsFilter:countyFilter]];
}

- (void)testContainsFilterWithInvalidChild
{
    instance = [[FilterManager alloc] init];

    countyFilterParent = [[CountyFilter alloc] initWithName:"Parent"];
    countyFilterChild = [[CountyFilter alloc] initWithName:"Child"];

    [instance addFilter:countyFilterParent parent:nil];

    [self assert:NO equals:[instance containsFilter:countyFilterChild]];
}

- (void)testContainsFilterWithValidChild
{
    instance = [[FilterManager alloc] init];

    countyFilterParent = [[CountyFilter alloc] initWithName:"Parent"];
    countyFilterChild = [[CountyFilter alloc] initWithName:"Child"];

    [instance addFilter:countyFilterParent parent:nil];
    [instance addFilter:countyFilterChild parent:countyFilterParent];

    [self assert:YES equals:[instance containsFilter:countyFilterChild]];
}

@end