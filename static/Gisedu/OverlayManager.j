@import <Foundation/CPObject.j>

@import "loaders/ListLoader.j"
@import "loaders/DictionaryLoader.j"

@import "School.j"

//IMPORTANT ************************************************************************************************************
// Hi! You may be wondering why there are three separate variables tracking these items(two here and one in app controller).
// Why do we need all these? Well the reason is two fold first the outline view works best with arrays of strings, which explains
// m_CountyItems in AppController.j.
// Second, the variables here is a speed optimization. The idea is only to load the information we need as we need it. For example
// At first we just get a list of the school districts(m_SchoolDistricts) which tells us the name of the district and the PK needed
// for loading more information. When a user attempts to display a school district overlay we check if it exists. If it doesn't we
// load the geometry for the district and put it in the *Overlays dictionary, which maps the PK we just used to the overlay data.
// It is completely possible that the *Overlays only has 1 or 2 items whereas the Name=>PK Mapping tends to have everything loaded
// ready for selection. This same process works pretty much for verbatium for everything you see in the outline view.
//**********************************************************************************************************************

var overlayManagerInstance = nil;

@implementation OverlayManager : CPObject
{
    MKMapView m_MapView                 @accessors(property=mapView);

    CPDictionary m_PolygonalDataLists;  //Maps a gisedu datatype to a dictionary mapping the datatype's name to it's PK
                                        //in the database {'county':{'Franklin':25, 'Allen':15}, 'school_district' : {}...}
    CPDictionary m_PolygonalDataOverlayMaps;    //Maps a gisedu datatype to a dictionary mapping the datatype's name to it's Overlay

    CPDictionary m_PointDataTypeLists;      //'school' : {1 : 'Elementary', 2 : 'Middle', 3 : 'High'}

    CPDictionary m_PointDataSubTypeLists;   //'school' : {1 : {10 : 'Elem School 1', 20 : 'Elem School 2', 30 : 'Elem School 3'},
                                            //                   2 : {40 : 'Middle School 1', 50 : 'Middle School 2', 60 : 'Middle School 3'},
                                            //                   3 : {70 : 'High School 1', 80 : 'High School 2', 90 : 'High School 3'}
                                            //                  }

    CPDictionary m_PointDataObjects;        //'school' : { 10 : <Elem School 1>, 20 : <Elem School 2>, 30 : <Elem School 3>,
                                            //             40 : <Middle School 1>, 50 : <Middle School 2>, 60 : <Middle School 3>,
                                            //             70 : <High School 1>, 80 : <High School 2>, 90 : <High School 3> }

    CPDictionary m_SchoolItcTypes       @accessors(property=schoolItcTypes);
    CPDictionary m_SchoolOdeTypes       @accessors(property=schoolOdeTypes);

    id m_Delegate @accessors(property=delegate);
}

- (id)init
{
    self = [super init];

    if(self)
    {
        m_PolygonalDataLists = [CPDictionary dictionary];
        m_PolygonalDataOverlayMaps = [CPDictionary dictionary];

        m_PointDataTypeLists = [CPDictionary dictionary];
        m_PointDataSubTypeLists = [CPDictionary dictionary];
        m_PointDataObjects = [CPDictionary dictionary];

        m_SchoolItcTypes = [CPArray array];
        m_SchoolOdeTypes = [CPArray array];
    }

    return self;
}

- (CPDictionary)polygonalDataList:(CPString)dataType
{
    return [m_PolygonalDataLists objectForKey:dataType];
}

- (CPDictionary)polygonalDataOverlays:(CPString)dataType
{
    return [m_PolygonalDataOverlayMaps objectForKey:dataType];
}

- (CPDictionary)pointDataTypes:(CPString)dataType
{
    console.log([[m_PointDataTypeLists objectForKey:dataType] allKeys]);

    return [m_PointDataTypeLists objectForKey:dataType];
}

- (CPDictionary)pointDataObjects:(CPString)dataType
{
    return [m_PointDataObjects objectForKey:dataType];
}

- (id)getPointObject:(CPString)dataType objId:(CPInteger)objId
{
    return [[m_PointDataObjects objectForKey:dataType] objectForKey:objId];
}

- (void)loadPolygonOverlay:(CPString)dataType withId:(CPInteger)dataId
{
    [self loadOverlay:dataType withId:dataId andShowOnLoad:NO];
}

- (void)loadPolygonOverlay:(CPString)dataType withId:(CPInteger)dataId andShowOnLoad:(BOOL)show
{
    overlayLoader = [[PolygonOverlayLoader alloc] initWithIdentifier:dataId andUrl:(g_UrlPrefix + "/" + dataType + "/")];
    [overlayLoader setAction:@selector(onPolygonOverlayLoaded:)];
    [overlayLoader setCategory:dataType];
    [overlayLoader setTarget:self];
    [overlayLoader loadAndShow:show];
}

- (void)onPolygonOverlayLoaded:(id)sender
{
    overlay = [sender overlay];

    [[self polygonalDataOverlays:[sender category]] setObject:overlay forKey:[overlay pk]];

    if([sender showOnLoad])
    {
        [overlay addToMapView];
    }

    if([m_Delegate respondsToSelector:@selector(onPolygonOverlayLoaded:dataType:)])
        [m_Delegate onPolygonOverlayLoaded:overlay dataType:[sender category]];
}

- (void)loadSchoolItcTypeList
{
    loader = [[DictionaryLoader alloc] initWithUrl:(g_UrlPrefix + "/school_itc_list/")];
    [loader setAction:@selector(onSchoolItcListLoaded:)];
    [loader setTarget:self];
    [loader load];
}

- (void)loadSchoolOdeTypeList
{
    loader = [[DictionaryLoader alloc] initWithUrl:(g_UrlPrefix + "/school_ode_list/")];
    [loader setAction:@selector(onSchoolOdeListLoaded:)];
    [loader setTarget:self];
    [loader load];
}

- (void)loadPolygonalDataLists
{
    var dataTypes = ['county', 'school_district', 'house_district', 'senate_district'];

    for(var i=0; i < dataTypes.length; i++)
    {
        var curDataType = dataTypes[i];

        var loader = [[DictionaryLoader alloc] initWithUrl:(g_UrlPrefix + "/list/" + curDataType)];
        [loader setCategory:curDataType];
        [loader setAction:@selector(onPolygonalDataListLoaded:)];
        [loader setTarget:self];
        [loader load];
    }
}

- (void)onPolygonalDataListLoaded:(id)sender
{
    var dataType = [sender category];

    [m_PolygonalDataLists setObject:[sender dictionary] forKey:dataType];
    [m_PolygonalDataOverlayMaps setObject:[CPDictionary dictionary] forKey:dataType];

    if([m_Delegate respondsToSelector:@selector(onPolygonalDataListLoaded:)])
        [m_Delegate onPolygonalDataListLoaded:dataType];

    console.log("Finished Loading Polygonal Data List of Type = " + dataType + ".");
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
    [m_PointDataObjects setObject:[CPDictionary dictionary] forKey:dataType];

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
    var idToObjDict = [m_PointDataObjects objectForKey:[sender category]];
    //console.log("idToObjDict = " + idToObjDict);

    var ids = [[sender dictionary] allKeys];
    for(var i=0; i < [ids count]; i++)
    {
        var curId = [ids objectAtIndex:i];
        var curName = [[sender dictionary] objectForKey:curId];

        var newObject = nil;

        if([sender category] == "organization")
            newObject = [[Organization alloc] initWithIdentifier:curId];
        else if([sender category] == "school")
            newObject = [[School alloc] initWithIdentifier:curId];

        if(newObject)
        {
            [newObject setName:curName];
            [newObject setType:[sender subCategory]];
            [newObject setDelegate:self];
            [idToObjDict setObject:newObject forKey:curId];
        }
    }
}

- (void)onSchoolItcListLoaded:(id)sender
{
    m_SchoolItcTypes = [sender dictionary];

    if([m_Delegate respondsToSelector:@selector(onSchoolItcListLoaded)])
        [m_Delegate onSchoolItcListLoaded];

    console.log("Finished Loading School ITC List");
}

- (void)onSchoolOdeListLoaded:(id)sender
{
    m_SchoolOdeTypes = [sender dictionary];

    if([m_Delegate respondsToSelector:@selector(onSchoolOdeListLoaded)])
        [m_Delegate onSchoolOdeListLoaded];

    console.log("Finished Loading School ODE Classification List");
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
    var polygonOverlayDicts = [m_PolygonalDataOverlayMaps allValues];

    for(var i=0; i < [polygonOverlayDicts count]; i++)
    {
        var curDict = [polygonOverlayDicts objectAtIndex:i];

        [self removePolygonOverlaysFromMapView:curDict];
    }

    var pointOverlayDicts = [m_PointDataObjects allValues];

    for(var i=0; i < [pointOverlayDicts count]; i++)
    {
        var curDict = [pointOverlayDicts objectAtIndex:i];

        [self removePointOverlaysFromMapView:curDict];
    }
}

- (void)removePolygonOverlaysFromMapView:(CPDictionary)overlayDict
{
    var overlays = [overlayDict allValues];

    for(var i=0; i < [overlays count]; i++)
    {
        [[overlays objectAtIndex:i] removeFromMapView];
    }
}

- (void)removePointOverlaysFromMapView:(CPDictionary)overlayDict
{
    var overlays = [overlayDict allValues];

    for(var i=0; i < [overlays count]; i++)
    {
        [[[overlays objectAtIndex:i] overlay] removeFromMapView];
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