@import <AppKit/CPTreeNode.j>

/* If you walk the filter tree from parent to child. Each path to a leaf is represented
   as a seperate filter chain. Each filter chain make's it's own request to the server
   for information regarding the types of overlays Gisedu should load onto the display.

   The filter chain holds an array of filters leading from parent to child, where m_Filters[0] is
   the non-null root filter and m_Filters[N] is the leaf of that tree. The FilterChain is responsible
   for building the filter request, handling the response, communicate with the Overlaymanager
   to load overlays. And for applying filter wide display options for each overlay associated
   with the filters in the filter chain.
   */

@implementation GiseduFilterChain : CPObject
{
    CPArray             m_Filters       @accessors(property=filters);
    
    GiseduFilterRequest m_Request;

    FilterManager m_FilterManager;

    id m_Delegate                       @accessors(property=delegate);
}

- (vid)init
{
    self = [super init];

    if(self)
    {
        m_Filters = [CPArray array];

        m_FilterManager = [FilterManager getInstance];
    }

    return self;
}

- (id)initWithRootFilter:(GiseduFilter)rootFilter
{
    self = [self init];

    if(self)
        [self addFilter:rootFilter];

    return self;
}

- (id)addFilter:(GiseduFilter)filter
{
    [m_Filters addObject:filter];
}

- (CPString)buildFilterRequest
{
    var filterChain = [m_Filters copy];

    var filterRequestModifiers = [m_FilterManager filterRequestModifiers];
    var filterOptionsMap = [m_FilterManager filterOptions];

    var baseFilterItemList = ['county', 'house_district', 'senate_district', 'school_district', 'school', 'organization', 'joint_voc_sd'];
    var keyFilterItemList = ['school', 'organization'];

    var keyFilterType = nil;
    var filterChainBuffer = [CPArray array];
    var filterRequestStrings = {}

    //Pop Item off FilterChain
    //Is the item a filter base?
        //Is the item the "key" filter (org or school)?
            //If so remember it in keyFilter variable
        //if so build the filter base
        //add to a list of filter base request strings
    //else: Is the item an option of a current filter base?
        //if so add to the filter base request string for that filter base
    //else:
        //Push back onto FilterChain
    //Remove the keyFilter from the filterBase list
    //Start with the keyFilter add the other filterbases onto it (concatenate them together)
    while(true)
    {
        var curFilter = [filterChain lastObject];
        [filterChain removeLastObject];

        console.log("Current Filter is " + curFilter);

        if(!curFilter)
            break;

        var curFilterType = [curFilter type];

        console.log("Current Filter Type is " + curFilterType);

        if(baseFilterItemList.indexOf(curFilterType) != -1)
        {
            //curFilter is a base for a filter query

            if(keyFilterItemList.indexOf(curFilterType) != -1)
            {
                //curFilter is a key base filter
                keyFilterType = curFilterType;
                filterRequestStrings[curFilterType] = "/" + filterRequestModifiers[curFilterType] + "=" + [curFilter value];

                console.log("Built KeyFilter Request String: " + filterRequestStrings[curFilterType]);
            }
            else
            {
                filterRequestStrings[curFilterType] = "/" + filterRequestModifiers[curFilterType] + "=" + [curFilter value];

                console.log("Built BaseFilter Request String: " + filterRequestStrings[curFilterType]);
            }

            [filterChain addObjectsFromArray:filterChainBuffer];
            [filterChainBuffer removeAllObjects];
        }
        else
        {
            var bNoBase = true;

            for(baseFilterType in filterRequestStrings)
            {
                if(baseFilterType in filterOptionsMap)
                {
                    var filterOptions = filterOptionsMap[baseFilterType];

                    console.log("filterOptions = " + filterOptions);

                    if(filterOptions.indexOf(curFilterType) != -1)
                    {
                        //add to the base filter
                        filterRequestStrings[baseFilterType] += ":" + filterRequestModifiers[curFilterType] + "=" + [curFilter value];

                        console.log("Updated BaseFilter Request String To: " + filterRequestStrings[curFilterType]);
                        bNoBase = false;
                    }
                }
            }

            if(bNoBase)
            {
                [filterChainBuffer addObject:curFilter];
            }
        }
    }

    var requestUrl = g_UrlPrefix + "/filter";

    if(keyFilterType in filterRequestStrings)
        requestUrl += filterRequestStrings[keyFilterType]

    for(filterString in filterRequestStrings)
    {
        if(filterRequestStrings[filterString] != filterRequestStrings[keyFilterType])
            requestUrl += filterRequestStrings[filterString];
    }

    console.log("Resulting Request URL is: " + requestUrl);

    return requestUrl;
}

- (void)sendFilterRequest
{
    var requestUrl = [self buildFilterRequest];

    if(requestUrl)
    {
        m_Request = [GiseduFilterRequest requestWithUrl:requestUrl];
        [m_Request setDelegate:self];
        [m_Request trigger];
    }
}

- (void)onFilterRequestSuccessful:(id)sender
{
    var resultSet = [sender resultSet];

    if(m_Delegate && [m_Delegate respondsToSelector:@selector(onFilterRequestSuccessful:)])
        [m_Delegate onFilterRequestSuccessful:[CPSet setWithArray:resultSet]];
}

+ (id)filterChain
{
    return [[GiseduFilterChain alloc] init];
}

+ (id)filterChainWithRootFilter:(GiseduFilter)rootFilter
{
    return [[GiseduFilterChain alloc] initWithRootFilter:rootFilter];
}

@end