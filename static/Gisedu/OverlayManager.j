@import <Foundation/CPObject.j>

@import "loaders/ListLoader.j"
@import "loaders/DictionaryLoader.j"

@import "PointDataObject.j"

var overlayManagerInstance = nil;

@implementation OverlayManager : CPObject
{
    MKMapView m_MapView                 @accessors(property=mapView);

    var m_BasicDataTypes                @accessors(getter=basicDataTypes);
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
        m_BasicDataTypes = ['county', 'school_district', 'house_district', 'senate_district',
                            'joint_voc_sd', 'school_itc', 'ode_class'];
        
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
    console.log([[m_PointDataTypeLists objectForKey:dataType] allKeys]);

    return [m_PointDataTypeLists objectForKey:dataType];
}

- (CPDictionary)pointDataObjects:(CPString)dataType
{
    return [m_OverlayDataObjects objectForKey:dataType];
}

- (id)getPointObject:(CPString)dataType objId:(CPInteger)objId
{
    return [[m_OverlayDataObjects objectForKey:dataType] objectForKey:objId];
}

- (void)loadPolygonOverlay:(CPString)dataType withId:(CPInteger)dataId
{
    [self loadPolygonOverlay:dataType withId:dataId andShowOnLoad:NO];
}

- (void)loadPointOverlay:(CPString)dataType withId:(CPInteger)dataId
{
    [self loadPointOverlay:dataType withId:dataId andShowOnLoad:NO];
}

- (void)loadPolygonOverlay:(CPString)dataType withId:(CPInteger)dataId andShowOnLoad:(BOOL)show
{
    var overlayDict = [self basicDataOverlayMap:dataType];

    if([overlayDict containsKey:itemId])
    {
        overlay = [overlayDict objectForKey:itemId];
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
        [overlayLoader loadAndShow:show];
    }
}

- (void)loadPointOverlay:(CPString)dataType withId:(CPInteger)dataId andShowOnLoad:(BOOL)show
{
    var curObject = [self getPointObject:dataType objId:itemId];

    //console.log("handlePointFilterResult curObject=" + curObject);

    if([curObject overlay])
    {
        [[curObject overlay] addToMapView:m_MapView];

         if([m_Delegate respondsToSelector:@selector(onPointOverlayLoaded:dataType:)])
            [m_Delegate onPointOverlayLoaded:curObject dataType:dataType];
    }
    else
    {
        [curObject loadPointOverlay:YES];
        //[[m_LeftSideTabView outlineView] addItem:[curObject name] forCategory:[curObject type]];
    }
}

- (void)onPolygonOverlayLoaded:(id)sender
{
    overlay = [sender overlay];

    [[self basicDataOverlayMap:[sender category]] setObject:overlay forKey:[overlay pk]];

    if([sender showOnLoad])
    {
        [overlay addToMapView];
    }

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
    for(var i=0; i < m_BasicDataTypes.length; i++)
    {
        var curDataType = m_BasicDataTypes[i];

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

    //console.log("OverlayDataObjects = " + [m_OverlayDataObjects]);

    if([m_Delegate respondsToSelector:@selector(onBasicDataTypeMapsLoaded:)])
        [m_Delegate onBasicDataTypeMapsLoaded:dataType];

    console.log("Finished Loading Basic Data List of Type = " + dataType + ".");
}

- (void)loadPointDataTypeLists
{
    var dataTypes = ['school', 'organization'];

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

    //console.log("pointDataTypeListLoaded =" + [sender dictionary]);

    [m_PointDataTypeLists setObject:[sender dictionary] forKey:dataType];
    [m_PointDataSubTypeLists setObject:[CPDictionary dictionary] forKey:dataType];
    [m_OverlayDataObjects setObject:[CPDictionary dictionary] forKey:dataType];

    var subDataTypes = [[sender dictionary] allKeys];

    for(var i=0; i < [subDataTypes count]; i++)
    {
        var subDataTypeId = [subDataTypes objectAtIndex:i];
        var subDataTypeName = [[sender dictionary] objectForKey:subDataTypeId];

        //console.log("SubType Loader URL = " + g_UrlPrefix + "/list/" + dataType + "/type/" + subDataTypeId);
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
    //console.log("pointSubDataTypeListLoaded =" + [sender dictionary]);
    //console.log("pointSubDataType Category = " + [sender category]);

    var subTypeList = [m_PointDataSubTypeLists objectForKey:[sender category]];
    //console.log("subTypeList = " + subTypeList);
    [subTypeList setObject:[sender dictionary] forKey:[sender subCategory]];

    [self createPointDataObjects:[sender dictionary] withDataType:[sender category]];

    //console.log("OverlayDataObjects = " + [m_OverlayDataObjects]);
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
    console.log("OverlayManager:onOrgOverlaySelected Called");

    if([m_Delegate respondsToSelector:@selector(onOrgOverlaySelected:)])
        [m_Delegate onOrgOverlaySelected:sender];
}

- (void)onSchoolOverlaySelected:(id)sender
{
    console.log("OverlayManager:onSchoolOverlaySelected Called");

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