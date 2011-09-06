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
    CPArray             m_Filters              @accessors(property=filters);
    CPArray             m_DataTypes;           //m_OverlayIds Keys
    CPDictionary        m_OverlayIds;          //dictionary of list {'org' : [1,2,3,4,], 'school' : [5,6,7,8]};
    
    GiseduFilterRequest m_Request;

    FilterManager m_FilterManager;
    OverlayManager m_OverlayManager;

    var m_PointDataTypes;
    var m_PolygonDataTypes;
    
    id m_Delegate                       @accessors(property=delegate);
}

- (vid)init
{
    self = [super init];

    if(self)
    {
        m_Filters = [CPArray array];
        m_OverlayIds = [CPDictionary dictionary];

        m_FilterManager = [FilterManager getInstance];
        m_OverlayManager = [OverlayManager getInstance];

        m_PointDataTypes = [m_FilterManager pointFilterTypes];
        m_PolygonDataTypes = [m_FilterManager polygonalFilterTypes]; 
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

- (BOOL)containsFilter:(GiseduFilter)filter
{
    for(var i=0; i < [m_Filters count]; i++)
    {
        if([m_Filters objectAtIndex:i] == filter)
            return YES;
    }

    return NO;
}

- (CPString)buildFilterRequest
{
    var filterChain = [m_Filters copy];

    var filterRequestModifiers = [m_FilterManager filterRequestModifiers];
    var filterOptionsMap = [m_FilterManager filterOptions];

    var baseFilterItemList = [m_FilterManager baseFilterTypes];
    var keyFilterItemList = [m_FilterManager pointFilterTypes];

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
    var filterResult = [CPSet setWithArray:[sender resultSet]]; //to remove duplicates dummy. Array->Set->Array
    var resultSet = [filterResult allObjects];

    seps = [CPCharacterSet characterSetWithCharactersInString:":"];

    for(var i=0; i < [resultSet count]; i++)
    {
        typeIdPair = [resultSet objectAtIndex:i];
        items = [typeIdPair componentsSeparatedByCharactersInSet:seps];

        itemType = [items objectAtIndex:0];
        itemId = [items objectAtIndex:1];

        if(![m_OverlayIds objectForKey:itemType])
            [m_OverlayIds setObject:[CPArray array] forKey:itemType];

        [[m_OverlayIds objectForKey:itemType] addObject:itemId];
    }

    m_DataTypes = [m_OverlayIds allKeys];
    [self updateOverlays];

    if(m_Delegate && [m_Delegate respondsToSelector:@selector(onFilterRequestProcessed:)])
        [m_Delegate onFilterRequestProcessed:self];
}

- (void)updateOverlays
{
    var overlayOptions = {}

    for(var i=0; i < [m_Filters count]; i++)
    {
        var curFilter = [m_Filters objectAtIndex:i];
        var curFilterType = [curFilter type];

        overlayOptions[curFilterType] = [curFilter displayOptions];
    }

    for(var i=0; i < [m_DataTypes count]; i++)
    {
        var curType = [m_DataTypes objectAtIndex:i];
        var curOptions = overlayOptions[curType];
        var curIds = [m_OverlayIds objectForKey:curType];

        for(var j=0; j < [curIds count]; j++)
        {
            var curItemId = [curIds objectAtIndex:j];
            var dataObj = [m_OverlayManager getOverlayObject:curType objId:curItemId];

            if(m_PointDataTypes.indexOf(curType) != -1)
            {
                var overlay = [dataObj overlay];

                if(overlay)
                {
                    [overlay setDisplayOptions:curOptions];

                    if(![overlay markerValid])
                    {
                        [overlay removeFromMapView];
                        [overlay createGoogleMarker];
                    }

                    [overlay updateGoogleMarker];
                }
                else
                {
                    [m_OverlayManager loadPointOverlay:curType withId:curItemId withDisplayOptions:curOptions];
                }

            }
            else if(m_PolygonDataTypes.indexOf(curType) != -1)
            {
                var overlay = dataObj;

                if(overlay)
                {
                    [overlay setDisplayOptions:curOptions];
                    [overlay setDisplayOption:"visible" value:YES];

                    [overlay updateGooglePolygon];
                }
                else
                {
                    [m_OverlayManager loadPolygonOverlay:curType withId:curItemId withDisplayOptions:curOptions];
                }
            }
        }
    }
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