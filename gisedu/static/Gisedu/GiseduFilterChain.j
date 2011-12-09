@import <AppKit/CPTreeNode.j>
@import "PointDisplayOptions.j"
@import "PolygonDisplayOptions.j"

@import "FileKit/JsonRequest.j"

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

    var m_LoadPointOverlayList;
    var m_LoadPolygonOverlayList;

    var m_PointOverlayIds;  //The id's under the "control" of this filter chain
    var m_PolygonOverlayIds;//ditto. These are used for post processing filters.

    CPArray m_OverlayListLoaders;
    var m_PostProcessingRequests; //a JS object mapping requestObject to request type for Post processing requests

    GiseduFilterRequest m_Request;

    FilterManager m_FilterManager;
    OverlayManager m_OverlayManager;

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

        m_LoadPointOverlayList = {}
        m_LoadPolygonOverlayList = {}

        m_PointOverlayIds = {};
        m_PolygonOverlayIds = {};

        m_OverlayListLoaders = [CPArray array];
        m_PostProcessingRequests = {};
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

    var filterDescriptions = [m_FilterManager filterDescriptions];

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

        console.log("Current Filter = "); console.log(curFilter);

        if(!curFilter)
            break;

        var curFilterType = [curFilter type];
        var curFilterDescription = [filterDescriptions objectForKey:[curFilter type]];

        console.log("Current Filter Type is " + curFilterType);

        if([curFilterDescription dataType] == "POINT" || [curFilterDescription dataType] == "POLYGON")
        {
            //curFilter is a base for a filter query

            if([curFilterDescription dataType] == "POINT")
            {
                //curFilter is a key base filter
                keyFilterType = curFilterType;
                filterRequestStrings[curFilterType] = "/" + [curFilterDescription requestModifier] + "=" + [curFilter value];

                console.log("Built KeyFilter Request String: " + filterRequestStrings[curFilterType]);
            }
            else
            {
                filterRequestStrings[curFilterType] = "/" + [curFilterDescription requestModifier] + "=" + [curFilter value];

                console.log("Built BaseFilter Request String: " + filterRequestStrings[curFilterType]);
            }

            [filterChain addObjectsFromArray:filterChainBuffer];
            [filterChainBuffer removeAllObjects];
        }
        else if([curFilterDescription dataType] == "REDUCE")
        {
            var bNoBase = true;

            console.log("filterRequestStrings = "); console.log(filterRequestStrings);

            for(baseFilterType in filterRequestStrings)
            {
                console.log("baseFilterType = "); console.log(baseFilterType);
                
                var baseFilterDescription = [filterDescriptions objectForKey:baseFilterType];

                console.log("baseFilterDesc = "); console.log(baseFilterDescription);

                if([[baseFilterDescription attributeFilters] containsObject:curFilterType])
                {
                    //add to the base filter
                    if([curFilterDescription filterType] == "INTEGER" && [curFilter requestOption] != "")
                        filterRequestStrings[baseFilterType] += ":" + [curFilterDescription requestModifier] + "__" + [curFilter requestOption] + "=" + [curFilter value];
                    else
                        filterRequestStrings[baseFilterType] += ":" + [curFilterDescription requestModifier] + "=" + [curFilter value];

                    console.log("Updated BaseFilter Request String To: " + filterRequestStrings[curFilterType]);
                    bNoBase = false;
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
    console.log("onFilterRequestSuccessful");
    var filterResult = [CPSet setWithArray:[sender resultSet]]; //to remove duplicates dummy. Array->Set->Array
    var resultSet = [filterResult allObjects];

    /* console.log("resultSet = "); console.log(resultSet);
    console.log("overlayIds = "); console.log(m_OverlayIds); */

    seps = [CPCharacterSet characterSetWithCharactersInString:":"];

    for(var i=0; i < [resultSet count]; i++)
    {
        typeIdPair = [resultSet objectAtIndex:i];
        items = [typeIdPair componentsSeparatedByCharactersInSet:seps];

        itemType = parseInt([items objectAtIndex:0]);
        itemId = [items objectAtIndex:1];

        if(![m_OverlayIds objectForKey:itemType])
            [m_OverlayIds setObject:[CPArray array] forKey:itemType];

        [[m_OverlayIds objectForKey:itemType] addObject:itemId];
    }

    m_DataTypes = [m_OverlayIds allKeys];

    if(m_Delegate && [m_Delegate respondsToSelector:@selector(onFilterRequestProcessed:)])
        [m_Delegate onFilterRequestProcessed:self];
}

- (void)_addPointOverlayId:(int)objId dataType:(CPString)type
{
    [self _addPointOverlayId:objId dataType:type andLoad:NO];
}

- (void)_addPolygonOverlayId:(int)objId dataType:(CPString)type
{
    [self _addPolygonOverlayId:objId dataType:type andLoad:NO];
}

- (void)_addPointOverlayId:(int)objId dataType:(CPString)type andLoad:(BOOL)load
{
    if(!m_PointOverlayIds[type])
        m_PointOverlayIds[type] = new Array();

    m_PointOverlayIds[type].push(objId);

    if(load)
    {
        if(!m_LoadPointOverlayList[type])
            m_LoadPointOverlayList[type] = new Array();

        m_LoadPointOverlayList[type].push(objId);
    }
}

- (void)_addPolygonOverlayId:(int)objId dataType:(CPString)type andLoad:(BOOL)load
{
    if(!m_PolygonOverlayIds[type])
        m_PolygonOverlayIds[type] = new Array();

    m_PolygonOverlayIds[type].push(objId);

    if(load)
    {
        if(!m_LoadPolygonOverlayList[type])
            m_LoadPolygonOverlayList[type] = new Array();

        m_LoadPolygonOverlayList[type].push(objId);
    }
}

- (void)updateOverlays
{
    pointDisplayOptions = [PointDisplayOptions defaultOptions];
    polygonDisplayOptions = [PolygonDisplayOptions defaultOptions];

    m_LoadPointOverlayList = {}
    m_LoadPolygonOverlayList = {}
    
    m_PointOverlayIds = {};
    m_PolygonOverlayIds = {};

    var filterDescriptions = [m_FilterManager filterDescriptions];

    //Build the display options for the overlays O(2n)
    for(var i=0; i < [m_Filters count]; i++)
    {
        var curFilter = [m_Filters objectAtIndex:i];
        var curFilterType = [[curFilter description] dataType];

        if(curFilterType == "POINT")
            [pointDisplayOptions enchantOptionsFrom:[curFilter displayOptions]];
        else if(curFilterType == "POLYGON")
            [polygonDisplayOptions enchantOptionsFrom:[curFilter displayOptions]];
    }

    console.log(polygonDisplayOptions);

    //second pass REDUCE enchantment only
    for(var i=0; i < [m_Filters count]; i++)
    {
        var curFilter = [m_Filters objectAtIndex:i];
        var curFilterType = [[curFilter description] dataType];

        if(curFilterType == "REDUCE")
        {
            [pointDisplayOptions enchantOptionsFrom:[curFilter pointDisplayOptions]];
            [polygonDisplayOptions enchantOptionsFrom:[curFilter polygonDisplayOptions]];
        }
    }

    for(var i=0; i < [m_DataTypes count]; i++)
    {
        var curType = [m_DataTypes objectAtIndex:i];
        var curIds = [m_OverlayIds objectForKey:curType];

        var curFilterDescription = [filterDescriptions objectForKey:curType];

        //console.log(curType);

        for(var j=0; j < [curIds count]; j++)
        {
            var curItemId = [curIds objectAtIndex:j];
            var dataObj = [m_OverlayManager getOverlayObject:curType objId:curItemId];

            //console.log(dataObj);

            if([curFilterDescription dataType] == "POINT")
            {
               // console.log("UpdateOverlay processing pointDataType");
                var overlay = [dataObj overlay];

                if(overlay)
                {
                    [overlay setDisplayOptions:pointDisplayOptions];

                    if(![overlay markerValid])
                    {
                        [overlay removeFromMapView];
                        [overlay createGoogleMarker];
                    }

                    [overlay updateGoogleMarker];
                    [self _addPointOverlayId:curItemId dataType:curType];
                }
                else
                {
                    [self _addPointOverlayId:curItemId dataType:curType andLoad:YES];
                }
            }
            else if([curFilterDescription dataType] == "POLYGON")
            {
                //console.log("UpdateOverlay processing polygonDataType");
                var overlay = dataObj;
                //console.log(overlay);

                if(overlay)
                {
                    [overlay setDisplayOptions:polygonDisplayOptions];

                    [overlay updateGooglePolygon];
                    [self _addPolygonOverlayId:curItemId dataType:curType];
                }
                else
                {
                    [self _addPolygonOverlayId:curItemId dataType:curType andLoad:YES];
                }
            }
        }
    }

    for(curType in m_LoadPointOverlayList)
    {
        var curItemIds = m_LoadPointOverlayList[curType];
        var loaderUrl = g_UrlPrefix + "/point_geom/" + curType + "/list/";
        var loader = [[PointOverlayListLoader alloc] initWithRequestUrl:loaderUrl];
        [loader setAction:@selector(onPointOverlayListLoaded:)];
        [loader setTarget:self];
        [loader setIdList:curItemIds];
        [loader setDataType:curType];
        [loader loadWithDisplayOptions:pointDisplayOptions];

        [m_OverlayListLoaders addObject:loader];
    }

    for(curType in m_LoadPolygonOverlayList)
    {
        var curItemIds = m_LoadPolygonOverlayList[curType];
        var loaderUrl = g_UrlPrefix + "/polygon_geom/" + curType + "/list/";
        var loader = [[PolygonOverlayListLoader alloc] initWithRequestUrl:loaderUrl];
        [loader setAction:@selector(onPolygonOverlayListLoaded:)];
        [loader setTarget:self];
        [loader setIdList:curItemIds];
        [loader setDataType:curType];
        [loader loadWithDisplayOptions:polygonDisplayOptions];

        [m_OverlayListLoaders addObject:loader];
    }

    //if we don't need to load the overlays then immediate process the POST filters
    [self postProcessDisplayOptions];
}

- (void)onPointOverlayListLoaded:(id)sender
{
    console.log("onPointOverlayListLoaded called");

    var overlays = [sender pointOverlays];
    var overlayObjects = [CPArray array];
    var overlayIds = [overlays allKeys];

    for(var i=0; i < [overlayIds count]; i++)
    {
        var curId = [overlayIds objectAtIndex:i];
        var curObject = [m_OverlayManager getOverlayObject:[sender dataType] objId:curId];
        [curObject setOverlay:[overlays objectForKey:curId]];
        [overlayObjects addObject:curObject];
    }

    [m_OverlayListLoaders removeObject:sender];
    [self postProcessDisplayOptions];

    if([m_Delegate respondsToSelector:@selector(onOverlayListLoaded:dataType:)])
        [m_Delegate onOverlayListLoaded:overlayObjects dataType:[sender dataType]];
}

- (void)onPolygonOverlayListLoaded:(id)sender
{
    console.log("onPolygonOverlayListLoaded called");

    var idNameMap = [[[m_FilterManager filterDescriptions] objectForKey:[sender dataType]] options];

    var overlays = [sender polygonOverlays];
    var overlayIds = [overlays allKeys];

    var polygonDataObjects = [m_OverlayManager basicDataOverlayMap:[sender dataType]];
    [polygonDataObjects addEntriesFromDictionary:overlays];

    for(var i=0; i < [overlayIds count]; i++)
    {
        var curOverlayId = [overlayIds objectAtIndex:i];
        var curOverlay = [overlays objectForKey:curOverlayId];
        [curOverlay setPk:curOverlayId];
        [curOverlay setName:[idNameMap objectForKey:curOverlayId]];
        [curOverlay setDelegate:[m_Delegate delegate]];
        [curOverlay addToMapView];
    }

    [m_OverlayListLoaders removeObject:sender];
    [self postProcessDisplayOptions];

    if([m_Delegate respondsToSelector:@selector(onOverlayListLoaded:dataType:)])
        [m_Delegate onOverlayListLoaded:[overlays allValues] dataType:[sender dataType]];
}

- (void)postProcessDisplayOptions
{
    if([m_OverlayListLoaders count] > 0)
        return; //haven't finished loading everything

    m_PostProcessingRequests = {}
    //An important note is that, for now, post processing filters are atomic
    //in that they do not rely on each other and the order in which they
    //are processed do not matter. This may change in the future if atomicness
    //is not possible i.e. translation, rotation, and scale do not combine together
    //well unless ran is a specifc order(the one above)

    for(var i=0; i < [m_Filters count]; i++)
    {
        var curFilter = [m_Filters objectAtIndex:i];
        var curFilterDesc = [curFilter description];

        if([curFilterDesc dataType] == "POST")
        {
            if([curFilterDesc filterType] == "SCALE_INTEGER")
            {
                for(curType in m_PointOverlayIds)
                {
                    var curItemIds = m_PointOverlayIds[curType];
                    var requestUrl = g_UrlPrefix + "/point_scale_integer/" + curType;
                    var requestObject = {
                        'reduce_filter' : [curFilter reduceFilterId],
                        'minimum_scale' : [curFilter minimumScale],
                        'maximum_scale' : [curFilter maximumScale], 
                        'object_ids' : curItemIds
                    };
                    var request = [JsonRequest postRequestWithJSObject:requestObject toUrl:requestUrl delegate:self send:YES];

                    m_PostProcessingRequests[request] = "POINT_SCALE_INTEGER";
                }
            }
            else if([curFilterDesc filterType] == "COLORIZE_INTEGER")
            {
                for(curType in m_PointOverlayIds)
                {
                    var curItemIds = m_PointOverlayIds[curType];
                    var requestUrl = g_UrlPrefix + "/point_colorize_integer/" + curType;
                    var requestObject = {
                        'reduce_filter' : [curFilter reduceFilterId],
                        'minimum_color' : [curFilter minimumColor],
                        'maximum_scale' : [curFilter maximumColor], 
                        'object_ids' : curItemIds
                    };
                    var request = [JsonRequest postRequestWithJSObject:requestObject toUrl:requestUrl delegate:self send:YES];

                    m_PostProcessingRequests[request] = "POINT_COLORIZE_INTEGER";
                }

                for(curType in m_PolygonOverlayIds)
                {
                    var curItemIds = m_PolygonOverlayIds[curType];
                    var requestUrl = g_UrlPrefix + "/polygon_colorize_integer/" + curType;
                    var requestObject = {
                        'reduce_filter' : [curFilter reduceFilterId],
                        'minimum_color' : [curFilter minimumColor],
                        'maximum_scale' : [curFilter maximumColor], 
                        'object_ids' : curItemIds
                    };
                    var request = [JsonRequest postRequestWithJSObject:requestObject toUrl:requestUrl delegate:self send:YES];

                    m_PostProcessingRequests[request] = "POLYGON_COLORIZE_INTEGER";
                }
            }
        }
    }
}

- (void)onJsonRequestSuccessful:(id)sender withResponse:(id)responseData
{
    if(m_PostProcessingRequests[sender] == "POINT_SCALE_INTEGER") 
    {
        for(curType in m_PointOverlayIds)
        {
            var curItemIds = m_PointOverlayIds[curType];

            for(var i=0; i < curItemIds.length; i++)
            {
                var curOverlayId = curItemIds[i];
                var newScale = responseData[curOverlayId];

                if(newScale)
                {
                    var pointOverlay = [[m_OverlayManager getOverlayObject:curType objId:curOverlayId] overlay];
                    var displayOptions = [pointOverlay displayOptions];
                    [displayOptions setDisplayOption:'radius' value:newScale];
                    [pointOverlay updateGoogleMarker];
                }
            }
        }
    }
    else if(m_PostProcessingRequests[sender] == "POINT_COLORIZE_INTEGER") {}
        //apply the display properties
    else if(m_PostProcessingRequests[sender] == "POLYGON_COLORIZE_INTEGER") {}
        //apply the display properties
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
