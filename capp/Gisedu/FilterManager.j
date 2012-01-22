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

    CPArray m_UserFilters           @accessors(property=userFilters);   //Filters that the user declares
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
        m_UserFilters = [CPArray array];
        m_FilterChains = [CPArray array];

        m_FilterChainsWaitingResponse = [CPArray array];
        m_FilterChainsWaitingProcess = [CPArray array];

        m_FilterDescriptions = [CPDictionary dictionary];

        //[self addFilter:[self createFilter:'county'] parent:nil];
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
    if(!parent)
    {
        [m_UserFilters addObject:filter];
    }
    else if([self containsFilter:parent])
    {
        [parent insertObject:filter inChildNodesAtIndex:0];

        [filter enchantFromParents];
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
    console.log("Trigger Filters Called");

    [m_FilterChains removeAllObjects];
    [m_OverlayManager removeMapOverlays];

    [m_StatusPanel setStatus:"Building Filters"];
    [self _triggerFilters:m_UserFilters];
    [self sendFilterRequests];
}

- (void)_triggerFilters:(CPArray)filters
{
    for(var i=0; i < [filters count]; i++)
    {
        var curFilter = [filters objectAtIndex:i];

        if(![curFilter isLeaf])
        {
            [self _triggerFilters:[curFilter childNodes]];
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

- (void)sendFilterRequests
{
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

- (void)_buildFilterChain:(id)filter withChain:(GiseduFilterChain)filterChain
{
    if([filter parentNode])
        [self _buildFilterChain:[filter parentNode] withChain:filterChain];

    [filterChain addFilter:filter];
}

- (id)toJson
{
    var filterJson = [];

    for(var i=0; i < [m_UserFilters count]; i++)
    {
        var curFilter = [m_UserFilters objectAtIndex:i];

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
    [m_UserFilters removeAllObjects];

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
