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

@import "loaders/ListLoader.j"
@import "loaders/DictionaryLoader.j"

//TODO: Merge these two classes together
@import "loaders/PointOverlayListLoader.j"
@import "loaders/PolygonOverlayListLoader.j"

@import "HashKit/Sha1Hash.j"
@import "HashKit/BloomFilter.j"

@import "FilterManager.j"
@import "PointDataObject.j"

var overlayManagerInstance = nil;

@implementation OverlayManager : CPObject
{
    id m_StatusPanel                    @accessors(setter=setStatusPanel:);
    MKMapView m_MapView                 @accessors(property=mapView);

    CPDictionary m_PointDataTypeLists;      //'school' : {1 : 'Elementary', 2 : 'Middle', 3 : 'High'}

    CPDictionary m_PointDataSubTypeLists;   //'school' : {1 : {10 : 'Elem School 1', 20 : 'Elem School 2', 30 : 'Elem School 3'},
                                            //                   2 : {40 : 'Middle School 1', 50 : 'Middle School 2', 60 : 'Middle School 3'},
                                            //                   3 : {70 : 'High School 1', 80 : 'High School 2', 90 : 'High School 3'}
                                            //                  }

    CPDictionary m_OverlayDataObjects;              //'school' : { 10 : <Elem School 1>, 20 : <Elem School 2>, 30 : <Elem School 3>,
                                                    //             40 : <Middle School 1>, 50 : <Middle School 2>, 60 : <Middle School 3>,
                                                    //             70 : <High School 1>, 80 : <High School 2>, 90 : <High School 3> }


    CPArray     m_PrevMapOverlays;
    CPArray     m_MapOverlays;

    BloomFilter m_PrevMapOverlaysBF;          //Overlays shown on the previous map's update
    BloomFilter m_MapOverlaysBF;              //Overlays shown on current on this map's update

    id m_Delegate @accessors(property=delegate);
}

- (id)init
{
    self = [super init];

    if(self)
    {
        m_PointDataTypeLists = [CPDictionary dictionary];
        m_PointDataSubTypeLists = [CPDictionary dictionary];

        m_OverlayDataObjects = [CPDictionary dictionary];

        m_PointLoadQueue = [CPDictionary dictionary];
        m_PolygonLoadQueue = [CPDictionary dictionary];

        m_PrevMapOverlays = [CPArray array];
        m_MapOverlays = [CPArray array];

        m_PrevMapOverlaysBF = [[BloomFilter alloc] init];
        m_MapOverlaysBF = [[BloomFilter alloc] init];
    }

    return self;
}

- (CPDictionary)basicDataOverlayMap:(CPString)dataType
{
    return [m_OverlayDataObjects objectForKey:dataType];
}

- (CPDictionary)pointDataTypes:(CPString)dataType
{
    return [m_PointDataTypeLists objectForKey:dataType];
}

- (id)getOverlayObject:(CPString)dataType objId:(CPInteger)objId
{
    return [[m_OverlayDataObjects objectForKey:dataType] objectForKey:objId];
}

- (void)onFilterDescriptionsLoaded
{
    var filterDescriptions = [[[FilterManager getInstance] filterDescriptions] allValues];

    for(var i=0; i < [filterDescriptions count]; i++)
    {
        var curFilterDesc = [filterDescriptions objectAtIndex:i];
        var dataDict = [curFilterDesc options];
        var filterId = [curFilterDesc id];
        var filterDataType = [curFilterDesc dataType];
        var filterFilterType = [curFilterDesc filterType];

        if(filterDataType == "POINT")
        {
            if(filterFilterType == "DICT")
            {
                [m_PointDataTypeLists setObject:dataDict forKey:filterId];
                [m_OverlayDataObjects setObject:[CPDictionary dictionary] forKey:filterId];

                var subDataTypes = [dataDict allKeys];

                for(var j=0; j < [subDataTypes count]; j++)
                {
                    var subDataTypeName = [subDataTypes objectAtIndex:j];
                    var subDataTypeDict = [dataDict objectForKey:subDataTypeName];

                    [self createPointDataObjects:subDataTypeDict withDataType:filterId];
                }
            }
            else if(filterFilterType == "LIST")
            {
                [m_OverlayDataObjects setObject:[CPDictionary dictionary] forKey:filterId];

                [self createPointDataObjects:dataDict withDataType:filterId];
            }
        }
        else if(filterDataType == "POLYGON")
        {
            if(filterFilterType == "LIST")
            {
                [m_OverlayDataObjects setObject:[CPDictionary dictionary] forKey:filterId];

                //console.log("overlayDataObjects = "); console.log(m_OverlayDataObjects);

                if([m_Delegate respondsToSelector:@selector(onBasicDataTypeMapsLoaded:)])
                    [m_Delegate onBasicDataTypeMapsLoaded:filterId];

                console.log("Finished Loading Basic Data List of Type = " + [curFilterDesc name] + ".");
            }
        }
    }
}

- (void)createPointDataObjects:(CPDictionary)dictionary withDataType:(CPString)dataType
{
    var idToObjDict = [m_OverlayDataObjects objectForKey:dataType];

    var ids = [dictionary allKeys];

    for(var i=0; i < [ids count]; i++)
    {
        var curId = [ids objectAtIndex:i];
        var curName = [dictionary objectForKey:curId];

        var newObject = [PointDataObject pointDataObjectWithIdentifier:curId dataType:dataType];

        if(newObject)
        {
            [newObject setName:curName];
            [newObject setType:dataType];

            [newObject setDelegate:self];
            [idToObjDict setObject:newObject forKey:curId];
        }
    }
}

- (void)onPointOverlaySelected:(id)sender
{
    if([m_Delegate respondsToSelector:@selector(onPointOverlaySelected:)])
        [m_Delegate onPointOverlaySelected:sender];
}

/* Adds a overlay to the list of currently displayed map items */
- (void)addMapOverlay:(id)overlay
{
    [m_MapOverlays addObject:overlay];
    [m_MapOverlaysBF add:overlay.toString()];
}

/* Does not remove overlays from the map... this simply moves
    the list of overlays currently on the map into the previous list
    then clears the current list: See updateMapView */
- (void)removeMapOverlays
{
    m_PrevMapOverlaysBF = m_MapOverlaysBF;
    m_MapOverlaysBF = [[BloomFilter alloc] init];

    m_PrevMapOverlays = m_MapOverlays;
    m_MapOverlays = [CPArray array];
}

/* Updates the mapview by adding and removing overlays
    based on what was shown on the previous update
    and what should be shown now. 
    i.e. Removes stale overlays. Adds brand new ones.
    
    Percieved Speed Optimization: Previously all overlays
    were cleared then re-added. This will keep still relvant
    overlays on the map during the update process.
*/
- (void)updateMapView
{
    //remove stale
    [m_StatusPanel setStatus:"Removing State Overlays"];
    for(var i=0; i < [m_PrevMapOverlays count]; i++)
    {
        var curOverlay = [m_PrevMapOverlays objectAtIndex:i];

        if(![m_MapOverlaysBF test:curOverlay.toString()])
            [curOverlay removeFromMapView];
    }

    //add new
    [m_StatusPanel setStatus:"Applying New Overlays"];
    for(var i=0; i < [m_MapOverlays count]; i++)
    {
        var curOverlay = [m_MapOverlays objectAtIndex:i];

        [curOverlay update];

        if(![m_PrevMapOverlaysBF test:curOverlay.toString()])
            [curOverlay addToMapView];
    }
}

- (void)removeDataOverlaysFromMapView:(CPDictionary)overlayDict
{
    var overlays = [overlayDict allValues];

    for(var i=0; i < [overlays count]; i++)
    {
        [[overlays objectAtIndex:i] removeFromMapView];
    }
}

+ (OverlayManager)getInstance
{
    if(overlayManagerInstance == nil)
    {
        overlayManagerInstance = [[OverlayManager alloc] init];
    }

    return overlayManagerInstance;
}

@end
