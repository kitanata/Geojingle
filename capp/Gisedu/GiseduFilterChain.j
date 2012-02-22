/***** BEGIN LICENSE BLOCK *****
* Version: MPL 1.1/GPL 2.0/LGPL 2.1
*
* The Gisedu project is subject to the Mozilla Public License Version
* 1.1 (the "License"); you may not use any content of the Gisedu project
* except in compliance with the License. You may obtain a copy of the License at
* http://www.mozilla.org/MPL/
*
* Software distributed under the License is distributed on an "AS IS" basis,
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
* for the specific language governing rights and limitations under the
* License.
*
* The Original Code is the "Gisedu Project".
*
* The Initial Developer of the Original Code is "eTech Ohio Commission".
* Portions created by the Initial Developer are Copyright (C) 2011
* the Initial Developer. All Rights Reserved.
*
* Contributor(s):
*      Raymond E Chandler III
*
* Alternatively, the contents of this project may be used under the terms of
* either the GNU General Public License Version 2 or later (the "GPL"), or
* the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
* in which case the provisions of the GPL or the LGPL are applicable instead
* of those above. If you wish to allow use of your version of this file only
* under the terms of either the GPL or the LGPL, and not to allow others to
* use your version of this file under the terms of the MPL, indicate your
* decision by deleting the provisions above and replace them with the notice
* and other provisions required by the GPL or the LGPL. If you do not delete
* the provisions above, a recipient may use your version of this file under
* the terms of any one of the MPL, the GPL or the LGPL.
*
* ***** END LICENSE BLOCK ***** */
@import <AppKit/CPTreeNode.j>
@import "PointDisplayOptions.j"
@import "PolygonDisplayOptions.j"

@import "FileKit/JsonRequest.j"
@import "GeoJsonParser.j"

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

    CPDictionary m_PointOverlayIds             @accessors(getter=pointOverlayIds);
    CPDictionary m_PolygonOverlayIds           @accessors(getter=polygonOverlayIds);
    CPInteger m_DataSize                       @accessors(getter=dataSize);

    var m_LoadOverlayList;
    JsonRequest m_OverlayListLoader;

    PointDisplayOptions m_PointDisplayOptions;
    PolygonDisplayOptions m_PolygonDisplayOptions;

    var m_PostProcessingRequests;       //a JS object mapping requestObject to request type for Post processing requests
    CPInteger m_PostProcessesPending;   //Reference count of how many post processing items are pending

    JsonRequest m_DataSizeRequest;
    JsonRequest m_Request;

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

        m_FilterManager = [FilterManager getInstance];
        m_OverlayManager = [OverlayManager getInstance];

        m_LoadOverlayList = {}
        m_PointOverlayIds = [CPDictionary dictionary];
        m_PolygonOverlayIds = [CPDictionary dictionary];

        m_PostProcessingRequests = {};
        m_PostProcessesPending = 0;
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

/*Returns YES is chain is empty after delete */
- (BOOL)removeFilter:(GiseduFilter)filter
{
    if([self containsFilter:filter])
    {
        var lastFilter = [m_Filters lastObject];

        while(lastFilter != filter)
        {
            [m_Filters removeLastObject];
            lastFilter = [m_Filters lastObject];
        }

        [m_Filters removeLastObject];
    }

    [self dirtyMapOverlays:YES];

    return ([m_Filters count] <= 0);
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

        if(!curFilter)
            break;

        var curFilterType = [curFilter type];
        var curFilterDescription = [filterDescriptions objectForKey:[curFilter type]];

        if([curFilterDescription dataType] == "POINT" || [curFilterDescription dataType] == "POLYGON")
        {
            //curFilter is a base for a filter query

            if([curFilterDescription dataType] == "POINT")
            {
                //curFilter is a key base filter
                keyFilterType = curFilterType;
                filterRequestStrings[curFilterType] = "/" + [curFilterDescription requestModifier] + "=" + [curFilter value];
            }
            else
            {
                filterRequestStrings[curFilterType] = "/" + [curFilterDescription requestModifier] + "=" + [curFilter value];
            }

            [filterChain addObjectsFromArray:filterChainBuffer];
            [filterChainBuffer removeAllObjects];
        }
        else if([curFilterDescription dataType] == "REDUCE")
        {
            var bNoBase = true;

            for(baseFilterType in filterRequestStrings)
            {
                var baseFilterDescription = [filterDescriptions objectForKey:baseFilterType];

                if([[baseFilterDescription attributeFilters] containsObject:curFilterType])
                {
                    //add to the base filter
                    if([curFilterDescription filterType] == "INTEGER" && [curFilter requestOption] != "")
                        filterRequestStrings[baseFilterType] += ":" + [curFilterDescription requestModifier] + "__" + [curFilter requestOption] + "=" + [curFilter value];
                    else
                        filterRequestStrings[baseFilterType] += ":" + [curFilterDescription requestModifier] + "=" + [curFilter value];

                    bNoBase = false;
                }
            }

            if(bNoBase)
            {
                [filterChainBuffer addObject:curFilter];
            }
        }
    }

    var requestUrl = "";

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

- (void)sendDataSizeRequest
{
    console.log("GiseduFilterChain:sendDataSizeRequest");

    var requestUrl = g_UrlPrefix + "/data_size/filter" + [self buildFilterRequest];

    if(requestUrl)
        m_DataSizeRequest = [JsonRequest getRequestFromUrl:requestUrl delegate:self send:YES];
}

- (void)sendFilterRequest
{
    console.log("GiseduFilterChain::sendFilterRequest");

    var requestUrl = g_UrlPrefix + "/filter" + [self buildFilterRequest];

    if(requestUrl)
        m_Request = [JsonRequest getRequestFromUrl:requestUrl delegate:self send:YES];
}

- (void)_addPointOverlayId:(int)objId dataType:(CPString)type
{
    if(![m_PointOverlayIds containsKey:type])
        [m_PointOverlayIds setObject:[CPArray array] forKey:type];

    [[m_PointOverlayIds objectForKey:type] addObject:objId];
}

- (void)_addPolygonOverlayId:(int)objId dataType:(CPString)type
{
    if(![m_PolygonOverlayIds containsKey:type])
        [m_PolygonOverlayIds setObject:[CPArray array] forKey:type];

    [[m_PolygonOverlayIds objectForKey:type] addObject:objId];
}

- (void)_addOverlayToLoader:(int)objId dataType:(CPString)type
{
    if(!m_LoadOverlayList[type])
        m_LoadOverlayList[type] = new Array();

    m_LoadOverlayList[type].push(objId);
}

/* Marks all overlays currently attached to this filter chain displaying
    on the map as dirty and needing redraw */
- (void)dirtyMapOverlays
{
    [self dirtyMapOverlays:NO];
}

- (void)dirtyMapOverlays:(BOOL)resetOptions
{
    console.log("FilterChain::dirtyMapOverlays called");
    var pointOverlayKeys = [m_PointOverlayIds allKeys];
    for(var i=0; i < [pointOverlayKeys count]; i++)
    {
        var dataType = [pointOverlayKeys objectAtIndex:i];
        var idList = [m_PointOverlayIds objectForKey:dataType];

        for(var j=0; j < [idList count]; j++)
        {
            var overlayId = [idList objectAtIndex:j];
            var overlay = [[m_OverlayManager getOverlayObject:dataType objId:overlayId] overlay];

            if(overlay)
            {
                if(resetOptions)
                    [[overlay displayOptions] resetOptions];

                [overlay setDirty];
            }
        }
    }


    var polygonOverlayKeys = [m_PolygonOverlayIds allKeys];
    for(var i=0; i < [polygonOverlayKeys count]; i++)
    {
        var dataType = [polygonOverlayKeys objectAtIndex:i];
        var idList = [m_PolygonOverlayIds objectForKey:dataType];

        for(var j=0; j < [idList count]; j++)
        {
            var overlayId = [idList objectAtIndex:j];
            var overlay = [m_OverlayManager getOverlayObject:dataType objId:overlayId];

            if(overlay)
            {
                if(resetOptions)
                    [[overlay displayOptions] resetOptions];

                [overlay setDirty];
            }
        }
    }
}

- (void)updateOverlays
{
    console.log("GiseduFilterChain::updateOverlays");

    m_PointDisplayOptions = [PointDisplayOptions defaultOptions];
    m_PolygonDisplayOptions = [PolygonDisplayOptions defaultOptions];

    m_LoadOverlayList = {}
    
    //Build the display options for the overlays O(2n)
    for(var i=0; i < [m_Filters count]; i++)
    {
        var curFilter = [m_Filters objectAtIndex:i];
        var curFilterType = [[curFilter description] dataType];

        if(curFilterType == "POINT")
            [m_PointDisplayOptions enchantOptionsFrom:[curFilter displayOptions]];
        else if(curFilterType == "POLYGON")
            [m_PolygonDisplayOptions enchantOptionsFrom:[curFilter displayOptions]];
    }

    //second pass REDUCE enchantment only
    for(var i=0; i < [m_Filters count]; i++)
    {
        var curFilter = [m_Filters objectAtIndex:i];
        var curFilterType = [[curFilter description] dataType];

        if(curFilterType == "REDUCE")
        {
            [m_PointDisplayOptions enchantOptionsFrom:[curFilter pointDisplayOptions]];
            [m_PolygonDisplayOptions enchantOptionsFrom:[curFilter polygonDisplayOptions]];
        }
    }

    var pointOverlayKeys = [m_PointOverlayIds allKeys];
    for(var i=0; i < [pointOverlayKeys count]; i++)
    {
        var dataType = [pointOverlayKeys objectAtIndex:i];
        var idList = [m_PointOverlayIds objectForKey:dataType];

        for(var j=0; j < [idList count]; j++)
        {
            var overlayId = [idList objectAtIndex:j];
            var overlay = [[m_OverlayManager getOverlayObject:dataType objId:overlayId] overlay];

            if(overlay)
            {
                [overlay setFilterDisplayOptions:m_PointDisplayOptions];
                [m_OverlayManager addMapOverlay:overlay];
            }
            else
            {
                [self _addOverlayToLoader:overlayId dataType:dataType];
            }
        }
    }

    var polygonOverlayKeys = [m_PolygonOverlayIds allKeys];
    for(var i=0; i < [polygonOverlayKeys count]; i++)
    {
        var dataType = [polygonOverlayKeys objectAtIndex:i];
        var idList = [m_PolygonOverlayIds objectForKey:dataType];

        for(var j=0; j < [idList count]; j++)
        {
            var overlayId = [idList objectAtIndex:j];
            var overlay = [m_OverlayManager getOverlayObject:dataType objId:overlayId];

            if(overlay)
            {
                [overlay setFilterDisplayOptions:m_PolygonDisplayOptions];
                [m_OverlayManager addMapOverlay:overlay];
            }
            else
            {
                [self _addOverlayToLoader:overlayId dataType:dataType];
            }
        }
    }

    loaderUrl = g_UrlPrefix + "/geom_list/";
    m_OverlayListLoader = [JsonRequest postRequestWithJSObject:m_LoadOverlayList 
                toUrl:loaderUrl delegate:self send:YES];
}

- (void)postProcessDisplayOptions
{
    console.log("GiseduFilterChain::postProcessDisplayOptions");

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
                var pointOverlayTypes = [m_PointOverlayIds allKeys];
                for(var j=0; j < [pointOverlayTypes count]; j++)
                {
                    var curType = [pointOverlayTypes objectAtIndex:j];
                    curItemIds = [m_PointOverlayIds objectForKey:curType];

                    var requestArray = new Array();
                    for(var k=0; k < [curItemIds count]; k++)
                        requestArray.push([curItemIds objectAtIndex:k]);

                    var requestUrl = g_UrlPrefix + "/point_scale_integer/";
                    var requestObject = {
                        'reduce_filter' : [curFilter reduceFilterId],
                        'minimum_scale' : [curFilter minimumScale],
                        'maximum_scale' : [curFilter maximumScale], 
                        'object_ids' : requestArray
                    };
                    var request = [JsonRequest postRequestWithJSObject:requestObject toUrl:requestUrl delegate:self send:YES];

                    m_PostProcessesPending++;
                    m_PostProcessingRequests[request] = "POINT_SCALE_INTEGER";
                }
            }
            else if([curFilterDesc filterType] == "COLORIZE_INTEGER")
            {
                var minColorComponents = [[curFilter minimumColor] components];
                var maxColorComponents = [[curFilter maximumColor] components];

                var minColor = Array();
                var maxColor = Array();

                for(var j=0; j < [minColorComponents count]; j++)
                    minColor.push([minColorComponents objectAtIndex:j]);

                for(var j=0; j < [maxColorComponents count]; j++)
                    maxColor.push([maxColorComponents objectAtIndex:j]);

                //Note: The above looks redudant, but isn't. Cappucinno puts extra things in it's array implementation. When this
                //extra stuff is serialized it fails because of a cyclical pattern in the object. We remove this stuff
                //and put things into a plain old JS array so it can easily be serialized to JSON.

                var pointOverlayTypes = [m_PointOverlayIds allKeys];
                for(var j=0; j < [pointOverlayTypes count]; j++)
                {
                    var curType = [pointOverlayTypes objectAtIndex:j];
                    curItemIds = [m_PointOverlayIds objectForKey:curType];

                    var requestArray = new Array();
                    for(var k=0; k < [curItemIds count]; k++)
                        requestArray.push([curItemIds objectAtIndex:k]);

                    var requestUrl = g_UrlPrefix + "/point_colorize_integer/";
                    var requestObject = {
                        'reduce_filter' : [curFilter reduceFilterId],
                        'minimum_color' : minColor,
                        'maximum_color' : maxColor,
                        'object_ids' : requestArray
                    };
                    var request = [JsonRequest postRequestWithJSObject:requestObject toUrl:requestUrl delegate:self send:YES];

                    m_PostProcessesPending++;
                    m_PostProcessingRequests[request] = "POINT_COLORIZE_INTEGER";
                }

                var polygonOverlayTypes = [m_PolygonOverlayIds allKeys];
                for(var j=0; j < [polygonOverlayTypes count]; j++)
                {
                    var curType = [polygonOverlayTypes objectAtIndex:j];
                    curItemIds = [m_PolygonOverlayIds objectForKey:curType];

                    var requestArray = new Array();
                    for(var k=0; k < [curItemIds count]; k++)
                        requestArray.push([curItemIds objectAtIndex:k]);

                    var requestUrl = g_UrlPrefix + "/polygon_colorize_integer/";
                    var requestObject = {
                        'reduce_filter' : [curFilter reduceFilterId],
                        'minimum_color' : minColor,
                        'maximum_color' : maxColor,
                        'object_ids' : requestArray
                    };
                    var request = [JsonRequest postRequestWithJSObject:requestObject toUrl:requestUrl delegate:self send:YES];

                    m_PostProcessesPending++;
                    m_PostProcessingRequests[request] = "POLYGON_COLORIZE_INTEGER";
                }
            }
        }
    }

    [self checkFinished];
}

- (void)onJsonRequestSuccessful:(id)sender withResponse:(id)responseData
{
    if(sender == m_DataSizeRequest)
    {
        console.log("GiseduFilterChain::onDataSizeRequestSuccessful");

        m_DataSize = responseData['data_size'];

        if(m_Delegate && [m_Delegate respondsToSelector:@selector(onFilterDataSizeRequestReceived:)])
            [m_Delegate onFilterDataSizeRequestReceived:self];
    }
    else if(sender == m_Request)
    {
        console.log("GiseduFilterChains::onFilterRequestSuccessful");

        //to remove duplicates dummy. Array->Set->Array
        var resultSet = [CPArray arrayWithObjects:responseData count:responseData.length];
        var resultSet = [[CPSet setWithArray:resultSet] allObjects]; 

        seps = [CPCharacterSet characterSetWithCharactersInString:":"];

        m_PointOverlayIds = [CPDictionary dictionary];
        m_PolygonOverlayIds = [CPDictionary dictionary];

        var filterDescriptions = [m_FilterManager filterDescriptions];
        for(var i=0; i < [resultSet count]; i++)
        {
            typeIdPair = [resultSet objectAtIndex:i];
            items = [typeIdPair componentsSeparatedByCharactersInSet:seps];

            itemType = parseInt([items objectAtIndex:0]);
            itemId = [items objectAtIndex:1];

            var curFilterDescription = [filterDescriptions objectForKey:itemType];

            if([curFilterDescription dataType] == "POINT")
                [self _addPointOverlayId:itemId dataType:itemType];
            else if([curFilterDescription dataType] == "POLYGON")
                [self _addPolygonOverlayId:itemId dataType:itemType];
        }

        if(m_Delegate && [m_Delegate respondsToSelector:@selector(onFilterRequestReceived:)])
            [m_Delegate onFilterRequestReceived:self];
    }
    else if(sender == m_OverlayListLoader)
    {
        for(filter_id in responseData)
        {
            for(var i=0; i < [m_Filters count]; i++)
            {
                var curFilter = [m_Filters objectAtIndex:i];

                if([curFilter type] != filter_id)
                    continue;

                var curFilterType = [[curFilter description] dataType];

                if(curFilterType == "POINT")
                {
                    var geoJsonParser = [GeoJsonParser alloc];

                    for(overlay_id in responseData[filter_id])
                    {
                        var jsonData = responseData[filter_id][overlay_id];
                        var pointOverlay = [geoJsonParser parsePoint:jsonData];

                        if(pointOverlay && m_PointDisplayOptions)
                            [pointOverlay setFilterDisplayOptions:m_PointDisplayOptions];

                        var curObject = [m_OverlayManager getOverlayObject:filter_id objId:overlay_id];
                        [curObject setOverlay:pointOverlay];
                        [m_OverlayManager addMapOverlay:pointOverlay];

                    }
                }
                else if(curFilterType == "POLYGON")
                {
                    var geoJsonParser = [GeoJsonParser alloc];

                    var overlayDict = [CPDictionary dictionary];

                    var idNameMap = [[[m_FilterManager filterDescriptions] 
                                        objectForKey:filter_id] options];

                    for(overlay_id in responseData[filter_id])
                    {
                        var jsonData = responseData[filter_id][overlay_id];
                        var polygonOverlay = [geoJsonParser parsePolygon:jsonData];

                        if(polygonOverlay && m_PolygonDisplayOptions)
                            [polygonOverlay setFilterDisplayOptions:m_PolygonDisplayOptions];

                        [overlayDict setObject:polygonOverlay forKey:overlay_id];

                        [polygonOverlay setPk:overlay_id];
                        [polygonOverlay setName:[idNameMap objectForKey:overlay_id]];
                        [polygonOverlay setDelegate:[m_Delegate delegate]];
                        [m_OverlayManager addMapOverlay:polygonOverlay];
                    }

                    var polygonDataObjects = [m_OverlayManager basicDataOverlayMap:filter_id];
                    [polygonDataObjects addEntriesFromDictionary:overlayDict];
                }
            }
        }

        [self postProcessDisplayOptions];
    }
    else if(m_PostProcessingRequests[sender] == "POINT_SCALE_INTEGER") 
    {
        m_PostProcessesPending--;

        console.log("POINT_SCALE_INTEGER jsonRequestSuccessful");

        var pointOverlayTypes = [m_PointOverlayIds allKeys];
        for(var i=0; i < [pointOverlayTypes count]; i++)
        {
            var curType = [pointOverlayTypes objectAtIndex:i];
            var curItemIds = [m_PointOverlayIds objectForKey:curType];
            for(var j=0; j < [curItemIds count]; j++)
            {
                var curOverlayId = [curItemIds objectAtIndex:j];
                var newScale = responseData[curOverlayId];

                if(newScale)
                {
                    var pointOverlay = [[m_OverlayManager getOverlayObject:curType objId:curOverlayId] overlay];
                    var displayOptions = [pointOverlay displayOptions];

                    if([displayOptions getDisplayOption:'radius'] != newScale)
                    {
                        [displayOptions setDisplayOption:'radius' value:newScale];
                        [pointOverlay setDirty];
                    }
                }
            }
        }

        [self checkFinished];
    }
    else if(m_PostProcessingRequests[sender] == "POINT_COLORIZE_INTEGER")
    {
        m_PostProcessesPending--;

        console.log("POINT_COLORIZE_INTEGER jsonRequestSuccessful");

        var pointOverlayTypes = [m_PointOverlayIds allKeys];
        for(var i=0; i < [pointOverlayTypes count]; i++)
        {
            var curType = [pointOverlayTypes objectAtIndex:i];
            var curItemIds = [m_PointOverlayIds objectForKey:curType];
            for(var j=0; j < [curItemIds count]; j++)
            {
                var curOverlayId = [curItemIds objectAtIndex:j];
                var col = responseData[curOverlayId];

                if(col)
                {
                    var newFillColor = [CPColor colorWithCalibratedRed:col[0] green:col[1] blue:col[2] alpha:col[3]];
                    var pointOverlay = [[m_OverlayManager getOverlayObject:curType objId:curOverlayId] overlay];
                    var displayOptions = [pointOverlay displayOptions];
                    var newFillColorStr = "#" + [newFillColor hexString];
                   
                    if([displayOptions getDisplayOption:'fillColor'] != newFillColorStr)
                    {
                        [displayOptions setDisplayOption:'fillColor' value:newFillColorStr];
                        [pointOverlay setDirty];
                    }
                }
            }
        }

        [self checkFinished];
    }
    else if(m_PostProcessingRequests[sender] == "POLYGON_COLORIZE_INTEGER")
    {
        m_PostProcessesPending--;

        console.log("POLYGON_COLORIZE_INTEGER jsonRequestSuccessful");

        var polygonOverlayTypes = [m_PolygonOverlayIds allKeys];
        for(var i=0; i < [polygonOverlayTypes count]; i++)
        {
            var curType = [polygonOverlayTypes objectAtIndex:i];
            var curItemIds = [m_PolygonOverlayIds objectForKey:curType];
            for(var j=0; j < [curItemIds count]; j++)
            {
                var curOverlayId = [curItemIds objectAtIndex:j];
                var col = responseData[curOverlayId];

                if(col)
                {
                    var newFillColor = [CPColor colorWithCalibratedRed:col[0] green:col[1] blue:col[2] alpha:col[3]];
                    var polygonOverlay = [m_OverlayManager getOverlayObject:curType objId:curOverlayId];
                    var displayOptions = [polygonOverlay displayOptions];
                    var newFillColorStr = "#" + [newFillColor hexString];
                    
                    if([displayOptions getDisplayOption:'fillColor'] != newFillColorStr)
                    {
                        [displayOptions setDisplayOption:'fillColor' value:newFillColorStr];
                        [polygonOverlay setDirty];
                    }
                }
            }
        }

        [self checkFinished];
    }
}

- (void)onJsonRequestFailed:(id)sender withError:(CPString)error 
{
    if(m_PostProcessingRequests[sender] == "POINT_SCALE_INTEGER") 
        m_PostProcessesPending--;
    else if(m_PostProcessingRequests[sender] == "POINT_COLORIZE_INTEGER")
        m_PostProcessesPending--;
    else if(m_PostProcessingRequests[sender] == "POLYGON_COLORIZE_INTEGER")
        m_PostProcessesPending--;

    [self checkFinished];
}

- (void)checkFinished
{
    if(!m_PostProcessesPending)
    {
        var dirtyOverlays = NO;
        for(var i=0; i < [m_Filters count]; i++)
        {
            var curFilter = [m_Filters objectAtIndex:i];

            if([curFilter dirty])
            {
                [curFilter setDirty:NO];
                dirtyOverlays = YES;
            }
        }

        if(dirtyOverlays)
            [self dirtyMapOverlays];

        if(m_Delegate && [m_Delegate respondsToSelector:@selector(onFilterChainProcessed:)])
            [m_Delegate onFilterChainProcessed:self];
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
