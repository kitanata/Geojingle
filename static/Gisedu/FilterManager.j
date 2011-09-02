@import <Foundation/CPObject.j>

@import "GiseduFilter.j"

@import "GiseduFilterRequest.j"
@import "GiseduFilterChain.j"

var g_FilterManagerInstance = nil;

@implementation FilterManager : CPObject
{
    OverlayManager m_OverlayManager;

    CPArray m_UserFilters           @accessors(property=userFilters);   //Filters that the user declares
    CPArray m_FilterChains;                                             //Cached Filter Chains

    id m_Delegate                   @accessors(property=delegate);

    var m_FilterRequestModifierMap  @accessors(property=filterRequestModifiers);
    var m_FilterOptionsMap          @accessors(property=filterOptions);

    var m_ExclusionFilterMap        @accessors(getter=filterExclusionMap);
}

- (void)init
{
    self = [super init];

    if(self)
    {
        m_OverlayManager = [OverlayManager getInstance];
        m_UserFilters = [CPArray array];
        m_FilterChains = [CPArray array];

        [self addFilter:[self createFilter:'county'] parent:nil];

        m_FilterRequestModifierMap = {
                                        'county' : "county",
                                        'house_district' : "house_district",
                                        'senate_district' : "senate_district",
                                        'school_district' : "school_district",
                                        'joint_voc_sd' : "joint_voc_sd",
                                        'connectivity_less' : "broadband_less",
                                        'connectivity_greater' : "broadband_greater",
                                        'school_itc' : "itc",
                                        'ode_class' : "ode_class",
                                        'organization' : "organization_by_type",
                                        'school' : "school_by_type",
                                        'comcast_coverage' : "comcast",
                                        'atomic_learning' : "atomic_learning",
                                    }

        m_FilterOptionsMap = {
                                'school' : ['school_itc', 'ode_class', 'connectivity_less', 'connectivity_greater'],
                                'school_district' : ['comcast_coverage', 'atomic_learning'],
                                'joint_voc_sd' : ['atomic_learning']
                             }

        m_ExclusionFilterMap = {
                           'county': ['county', 'school_district', 'house_district', 'senate_district'],
                           'school_district': ['county', 'school_district', 'house_district', 'senate_district'],
                           'house_district': ['county', 'school_district', 'house_district', 'senate_district', 'comcast_coverage'],
                           'senate_district' : ['county', 'school_district', 'house_district', 'senate_district', 'comcast_coverage'],
                           'comcast_coverage' : ['comcast_coverage', 'county', 'house_district', 'senate_district'],
                           'school_itc' : ['school_itc', 'organization'],
                           'ode_class' : ['ode_class', 'organization'],
                           'school' : ['school', 'organization'],
                           'connectivity_less' : ['connectivity_less', 'connectivity_greater', 'organization'],
                           'connectivity_greater' : ['connectivity_less', 'connectivity_greater', 'organization'],
                           'organization' : ['organization', 'school_itc', 'ode_class', 'school', 'connectivity_less', 'connectivity_greater',
                                            'atomic_learning', 'joint_voc_sd'],
                           'atomic_learning' : ['county', 'house_district', 'senate_district', 'school_itc', 'ode_class', 'school', 'connectivity_less',
                                            'connectivity_greater', 'organization'],
                           'joint_voc_sd' : ['organization', 'school', 'school_itc', 'ode_class', 'connectivity_less', 'connectivity_greater']
                           }
    }

    return self;
}

- (id)pointFilterTypes
{
    return ['school', 'organization', 'joint_voc_sd'];
}

- (id)polygonalFilterTypes
{
    return ['county', 'school_district', 'house_district', 'senate_district'];
}

- (id)reduceFilterTypes
{
    return ['school_itc', 'ode_class', 'connectivity_greater', 'connectivity_less',
            'comcast_coverage', 'atomic_learning'];
}

- (id)baseFilterTypes
{
    var filterTypes = [];
    return filterTypes.concat([self pointFilterTypes], [self polygonalFilterTypes]);
}

- (id)allFilterTypes
{
    var filterTypes = [];
    return filterTypes.concat([self pointFilterTypes], [self polygonalFilterTypes], [self reduceFilterTypes]);
}

- (id)filterFlagMap
{
    return {    'county': YES, 'school_district': YES, 'house_district': YES, 'senate_district' : YES,
                'comcast_coverage' : YES, 'school_itc' : YES, 'ode_class' : YES, 'school' : YES,
                'connectivity_less' : YES, 'connectivity_greater' : YES, 'organization' : YES,
                'atomic_learning' : YES, 'joint_voc_sd' : YES }
}

- (id)filterNameToTypeMap
{
    return {
                'County' : 'county',
                'School District' : 'school_district',
                'House District' : 'house_district',
                'Senate District' : 'senate_district',
                'School ITC' : 'school_itc',
                'ODE Income Classification' : 'ode_class',
                'Public School' : 'school',
                'Organization' : 'organization',
                'Connectivity Greater Than' : 'connectivity_greater',
                'Connectivity Less Than' : 'connectivity_less',
                'Comcast Coverage' : 'comcast_coverage',
                'Atomic Learning Participant' : 'atomic_learning',
                'Joint Vocational School District' : 'joint_voc_sd'
    };
}

- (id)filterTypeToNameMap
{
    var filterNameMap = [self filterNameToTypeMap];
    var filterMap = {}

    for(var key in filterNameMap)
        filterMap[filterNameMap[key]] = key;

    return filterMap;
}

/*These are used for dialogs*/
- (id)listBasedFilterTypes
{
    return ['county', 'school_district', 'house_district', 'senate_district', 'joint_voc_sd',
                'school_itc', 'ode_class', 'organization', 'school'];
}

- (id)booleanFilterTypes
{
     return ['comcast_coverage', 'atomic_learning'];
}

- (BOOL)containsFilter:(CPTreeNode)filter
{
    if(!filter)
        return NO;

    return [self containsFilter:filter withNodes:m_UserFilters];
}

- (BOOL)containsFilter:(CPTreeNode)filter withNodes:(CPArray)nodes
{
    if([nodes indexOfObject:filter] != CPNotFound)
        return YES;

    for(var i=0; i < [nodes count]; i++)
    {
        if([self containsFilter:filter withNodes:[[nodes objectAtIndex:i] childNodes]])
        {
            return YES;
        }
    }

    return NO;
}

- (CPArray)filterChainsWithFilter:(GiseduFilter)filter
{
    var results = [CPArray array];

    for(var i=0; i < [m_FilterChains count]; i++)
    {
        var curChain = [m_FilterChains objectAtIndex:i];
        if([curChain containsFilter:filter])
            [results addObject:curChain];
    }

    return results;
}

- (CPTreeNode)createFilter:(CPString)type
 {
    var newFilter = nil;

    var listBasedFilterTypes = [self listBasedFilterTypes];
    var boolFilterTypes = [self booleanFilterTypes];

    if(listBasedFilterTypes.indexOf(type) != -1)
        newFilter = [[GiseduFilter alloc] initWithValue:'All'];
    else if(type == 'connectivity_less' || type == 'connectivity_greater')
        newFilter = [[GiseduFilter alloc] initWithValue:100];
    else if(boolFilterTypes.indexOf(type) != -1)
        newFilter = [[GiseduFilter alloc] initWithValue:YES];

    console.log("FilterManager Created New Filter: " + newFilter + " of Type: " + type);
    [newFilter setType:type];

    return newFilter;
 }

- (void)addFilter:(CPTreeNode)filter parent:(CPTreeNode)parent
{
    if(!parent)
    {
        [m_UserFilters addObject:filter];
    }
    else if([self containsFilter:parent])
    {
        [parent insertObject:filter inChildNodesAtIndex:0];
    }
}

- (void)deleteFilter:(CPTreeNode)filter
{
    if([self containsFilter:filter])
    {
        var parent = [filter parentNode];

        if(!parent)
        {
            [m_UserFilters removeObject:filter];
        }
        else
        {
            [parent removeObjectFromChildNodesAtIndex:[[parent childNodes] indexOfObject:filter]];
        }
    }
}

+ (FilterManager)getInstance
{
    if(g_FilterManagerInstance == nil)
    {
        g_FilterManagerInstance = [[FilterManager alloc] init];
    }

    return g_FilterManagerInstance;
}

- (void)triggerFilters
{
    [m_FilterChains removeAllObjects];
    [m_OverlayManager removeAllOverlaysFromMapView];

    [self _triggerFilters:m_UserFilters];
}

- (void)_triggerFilters:(CPArray)filters
{
    for(var i=0; i < [filters count]; i++)
    {
        curFilter = [filters objectAtIndex:i];
        console.log("triggerFilters curFilter is " + curFilter);

        if(![curFilter isLeaf])
        {
            console.log("curFilter is not a leaf");
            [self _triggerFilters:[curFilter childNodes]];
        }
        else//leaf and has a parent
        {
            console.log("Current Filter is leaf and has parent");

            var filterChain = [GiseduFilterChain filterChain];
            [self _buildFilterChain:curFilter withChain:filterChain];
            [filterChain setDelegate:m_Delegate];
            [m_FilterChains addObject:filterChain];

            [filterChain sendFilterRequest];
        }
    }
}

- (void)_buildFilterChain:(id)filter withChain:(GiseduFilterChain)filterChain
{
    if([filter parentNode])
        [self _buildFilterChain:[filter parentNode] withChain:filterChain];

    [filterChain addFilter:filter];

    console.log("Filter Chain = " + filterChain);
}

- (void)updateAllFilterChains
{
    for(var i=0; i < [m_FilterChains count]; i++)
    {
        var curChain = [m_FilterChains objectAtIndex:i];
        [curChain updateOverlays];
    }
}

- (id)toJson
{
    var filterJson = [];

    for(var i=0; i < [m_UserFilters count]; i++)
    {
        var curFilter = [m_UserFilters objectAtIndex:i];

        filterJson.push([self _buildFilterJson:curFilter]);
        //[{'type': theType, 'value': theValue, 'children' : [filter, filter, filter]}]
    }

    console.log(filterJson);

    return filterJson;
}

- (id) _buildFilterJson:(id)curFilter
{
    var curFilterType = [curFilter type];
    var curFilterValue = [curFilter value];
    var curFilterDisplayOptions = [curFilter displayOptions];

    var childNodes = [curFilter childNodes];

    var childJson = [];

    for(var i=0; i < [childNodes count]; i++)
    {
        childJson.push([self _buildFilterJson:[childNodes objectAtIndex:i]]);
    }

    return {"type" : curFilterType, "value" : curFilterValue, "display_options" : curFilterDisplayOptions, "children" : childJson};
}

- (void)fromJson:(id)jsonObject
{
    [m_UserFilters removeAllObjects];
    
    for(var i=0; i < jsonObject.length; i++)
    {
        var curJsonFilter = jsonObject[i];

        [self _buildFilterFromJson:curJsonFilter parent:nil];
    }

    console.log("New User Filters are " + m_UserFilters);
}

- (void)_buildFilterFromJson:(id)jsonFilter parent:(id)parentFilter
{
    var newFilter = [self createFilter:jsonFilter['type']];
    [newFilter setValue:jsonFilter['value']];
    [self addFilter:newFilter parent:parentFilter];

    var displayOptions = jsonFilter['display_options'];

    if(displayOptions)
        [newFilter setDisplayOptions:displayOptions];

    var children = jsonFilter['children'];

    for(var i=0; i < children.length; i++)
    {
        [self _buildFilterFromJson:children[i] parent:newFilter];
    }
}

@end