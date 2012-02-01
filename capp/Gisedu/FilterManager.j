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
@import <Foundation/CPObject.j>

@import "GiseduPointFilter.j"
@import "GiseduPolygonFilter.j"
@import "GiseduReduceFilter.j"
@import "GiseduScaleFilter.j"
@import "GiseduColorizeFilter.j"

@import "GiseduFilterDescription.j"
@import "GiseduFilterRequest.j"
@import "GiseduFilterChain.j"

var g_FilterManagerInstance = nil;

@implementation FilterManager : CPObject
{
    id m_StatusPanel                @accessors(setter=setStatusPanel:);
    OverlayManager m_OverlayManager;

    CPArray m_FilterTree;                                               //The Filter Tree
    CPArray m_FilterChains;                                             //Cached Filter Chains

    CPArray m_FilterChainsWaitingResponse;                              //Chains waiting a response from the server
    CPArray m_FilterChainsWaitingProcess;                               //Chains waiting to finish their pipeline

    id m_Delegate                       @accessors(property=delegate);

    CPDictionary m_FilterDescriptions   @accessors(getter=filterDescriptions);
    CPURLConnection m_FilterDescriptionConn;
}

- (void)init
{
    self = [super init];

    if(self)
    {
        m_OverlayManager = [OverlayManager getInstance];
        m_FilterTree = [CPArray array];
        m_FilterChains = [CPArray array];

        m_FilterChainsWaitingResponse = [CPArray array];
        m_FilterChainsWaitingProcess = [CPArray array];

        m_FilterDescriptions = [CPDictionary dictionary];
    }

    return self;
}

- (void)loadFilterDescriptions
{
    m_FilterDescriptionConn = [CPURLConnection connectionWithRequest:[CPURLRequest requestWithURL:g_UrlPrefix + "/filter_list"] delegate:self];
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError
{
    if (aConnection == m_FilterDescriptionConn)
    {
        alert('Could not load filter list from server! ' + anError);
        m_FilterListConnection = nil;
    }
    else
    {
        alert('Save failed! ' + anError);
    }
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)aData
{
    if (aConnection == m_FilterDescriptionConn)
    {
        var aData = aData.replace('while(1);', '');

        filterList = JSON.parse(aData);

        for(var filterId in filterList)
        {
            var newDescription = [[GiseduFilterDescription alloc] init];

            [newDescription fromJson:filterList[filterId]];

            [m_FilterDescriptions setObject:newDescription forKey:filterId];
        }

        if(m_Delegate && [m_Delegate respondsToSelector:@selector(onFilterDescriptionsLoaded)])
                [m_Delegate onFilterDescriptionsLoaded];
    }

    console.log("Finished loading filter descriptions");
}

- (id)filterFlagMap
{
    var flagMap = {};
    var allFilters = [[self filterDescriptions] allKeys];

    for(var i=0; i < [allFilters count]; i++)
    {
        flagMap[[allFilters objectAtIndex:i]] = YES;
    }

    return flagMap;
}

- (CPInteger)filterIdFromName:(CPString)filterName
{
    var filterDesc = [m_FilterDescriptions allValues];

    for(var i=0; i < [filterDesc count]; i++)
    {
        var curDesc = [filterDesc objectAtIndex:i];
        if([curDesc name] == filterName)
            return [curDesc id];
    }
    
    return CPNotFound;
}

- (CPString)filterNameFromId:(int)filterId
{
    var filterDesc = [m_FilterDescriptions allValues];

    for(var i=0; i < [filterDesc count]; i++)
    {
        var curDesc = [filterDesc objectAtIndex:i];
        if([curDesc id] == filterId)
            return [curDesc name];
    }

    return "NotFound";
}

- (BOOL)containsFilter:(CPTreeNode)filter
{
    if(!filter)
        return NO;

    return [self containsFilter:filter withNodes:m_FilterTree];
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
    console.log("FilterManager::createFilter called");
    var newFilter = nil;
    var filterDesc = [m_FilterDescriptions objectForKey:type];

    if([filterDesc dataType] == "POINT")
        newFilter = [[GiseduPointFilter alloc] initWithValue:'All'];
    else if([filterDesc dataType] == "POLYGON")
        newFilter = [[GiseduPolygonFilter alloc] initWithValue:'All'];
    else if([filterDesc dataType] == "REDUCE")
    {
        if([filterDesc filterType] == "BOOL")
            newFilter = [[GiseduReduceFilter alloc] initWithValue:YES];
        else
            newFilter = [[GiseduReduceFilter alloc] initWithValue:'All'];
    }
    else if([filterDesc dataType] == "POST")
    {
        if([filterDesc filterType] == "SCALE_INTEGER")
            newFilter = [[GiseduScaleFilter alloc] initWithValue:'All'];
        else if([filterDesc filterType] == "COLORIZE_INTEGER")
            newFilter = [[GiseduColorizeFilter alloc] initWithValue:'All'];
    }

    [newFilter setType:type];
    [newFilter setDescription:filterDesc];

    return newFilter;
}

- (void)addFilter:(GiseduFilter)filter parent:(GiseduFilter)parent
{
    /*
    if no parent:
        make new filter chain
    else if has siblings:
        make new filter chain
    else if is leaf:
        add to existing filter chain
    */

    if(!parent)
    {
        [m_FilterTree addObject:filter];

        var filterChain = [GiseduFilterChain filterChain];
        [filterChain addFilter:filter];
        [filterChain setDelegate:self];
        [m_FilterChains addObject:filterChain];
    }
    else if([parent isLeaf])
    {
        [parent insertObject:filter inChildNodesAtIndex:0];
        [filter enchantFromParents];

        for(var i=0; i < [m_FilterChains count]; i++)
        {
            var curChain = [m_FilterChains objectAtIndex:i];
            if([curChain containsFilter:parent])
            {
                [curChain addFilter:filter];
            }
        }
    }
    else
    {
        [parent insertObject:filter inChildNodesAtIndex:0];
        [filter enchantFromParents];

        var filterChain = [GiseduFilterChain filterChain];
        [self _buildFilterChain:filter withChain:filterChain];
        [filterChain setDelegate:self];
        [m_FilterChains addObject:filterChain];
    }
}

- (void)deleteFilter:(CPTreeNode)filter
{
    var parent = [filter parentNode];

    if(parent)
    {
        [parent removeObjectFromChildNodesAtIndex:[[parent childNodes] indexOfObject:filter]];

        var emptyChains = [CPArray array];

        for(var i = 0; i < [m_FilterChains count]; i++)
        {
            var curChain = [m_FilterChains objectAtIndex:i];

            if([curChain containsFilter:filter])
            {
                var empty = [curChain deleteFilter:filter];

                if(empty)
                    [emptyChains addObject:curChain];
            }
        }

        for(var i=0; i < [emptyChains count]; i++)
            [m_FilterChains removeObject:[emptyChains objectAtIndex:i]];
    }
    else
    {
        [m_FilterTree removeObject:filter];
    }
}

- (id)outlineView:(CPOutlineView)outlineView child:(int)index ofItem:(id)item
{
    if (item === nil)
    {
        //console.log("index = "); console.log(index);
        //console.log("returning = "); console.log([m_FilterTree objectAtIndex:index]);
        return [m_FilterTree objectAtIndex:index];
    }
    else
    {
        //console.log("index = "); console.log(index);
        //console.log("returning = "); console.log([[item childNodes] objectAtIndex:index]);
        return [[item childNodes] objectAtIndex:index];
    }
}

- (BOOL)outlineView:(CPOutlineView)outlineView isItemExpandable:(id)item
{
    //console.log(item);
    //console.log("Problem expandable");
    //console.log(([[item childNodes] count] > 0));
    return ([[item childNodes] count] > 0);
}

- (int)outlineView:(CPOutlineView)outlineView numberOfChildrenOfItem:(id)item
{
    //console.log(item);
    //console.log("Problem Child Num");
    if (item === nil)
    {
        //console.log([m_FilterTree count]);
        return [m_FilterTree count];
    }
    else
    {
        //console.log([[item childNodes] count]);
        return [[item childNodes] count];
    }
}

- (id)outlineView:(CPOutlineView)outlineView objectValueForTableColumn:(CPTableColumn)tableColumn byItem:(id)item
{
    var filterType = [item type];
    var filterDescription = [item description];

    var names = nil;

    var filterTypeName = [filterDescription name];
    var filterLabel = "All " + filterTypeName + " Filter";

    if([filterDescription filterType] == "LIST")
    {
        var filterName = [[filterDescription options] objectForKey:[item value]];

        if(!filterName)
            filterName = "All";
            
        filterLabel = filterName + " " + filterTypeName + " Filter";
    }
    else if([filterDescription filterType] == "DICT")
    {
        filterLabel = [item value] + " " + filterTypeName + " Filter";
    }
    else if([filterDescription dataType] == "POINT")
    {
        var filterName = [[m_OverlayManager pointDataTypes:filterType] objectForKey:[item value]];

        if(filterName)
            filterLabel = filterName + " " + filterTypeName + " Filter";
    }
    else if([filterDescription filterType] == "CHAR")
    {
        var filterName = [[filterDescription options] objectForKey:[item value]];

        if(filterName)
            filterLabel = filterName + " " + filterTypeName + " Filter";
    }
    else if([filterDescription filterType] == "BOOL")
    {
        if([item value])
            filterLabel = "Has " + filterTypeName + " Filter";
        else
            filterLabel = "Doesn't have " + filterTypeName + " Filter";
    }
    else if([filterDescription filterType] == "INTEGER")
    {
        var filterValue = [item value];
        var requestOption = [item requestOption];

        if(requestOption == "lt")
            requestOption = "< "
        else if(requestOption == "gt")
            requestOption = "> "
        else if(requestOption == "gte")
            requestOption = ">= "
        else if(requestOption == "lte")
            requestOption = "<= "
        else
            requestOption = "== "

            
        if(filterValue != "All")
            filterLabel = requestOption + [item value] + " " + filterTypeName + " Filter";
    }

    return [filterLabel capitalizedString];
}

- (BOOL)outlineView:(CPOutlineView)outlineView acceptDrop:(id)info item:(id)item childIndex:(CPInteger)index
{
    var pboard = [info draggingPasteboard];
    var dataNode = [pboard dataForType:"filters"];
    var retVal = NO;

    if(item == dataNode)
        return NO;

    var dataNodeParent = [dataNode parentNode];

    if(!dataNodeParent)
    {
        [m_FilterTree removeObject:dataNode];

        if(!item)
        {
            [m_FilterTree addObject:dataNode];
            retVal = YES;
        }

        var itemRootParent = item;

        while([itemRootParent parentNode])
            itemRootParent = [itemRootParent parentNode];

        if(itemRootParent == dataNode)
        {
            [m_FilterTree addObjectsFromArray:[dataNode childNodes]];

            while([[dataNode childNodes] count] > 0)
                [dataNode removeObjectFromChildNodesAtIndex:0];
        }

        [item insertObject:dataNode inChildNodesAtIndex:0];

        retVal = YES;
    }
    else if(!item)
    {
        if(dataNodeParent)
        {
            var dataNodeIndex = [[dataNodeParent childNodes] indexOfObject:dataNode];
            [dataNodeParent removeObjectFromChildNodesAtIndex:dataNodeIndex];
        }

        [m_FilterTree addObject:dataNode];

        retVal = YES;
    }
    else if([item parentNode] != dataNode)
    {
        [item insertObject:dataNode inChildNodesAtIndex:0];

        retVal = YES;
    }
    else if([item parentNode] == dataNode)
    {
        if(dataNodeParent)
        {
            var itemIndex = [[dataNode childNodes] indexOfObject:item];
            [dataNode removeObjectFromChildNodesAtIndex:itemIndex];

            [dataNodeParent removeObjectFromChildNodesAtIndex:dataNodeIndex];
            var dataNodeIndex = [[dataNodeParent childNodes] indexOfObject:dataNode];
            [dataNodeParent insertObject:item inChildNodesAtIndex:dataNodeIndex];
            [item insertObject:dataNode inChildNodesAtIndex:index];
        }
        else
        {
            var itemIndex = [[dataNode childNodes] indexOfObject:item];
            [dataNode removeObjectFromChildNodesAtIndex:itemIndex];
            [item insertObject:dataNode inChildNodesAtIndex:index];
        }

        retVal = YES;
    }

    //Rebuild Broken Filter Chains
    if(retVal)
        [self rebuildFilterChains];

    return retVal;
}

- (CPDragOperation)outlineView:(CPOutlineView)outlineView validateDrop:(id)info proposedItem:(id)item proposedChildIndex:(CPInteger)index
{
    var movingItem = [[info draggingPasteboard] dataForType:"filters"];

    var filtersInTree = [self allTypesInFilterTree:movingItem];

    var exclusionMap = [self filterFlagMap];

    for(var i=0; i < [filtersInTree count]; i++)
    {
        var curFilterType = [filtersInTree objectAtIndex:i];
        var curFilterDesc = [m_FilterDescriptions objectForKey:curFilterType];

        var curExs = [curFilterDesc excludeFilters];

        for(var j=0; j < [curExs count]; j++)
            exclusionMap[[curExs objectAtIndex:j]] = NO;
    }

    var filtersInProposedItem = [CPArray arrayWithObject:[item type]];

    while([item parentNode])
    {
        [filtersInProposedItem addObject:[[item parentNode] type]];
        item = [item parentNode];
    }

    for(var i=0; i < [filtersInProposedItem count]; i++)
    {
        var curFilterType = [filtersInProposedItem objectAtIndex:i];

        if(exclusionMap[curFilterType] == NO)
            return CPDragOperationNone;
    }

    return CPDragOperationMove;
}

- (CPArray)allTypesInFilterTree:(GiseduFilter)filter
{
    var typeList = [CPArray array];
    var filterChildren = [filter childNodes];

    for(var i=0; i < [filterChildren count]; i++)
    {
        var curChild = [filterChildren objectAtIndex:i];

        [typeList addObjectsFromArray:[self allTypesInFilterTree:curChild]];
    }

    [typeList addObject:[filter type]];

    return typeList;
}

- (BOOL)outlineView:(CPOutlineView)outlineView writeItems:(CPArray)items toPasteboard:(CPPasteboard)pboard
{
    if([items count] > 1 || [items count] == 0)
        return NO;

    var theItem = [items objectAtIndex:0];

    [pboard declareTypes:[CPArray arrayWithObject:"filters"] owner:self];
    [pboard setData:theItem forType:"filters"];

    return YES;
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
    console.log("Trigger Filters Called");

    [m_OverlayManager removeMapOverlays];
    [m_StatusPanel setStatus:"Sending Filters To Server"];
    [self sendFilterRequests];
}

- (void)rebuildFilterChains
{
    for(var i=0; i < [m_FilterChains count]; i++)
        [[m_FilterChains objectAtIndex:i] dirtyMapOverlays];

    [m_FilterChains removeAllObjects];
    [self _rebuildFilterChains:m_FilterTree];
}

- (void)_rebuildFilterChains:(CPArray)filters
{
    for(var i=0; i < [filters count]; i++)
    {
        var curFilter = [filters objectAtIndex:i];

        if(![curFilter isLeaf])
        {
            [self _rebuildFilterChains:[curFilter childNodes]];
        }
        else//leaf and has a parent
        {
            var filterChain = [GiseduFilterChain filterChain];
            [self _buildFilterChain:curFilter withChain:filterChain];
            [filterChain setDelegate:self];
            [m_FilterChains addObject:filterChain];
        }
    }
}

- (void)_buildFilterChain:(id)filter withChain:(GiseduFilterChain)filterChain
{
    if([filter parentNode])
        [self _buildFilterChain:[filter parentNode] withChain:filterChain];

    [filterChain addFilter:filter];
}

- (void)sendFilterRequests
{
    console.log("FilterManager::sendFilterRequests");

    [m_StatusPanel setStatus:"Sending Filter Requests"];

    [m_FilterChainsWaitingResponse removeAllObjects];
    for(var i=0; i < [m_FilterChains count]; i++)
        [m_FilterChainsWaitingResponse addObject:[m_FilterChains objectAtIndex:i]];

    for(var i=0; i < [m_FilterChains count]; i++)
        [[m_FilterChains objectAtIndex:i] sendFilterRequest];
}

- (void)onFilterRequestReceived:(id)sender
{
    [m_FilterChainsWaitingResponse removeObject:sender];

    if([m_FilterChainsWaitingResponse count] == 0)
    {
        [m_StatusPanel setStatus:"Building Filter Chains"];

        [m_FilterChainsWaitingProcess removeAllObjects];
        for(var i=0; i < [m_FilterChains count]; i++)
            [m_FilterChainsWaitingProcess addObject:[m_FilterChains objectAtIndex:i]];

        for(var i=0; i < [m_FilterChains count]; i++)
            [[m_FilterChains objectAtIndex:i] updateOverlays];
    }
}

- (void)onFilterChainProcessed:(id)sender
{
    console.log("FilterManager::onFilterChainProcessed");

    [m_FilterChainsWaitingProcess removeObject:sender];

    if([m_FilterChainsWaitingProcess count] == 0)
    {
        [m_StatusPanel setStatus:"Cleaning Up Filters"];

        var activeOverlays = [CPDictionary dictionary];
        for(var i=0; i < [m_FilterChains count]; i++)
            [activeOverlays addEntriesFromDictionary:[[m_FilterChains objectAtIndex:i] overlayIds]];

        [m_StatusPanel setStatus:"Updating Map View"];
        [m_OverlayManager updateMapView];

        if(m_Delegate && [m_Delegate respondsToSelector:@selector(onFilterManagerFinished:)])
            [m_Delegate onFilterManagerFinished:activeOverlays];
    }
}


- (id)toJson
{
    var filterJson = [];

    for(var i=0; i < [m_FilterTree count]; i++)
    {
        var curFilter = [m_FilterTree objectAtIndex:i];

        filterJson.push([self _buildFilterJson:curFilter]);
        //[{'type': theType, 'value': theValue, 'request_option': theOption, 'children' : [filter, filter, filter]}]
    }

    return filterJson;
}

- (id) _buildFilterJson:(id)curFilter
{
    var childJson = [];

    var childNodes = [curFilter childNodes];
    for(var i=0; i < [childNodes count]; i++)
    {
        childJson.push([self _buildFilterJson:[childNodes objectAtIndex:i]]);
    }

    var jsonData = [curFilter toJson];
    jsonData["children"] = childJson;

    return jsonData;
}

- (void)fromJson:(id)jsonObject
{
    [m_FilterTree removeAllObjects];

    for(var i=0; i < jsonObject.length; i++)
    {
        var curJsonFilter = jsonObject[i];

        [self _buildFilterFromJson:curJsonFilter parent:nil];
    }
}

- (void)_buildFilterFromJson:(id)jsonFilter parent:(id)parentFilter
{
    var newFilter = [self createFilter:jsonFilter.type];
    [self addFilter:newFilter parent:parentFilter];
    [newFilter fromJson:jsonFilter]; //This must come after addFilter

    var children = jsonFilter.children;
    for(var i=0; i < children.length; i++)
    {
        [self _buildFilterFromJson:children[i] parent:newFilter];
    }
}

@end
