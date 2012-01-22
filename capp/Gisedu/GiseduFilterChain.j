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

    //dictionary of list {'org' : [1,2,3,4,], 'school' : [5,6,7,8]};
    CPDictionary        m_OverlayIds           @accessors(getter=overlayIds);

    var m_LoadPointOverlayList;
    var m_LoadPolygonOverlayList;

    var m_PointOverlayIds;
    var m_PolygonOverlayIds;

    CPArray m_OverlayListLoaders;
    var m_PostProcessingRequests;       //a JS object mapping requestObject to request type for Post processing requests
    CPInteger m_PostProcessesPending;   //Reference count of how many post processing items are pending

    CPArray m_MapOverlays;        //a current list of overlays currently shown on map view attached to this filter chain

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

        m_MapOverlays = [CPArray array];

        m_PointOverlayIds = {};
        m_PolygonOverlayIds = {};

        m_OverlayListLoaders = [CPArray array];
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

        itemType = parseInt([items objectAtIndex:0]);
        itemId = [items objectAtIndex:1];

        if(![m_OverlayIds objectForKey:itemType])
            [m_OverlayIds setObject:[CPArray array] forKey:itemType];

        [[m_OverlayIds objectForKey:itemType] addObject:itemId];
    }

    m_DataTypes = [m_OverlayIds allKeys];

    if(m_Delegate && [m_Delegate respondsToSelector:@selector(onFilterRequestReceived:)])
        [m_Delegate onFilterRequestReceived:self];
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

/* Marks all overlays currently attached to this filter chain displaying
    on the map as dirty and needing redraw */
- (void)dirtyMapOverlays
{
    for(var i=0; i < [m_MapOverlays count]; i++)
        [[m_MapOverlays objectAtIndex:i] setDirty];
}

- (void)updateOverlays
{
    pointDisplayOptions = [PointDisplayOptions defaultOptions];
    polygonDisplayOptions = [PolygonDisplayOptions defaultOptions];

    m_LoadPointOverlayList = {}
    m_LoadPolygonOverlayList = {}
    
    m_PointOverlayIds = {};
    m_PolygonOverlayIds = {};

    [m_MapOverlays removeAllObjects];

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

        for(var j=0; j < [curIds count]; j++)
        {
            var curItemId = [curIds objectAtIndex:j];
            var dataObj = [m_OverlayManager getOverlayObject:curType objId:curItemId];

            if([curFilterDescription dataType] == "POINT")
            {
                var overlay = [dataObj overlay];

                if(overlay)
                {
                    [overlay setFilterDisplayOptions:pointDisplayOptions];

                    [m_OverlayManager addMapOverlay:overlay];
                    [m_MapOverlays addObject:overlay];
                    [self _addPointOverlayId:curItemId dataType:curType];
                }
                else
                {
                    [self _addPointOverlayId:curItemId dataType:curType andLoad:YES];
                }
            }
            else if([curFilterDescription dataType] == "POLYGON")
            {
                var overlay = dataObj;

                if(overlay)
                {
                    [overlay setFilterDisplayOptions:polygonDisplayOptions];

                    [self _addPolygonOverlayId:curItemId dataType:curType];

                    [m_OverlayManager addMapOverlay:overlay];
                    [m_MapOverlays addObject:overlay];
                }
                else
                {
                    [self _addPolygonOverlayId:curItemId dataType:curType andLoad:YES];
                }
            }
        }
    }

    console.log("FilterChains' Display Options");
    console.log(pointDisplayOptions);

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
    var overlayIds = [overlays allKeys];

    for(var i=0; i < [overlayIds count]; i++)
    {
        var curId = [overlayIds objectAtIndex:i];
        var curObject = [m_OverlayManager getOverlayObject:[sender dataType] objId:curId];
        var curOverlay = [overlays objectForKey:curId];
        [curObject setOverlay:curOverlay];
        [m_OverlayManager addMapOverlay:curOverlay];
        [m_MapOverlays addObject:curOverlay];
    }

    [m_OverlayListLoaders removeObject:sender];
    [self postProcessDisplayOptions];
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
        [m_OverlayManager addMapOverlay:curOverlay];
        [m_MapOverlays addObject:curOverlay];
    }

    [m_OverlayListLoaders removeObject:sender];
    [self postProcessDisplayOptions];
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
                    var requestUrl = g_UrlPrefix + "/point_scale_integer/";
                    var requestObject = {
                        'reduce_filter' : [curFilter reduceFilterId],
                        'minimum_scale' : [curFilter minimumScale],
                        'maximum_scale' : [curFilter maximumScale], 
                        'object_ids' : curItemIds
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

                for(curType in m_PointOverlayIds)
                {
                    var curItemIds = m_PointOverlayIds[curType];
                    var requestUrl = g_UrlPrefix + "/point_colorize_integer/";
                    var requestObject = {
                        'reduce_filter' : [curFilter reduceFilterId],
                        'minimum_color' : minColor,
                        'maximum_color' : maxColor,
                        'object_ids' : curItemIds
                    };
                    var request = [JsonRequest postRequestWithJSObject:requestObject toUrl:requestUrl delegate:self send:YES];

                    m_PostProcessesPending++;
                    m_PostProcessingRequests[request] = "POINT_COLORIZE_INTEGER";
                }

                for(curType in m_PolygonOverlayIds)
                {
                    var curItemIds = m_PolygonOverlayIds[curType];
                    var requestUrl = g_UrlPrefix + "/polygon_colorize_integer/";
                    var requestObject = {
                        'reduce_filter' : [curFilter reduceFilterId],
                        'minimum_color' : minColor,
                        'maximum_color' : maxColor,
                        'object_ids' : curItemIds
                    };
                    var request = [JsonRequest postRequestWithJSObject:requestObject toUrl:requestUrl delegate:self send:YES];

                    m_PostProcessesPending++;
                    m_PostProcessingRequests[request] = "POLYGON_COLORIZE_INTEGER";
                }
            }
        }
    }

    if(!m_PostProcessesPending)
    {
        if(m_Delegate && [m_Delegate respondsToSelector:@selector(onFilterChainProcessed:)])
            [m_Delegate onFilterChainProcessed:self];
    }
}

- (void)onJsonRequestSuccessful:(id)sender withResponse:(id)responseData
{
    if(m_PostProcessingRequests[sender] == "POINT_SCALE_INTEGER") 
    {
        m_PostProcessesPending--;

        console.log("POINT_SCALE_INTEGER jsonRequestSuccessful");

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

                    if([displayOptions getDisplayOption:'radius'] != newScale)
                    {
                        [displayOptions setDisplayOption:'radius' value:newScale];
                        [pointOverlay setDirty];
                    }
                }
            }
        }
    }
    else if(m_PostProcessingRequests[sender] == "POINT_COLORIZE_INTEGER")
    {
        m_PostProcessesPending--;

        console.log("POINT_COLORIZE_INTEGER jsonRequestSuccessful");

        for(curType in m_PointOverlayIds)
        {
            var curItemIds = m_PointOverlayIds[curType];

            for(var i=0; i < curItemIds.length; i++)
            {
                var curOverlayId = curItemIds[i];
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
    }
    else if(m_PostProcessingRequests[sender] == "POLYGON_COLORIZE_INTEGER")
    {
        m_PostProcessesPending--;

        console.log("POLYGON_COLORIZE_INTEGER jsonRequestSuccessful");

        for(curType in m_PolygonOverlayIds)
        {
            var curItemIds = m_PolygonOverlayIds[curType];

            for(var i=0; i < curItemIds.length; i++)
            {
                var curOverlayId = curItemIds[i];
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
    }

    if(!m_PostProcessesPending)
    {
        if(m_Delegate && [m_Delegate respondsToSelector:@selector(onFilterChainProcessed:)])
            [m_Delegate onFilterChainProcessed:self];
    }
}

- (void)onJsonRequestFailed:(id)sender withError:(CPString)error 
{
    m_PostProcessesPending--;

    if(!m_PostProcessesPending)
    {
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
