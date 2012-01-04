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
