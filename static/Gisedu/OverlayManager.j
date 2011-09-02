@import <Foundation/CPObject.j>

@import "loaders/ListLoader.j"
@import "loaders/DictionaryLoader.j"

@import "FilterManager.j"
@import "PointDataObject.j"

var overlayManagerInstance = nil;

@implementation OverlayManager : CPObject
{
    MKMapView m_MapView                 @accessors(property=mapView);

    CPDictionary m_BasicDataTypeMap;            //Maps a gisedu datatype to a dictionary mapping the datatype's name to it's PK
                                                //in the database {'county':{'Franklin':25, 'Allen':15}, 'school_district' : {}...}

    CPDictionary m_PointDataTypeLists;      //'school' : {1 : 'Elementary', 2 : 'Middle', 3 : 'High'}

    CPDictionary m_PointDataSubTypeLists;   //'school' : {1 : {10 : 'Elem School 1', 20 : 'Elem School 2', 30 : 'Elem School 3'},
                                            //                   2 : {40 : 'Middle School 1', 50 : 'Middle School 2', 60 : 'Middle School 3'},
                                            //                   3 : {70 : 'High School 1', 80 : 'High School 2', 90 : 'High School 3'}
                                            //                  }

    CPDictionary m_OverlayDataObjects;      //'school' : { 10 : <Elem School 1>, 20 : <Elem School 2>, 30 : <Elem School 3>,
                                            //             40 : <Middle School 1>, 50 : <Middle School 2>, 60 : <Middle School 3>,
                                            //             70 : <High School 1>, 80 : <High School 2>, 90 : <High School 3> }

    id m_Delegate @accessors(property=delegate);
}

- (id)init
{
    self = [super init];

    if(self)
    {
        m_BasicDataTypeMap = [CPDictionary dictionary];

        m_PointDataTypeLists = [CPDictionary dictionary];
        m_PointDataSubTypeLists = [CPDictionary dictionary];

        m_OverlayDataObjects = [CPDictionary dictionary];
    }

    return self;
}

- (CPDictionary)basicDataTypeMap:(CPString)dataType
{
    return [m_BasicDataTypeMap objectForKey:dataType];
}

- (CPDictionary)basicDataOverlayMap:(CPString)dataType
{
    return [m_OverlayDataObjects objectForKey:dataType];
}

- (CPDictionary)pointDataTypes:(CPString)dataType
{
    return [m_PointDataTypeLists objectForKey:dataType];
}

- (CPDictionary)pointDataObjects:(CPString)dataType
{
    return [m_OverlayDataObjects objectForKey:dataType];
}

- (id)getOverlayObject:(CPString)dataType objId:(CPInteger)objId
{
    return [[m_OverlayDataObjects objectForKey:dataType] objectForKey:objId];
}

- (void)loadPolygonOverlay:(CPString)dataType withId:(CPInteger)dataId
{
    [self loadPolygonOverlay:dataType withId:dataId withDisplayOptions:nil];
}

- (void)loadPointOverlay:(CPString)dataType withId:(CPInteger)dataId
{
    [self loadPointOverlay:dataType withId:dataId withDisplayOptions:nil];
}

- (void)loadPolygonOverlay:(CPString)dataType withId:(CPInteger)dataId withDisplayOptions:(id)displayOptions
{
    var overlayDict = [self basicDataOverlayMap:dataType];

    if([overlayDict containsKey:dataId])
    {
        overlay = [overlayDict objectForKey:dataId];
        [overlay addToMapView];

        if([m_Delegate respondsToSelector:@selector(onPolygonOverlayLoaded:dataType:)])
            [m_Delegate onPolygonOverlayLoaded:overlay dataType:dataType];
    }
    else
    {
        overlayLoader = [[PolygonOverlayLoader alloc] initWithIdentifier:dataId andUrl:(g_UrlPrefix + "/" + dataType + "/")];
        [overlayLoader setAction:@selector(onPolygonOverlayLoaded:)];
        [overlayLoader setCategory:dataType];
        [overlayLoader setTarget:self];
        [overlayLoader loadWithDisplayOptions:displayOptions];
    }
}

- (void)loadPointOverlay:(CPString)dataType withId:(CPInteger)dataId withDisplayOptions:(id)displayOptions
{
    var curObject = [self getOverlayObject:dataType objId:dataId];

    if([curObject overlay])
    {
        [[curObject overlay] addToMapView];

         if([m_Delegate respondsToSelector:@selector(onPointOverlayLoaded:dataType:)])
            [m_Delegate onPointOverlayLoaded:curObject dataType:dataType];
    }
    else
    {
        [curObject loadWithDisplayOptions:displayOptions];
    }
}

- (void)onPolygonOverlayLoaded:(id)sender
{
    overlay = [sender overlay];

    [[self basicDataOverlayMap:[sender category]] setObject:overlay forKey:[overlay pk]];

    [overlay addToMapView];

    if([m_Delegate respondsToSelector:@selector(onPolygonOverlayLoaded:dataType:)])
        [m_Delegate onPolygonOverlayLoaded:overlay dataType:[sender category]];
}

- (void)onPointGeomLoaded:(id)sender
{
    if([m_Delegate respondsToSelector:@selector(onPointOverlayLoaded:dataType:)])
            [m_Delegate onPointOverlayLoaded:sender dataType:[sender type]];
}

- (void)loadBasicDataTypeMaps
{
    var listBasedFilterTypes = [[FilterManager getInstance] listBasedFilterTypes];

    for(var i=0; i < listBasedFilterTypes.length; i++)
    {
        var curDataType = listBasedFilterTypes[i];

        var loader = [[DictionaryLoader alloc] initWithUrl:(g_UrlPrefix + "/list/" + curDataType)];
        [loader setCategory:curDataType];
        [loader setAction:@selector(onBasicDataTypeMapsLoaded:)];
        [loader setTarget:self];
        [loader load];
    }
}

- (void)onBasicDataTypeMapsLoaded:(id)sender
{
    var dataType = [sender category];
    var dataTypeMap = [sender dictionary];

    [m_BasicDataTypeMap setObject:dataTypeMap forKey:dataType];
    [m_OverlayDataObjects setObject:[CPDictionary dictionary] forKey:dataType];

    if(dataType == "joint_voc_sd")
        [self createPointDataObjects:dataTypeMap withDataType:dataType];

    if([m_Delegate respondsToSelector:@selector(onBasicDataTypeMapsLoaded:)])
        [m_Delegate onBasicDataTypeMapsLoaded:dataType];

    console.log("Finished Loading Basic Data List of Type = " + dataType + ".");
}

- (void)loadPointDataTypeLists
{
    var dataTypes = [[FilterManager getInstance] pointFilterTypes];

    for(var i=0; i < dataTypes.length; i++)
    {
        var curDataType = dataTypes[i];

        var loader = [[DictionaryLoader alloc] initWithUrl:(g_UrlPrefix + "/list/" + curDataType)];
        [loader setCategory:curDataType];
        [loader setAction:@selector(onPointDataTypeListLoaded:)];
        [loader setTarget:self];
        [loader load];
    }
}

- (void)onPointDataTypeListLoaded:(id)sender
{
    var dataType = [sender category];

    [m_PointDataTypeLists setObject:[sender dictionary] forKey:dataType];
    [m_PointDataSubTypeLists setObject:[CPDictionary dictionary] forKey:dataType];
    [m_OverlayDataObjects setObject:[CPDictionary dictionary] forKey:dataType];

    var subDataTypes = [[sender dictionary] allKeys];

    for(var i=0; i < [subDataTypes count]; i++)
    {
        var subDataTypeId = [subDataTypes objectAtIndex:i];
        var subDataTypeName = [[sender dictionary] objectForKey:subDataTypeId];

        loader = [[DictionaryLoader alloc] initWithUrl:(g_UrlPrefix + "/list/" + dataType + "/type/" + subDataTypeId)];
        [loader setCategory:dataType];
        [loader setSubCategory:subDataTypeId];
        [loader setAction:@selector(onPointSubDataTypeListLoaded:)];
        [loader setTarget:self];
        [loader load];
    }
}

- (void)onPointSubDataTypeListLoaded:(id)sender
{
    var subTypeList = [m_PointDataSubTypeLists objectForKey:[sender category]];
    [subTypeList setObject:[sender dictionary] forKey:[sender subCategory]];

    [self createPointDataObjects:[sender dictionary] withDataType:[sender category]];
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

- (void)onOrgOverlaySelected:(id)sender
{
    if([m_Delegate respondsToSelector:@selector(onOrgOverlaySelected:)])
        [m_Delegate onOrgOverlaySelected:sender];
}

- (void)onSchoolOverlaySelected:(id)sender
{
    if([m_Delegate respondsToSelector:@selector(onSchoolOverlaySelected:)])
        [m_Delegate onSchoolOverlaySelected:sender];
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