@import <AppKit/CPTreeNode.j>
@import "PointDisplayOptions.j"
@import "PolygonDisplayOptions.j"

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

    CPArray m_OverlayListLoaders;

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

        m_OverlayListLoaders = [CPArray array];
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

- (void)updateOverlays
{
    pointDisplayOptions = [PointDisplayOptions defaultOptions];
    polygonDisplayOptions = [PolygonDisplayOptions defaultOptions];

    m_LoadPointOverlayList = {}
    m_LoadPolygonOverlayList = {}

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
                }
                else
                {
                    if(!m_LoadPointOverlayList[curType])
                        m_LoadPointOverlayList[curType] = new Array();

                    m_LoadPointOverlayList[curType].push(curItemId);
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
                }
                else
                {
                    if(!m_LoadPolygonOverlayList[curType])
                        m_LoadPolygonOverlayList[curType] = new Array();

                    m_LoadPolygonOverlayList[curType].push(curItemId);
                }
            }
        }
    }

    for(curType in m_LoadPointOverlayList)
    {
        var curItemIds = m_LoadPointOverlayList[curType];
        [self loadPointOverlayList:curType withIds:curItemIds withDisplayOptions:pointDisplayOptions];
    }

    for(curType in m_LoadPolygonOverlayList)
    {
        var curItemIds = m_LoadPolygonOverlayList[curType];
        [self loadPolygonOverlayList:curType withIds:curItemIds withDisplayOptions:polygonDisplayOptions];
    }
}

- (void)loadPointOverlayList:(CPString)dataType withIds:(CPArray)itemIds withDisplayOptions:(id)displayOptions
{
    var loaderUrl = g_UrlPrefix + "/point_geom/" + dataType + "/list/";
    var loader = [[PointOverlayListLoader alloc] initWithRequestUrl:loaderUrl];
    [loader setAction:@selector(onPointOverlayListLoaded:)];
    [loader setTarget:self];
    [loader setIdList:itemIds];
    [loader setDataType:dataType];
    [loader loadWithDisplayOptions:displayOptions];

    [m_OverlayListLoaders addObject:loader];
}

- (void)loadPolygonOverlayList:(CPString)dataType withIds:(id)itemIds withDisplayOptions:(id)displayOptions
{
    var loaderUrl = g_UrlPrefix + "/polygon_geom/" + dataType + "/list/";
    var loader = [[PolygonOverlayListLoader alloc] initWithRequestUrl:loaderUrl];
    [loader setAction:@selector(onPolygonOverlayListLoaded:)];
    [loader setTarget:self];
    [loader setIdList:itemIds];
    [loader setDataType:dataType];
    [loader loadWithDisplayOptions:displayOptions];

    [m_OverlayListLoaders addObject:loader];
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
