@import <Foundation/CPObject.j>

@import "loaders/ListLoader.j"
@import "loaders/DictionaryLoader.j"

//TODO: Merge these two classes together
@import "loaders/PointOverlayListLoader.j"
@import "loaders/PolygonOverlayListLoader.j"

@import "HashKit/Sha1Hash.j"

@import "FilterManager.j"
@import "PointDataObject.j"

var overlayManagerInstance = nil;

@implementation OverlayManager : CPObject
{
    MKMapView m_MapView                 @accessors(property=mapView);

    CPDictionary m_PointDataTypeLists;      //'school' : {1 : 'Elementary', 2 : 'Middle', 3 : 'High'}

    CPDictionary m_PointDataSubTypeLists;   //'school' : {1 : {10 : 'Elem School 1', 20 : 'Elem School 2', 30 : 'Elem School 3'},
                                            //                   2 : {40 : 'Middle School 1', 50 : 'Middle School 2', 60 : 'Middle School 3'},
                                            //                   3 : {70 : 'High School 1', 80 : 'High School 2', 90 : 'High School 3'}
                                            //                  }

    CPDictionary m_OverlayDataObjects;              //'school' : { 10 : <Elem School 1>, 20 : <Elem School 2>, 30 : <Elem School 3>,
                                                    //             40 : <Middle School 1>, 50 : <Middle School 2>, 60 : <Middle School 3>,
                                                    //             70 : <High School 1>, 80 : <High School 2>, 90 : <High School 3> }

    CPDictionary m_PointLoadQueue;      // {hash : {data_type : dataType, display_options : displayOptions, list : idList} }
    CPDictionary m_PolygonLoadQueue;    // where hash is "data_type" + json of display_options

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

- (void)queuePointOverlayList:(CPString)dataType withIds:(CPArray)itemIds withDisplayOptions:(id)displayOptions
{
    var hashMsg = dataType + displayOptions.toString();
    var hashType = [Sha1Hash hash:hashMsg utf8Encode:NO];

    if(![m_PointLoadQueue containsKey:hashType])
    {
        var hashObject = {
            type: dataType,
            display_options : displayOptions,
            ids : [CPSet setWithArray:itemIds]
        };

        [m_PointLoadQueue setObject:hashObject forKey:hashType];
    }
    else
    {
        var curHashObject = [m_PointLoadQueue objectForKey:hashType];
        curHashObject.ids = [curHashObject.ids setByAddingObjectsFromArray:itemIds];
        
        [m_PointLoadQueue setObject:curHashObject forKey:hashType];
    }
}

- (void)queuePolygonOverlayList:(CPString)dataType withIds:(id)itemIds withDisplayOptions:(id)displayOptions
{
    var hashMsg = dataType + displayOptions.toString();
    var hashType = [Sha1Hash hash:hashMsg utf8Encode:NO];

    if(![m_PolygonLoadQueue containsKey:hashType])
    {
        var hashObject = {
            type: dataType,
            display_options : displayOptions,
            ids : [CPSet setWithArray:itemIds]
        };

        [m_PolygonLoadQueue setObject:hashObject forKey:hashType];
    }
    else
    {
        var curHashObject = [m_PolygonLoadQueue objectForKey:hashType];
        curHashObject.ids = [curHashObject.ids setByAddingObjectsFromArray:itemIds];

        [m_PolygonLoadQueue setObject:curHashObject forKey:hashType];
    }
}

- (void)loadPointOverlayQueue
{
    var queueItems = [m_PointLoadQueue allValues];

    for(var i=0; i < [queueItems count]; i++)
    {
        var curItem = [queueItems objectAtIndex:i];

        var loaderUrl = g_UrlPrefix + "/point_geom/" + curItem.type + "/list/";
        var loader = [[PointOverlayListLoader alloc] initWithRequestUrl:loaderUrl];
        [loader setAction:@selector(onPointOverlayListLoaded:)];
        [loader setTarget:self];
        [loader setIdList:[curItem.ids allObjects]];
        [loader setDataType:curItem.type];
        [loader loadWithDisplayOptions:curItem.display_options];
    }

    [m_PointLoadQueue removeAllObjects];
}

- (void)loadPolygonOverlayQueue
{
    var queueItems = [m_PolygonLoadQueue allValues];

    for(var i=0; i < [queueItems count]; i++)
    {
        var curItem = [queueItems objectAtIndex:i];

        var loaderUrl = g_UrlPrefix + "/polygon_geom/" + curItem.type + "/list/";
        var loader = [[PolygonOverlayListLoader alloc] initWithRequestUrl:loaderUrl];
        [loader setAction:@selector(onPolygonOverlayListLoaded:)];
        [loader setTarget:self];
        [loader setIdList:[curItem.ids allObjects]];
        [loader setDataType:curItem.type];
        [loader loadWithDisplayOptions:curItem.display_options];
    }

    [m_PolygonLoadQueue removeAllObjects];
}

- (void)onPointOverlayListLoaded:(id)sender
{
    console.log("onPointOverlayListLoaded called");

    var overlays = [sender pointOverlays];
    var pointDataObjects = [m_OverlayDataObjects objectForKey:[sender dataType]];
    var overlayIds = [overlays allKeys];
    var overlayObjects = [CPArray array];

    /*console.log(m_OverlayDataObjects);
    console.log([sender dataType]);
    console.log(overlays);
    console.log(pointDataObjects);
    console.log(overlayIds);
    console.log(overlayObjects);*/

    for(var i=0; i < [overlayIds count]; i++)
    {
        var curId = [overlayIds objectAtIndex:i];
        var curObject = [pointDataObjects objectForKey:curId];
        [curObject setOverlay:[overlays objectForKey:curId]];
        [overlayObjects addObject:curObject];
    }

    if([m_Delegate respondsToSelector:@selector(onOverlayListLoaded:dataType:)])
        [m_Delegate onOverlayListLoaded:overlayObjects dataType:[sender dataType]];
}

- (void)onPolygonOverlayListLoaded:(id)sender
{
    console.log("onPolygonOverlayListLoaded called");

    var overlays = [sender polygonOverlays];
    var polygonDataObjects = [m_OverlayDataObjects objectForKey:[sender dataType]];

    var idNameMap = [[[[FilterManager getInstance] filterDescriptions] objectForKey:[sender dataType]] options];

    [polygonDataObjects addEntriesFromDictionary:overlays];

    var overlayIds = [overlays allKeys];

    for(var i=0; i < [overlayIds count]; i++)
    {
        var curOverlayId = [overlayIds objectAtIndex:i];
        var curOverlay = [overlays objectForKey:curOverlayId];
        [curOverlay setPk:curOverlayId];
        [curOverlay setName:[idNameMap objectForKey:curOverlayId]];
        [curOverlay setDelegate:m_Delegate];
        [curOverlay addToMapView];
    }

    if([m_Delegate respondsToSelector:@selector(onOverlayListLoaded:dataType:)])
        [m_Delegate onOverlayListLoaded:[overlays allValues] dataType:[sender dataType]];
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

                console.log("overlayDataObjects = "); console.log(m_OverlayDataObjects);

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

- (void)removeAllOverlaysFromMapView
{
    var overlayDicts = [m_OverlayDataObjects allValues];

    for(var i=0; i < [overlayDicts count]; i++)
    {
        var curDict = [overlayDicts objectAtIndex:i];

        [self removeDataOverlaysFromMapView:curDict];
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