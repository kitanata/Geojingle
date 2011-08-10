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

    CPDictionary m_PolygonalDataLists;                                                    //Maps a gisedu datatype to a
                                                                                          //dictionary mapping the datatype's name to it's PK
                                                                                          //in the database
                                                                                          //{'county':['Franklin':25, 'Allen' 15], 'school_district' : []...}

    CPDictionary m_PolygonalDataOverlayMaps;                                              //Maps a gisedu datatype to a
                                                                                          //dictionary mapping the datatype's name to it's Overlay

    CPDictionary m_PointDataLists;                                                        //Maps a gisedu datatype to a
                                                                                          //dictionary mapping the datatype's name to it's PK
                                                                                          //in the database

    CPDictionary m_PointDataOverlayMaps;                                                  //Maps a gisedu datatype to a
                                                                                          //dictionary mapping the datatype's name to it's Overlay


    CPDictionary m_OrgPkToName          @accessors(property=orgPkToName);                 //maps an organization PK to it's name
    CPDictionary m_OrgGidToOrg          @accessors(property=organizations);               //maps the the organization primary key to it's object

    CPDictionary m_SchoolPkToName       @accessors(property=schoolPkToName);              //maps the school's PK to it's name
    CPDictionary m_SchoolGidToSchool    @accessors(property=schools);                     //maps school pk to it's object

    CPDictionary m_OrganizationTypes    @accessors(property=orgTypes);                    //maps organization type to it's PK
    CPDictionary m_SchoolTypes          @accessors(property=schoolTypes);     //each of these maps a name to an id representing the name server side
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

        m_OrganizationTypes = [CPDictionary dictionary];
        m_OrgPkToName = [CPDictionary dictionary];
        m_OrgGidToOrg = [CPDictionary dictionary];

        m_SchoolTypes = [CPDictionary dictionary];
        m_SchoolPkToName = [CPDictionary dictionary];
        m_SchoolGidToSchool = [CPDictionary dictionary];

        m_SchoolItcTypes = [CPArray array];
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

- (id)getOrganization:(CPInteger)gid
{
    return [m_OrgGidToOrg objectForKey:gid];
}

- (id)createOrganization:(CPInteger)gid
{
    newOrg = [[Organization alloc] initWithIdentifier:gid];
    [m_OrgGidToOrg setObject:newOrg forKey:gid];
    return newOrg;
}

- (id)getSchool:(CPInteger)gid
{
    return [m_SchoolGidToSchool objectForKey:gid];
}

- (id)createSchool:(CPInteger)gid
{
    newSchool = [[School alloc] initWithIdentifier:gid];
    [m_SchoolGidToSchool setObject:newSchool forKey:gid];
    return newSchool;
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

- (void)loadOrganizationTypeList
{
    organizationTypeListLoader = [[DictionaryLoader alloc] initWithUrl:(g_UrlPrefix + "/org_type_list/")];
    [organizationTypeListLoader setAction:@selector(onOrgTypeListLoaded:)];
    [organizationTypeListLoader setTarget:self];
    [organizationTypeListLoader load];
}

- (void)loadSchoolTypeList
{
    schoolTypeListLoader = [[DictionaryLoader alloc] initWithUrl:(g_UrlPrefix + "/school_type_list/")];
    [schoolTypeListLoader setAction:@selector(onSchoolTypeListLoaded:)];
    [schoolTypeListLoader setTarget:self];
    [schoolTypeListLoader load];
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

- (void)onCountyOverlayLoaded:(id)sender
{
    overlay = [sender overlay];

    [[self polygonalDataOverlays:"county"] setObject:overlay forKey:[overlay pk]];

    if([sender showOnLoad])
    {
        [overlay addToMapView];
    }

    if([m_Delegate respondsToSelector:@selector(onCountyOverlayLoaded:)])
        [m_Delegate onCountyOverlayLoaded:overlay];
}

- (void)onSchoolDistrictOverlayLoaded:(id)sender
{
    overlay = [sender overlay];

    [[self polygonalDataOverlays:"school_district"] setObject:overlay forKey:[overlay pk]];

    if([sender showOnLoad])
    {
        [overlay addToMapView];
    }

    if([m_Delegate respondsToSelector:@selector(onSchoolDistrictOverlayLoaded:)])
        [m_Delegate onSchoolDistrictOverlayLoaded:overlay];
}

- (void)onHouseDistrictOverlayLoaded:(id)sender
{
    overlay = [sender overlay];

    [[self polygonalDataOverlays:"house_district"] setObject:overlay forKey:[overlay pk]];

    if([sender showOnLoad])
    {
        [overlay addToMapView];
    }

    if([m_Delegate respondsToSelector:@selector(onHouseDistrictOverlayLoaded:)])
        [m_Delegate onHouseDistrictOverlayLoaded:overlay];
}

- (void)onSenateDistrictOverlayLoaded:(id)sender
{
    overlay = [sender overlay];

    [[self polygonalDataOverlays:"senate_district"] setObject:overlay forKey:[overlay pk]];

    if([sender showOnLoad])
    {
        [overlay addToMapView];
    }

    if([m_Delegate respondsToSelector:@selector(onSenateDistrictOverlayLoaded:)])
        [m_Delegate onSenateDistrictOverlayLoaded:overlay];
}

- (void)onOrgTypeListLoaded:(id)sender
{
    m_OrganizationTypes = [sender dictionary];
    var orgTypeIds = [m_OrganizationTypes allValues];

    for(var i=0; i < [orgTypeIds count]; i++)
    {
        var curOrgTypeId = [orgTypeIds objectAtIndex:i];
        loader = [[DictionaryLoader alloc] initWithUrl:(g_UrlPrefix + "/org_list_by_type/" + curOrgTypeId)];
        [loader setCategory:curOrgTypeId];
        [loader setAction:@selector(onOrgListLoaded:)];
        [loader setTarget:self];
        [loader load];
    }

    if([m_Delegate respondsToSelector:@selector(onOrgTypeListLoaded)])
        [m_Delegate onOrgTypeListLoaded];
}

- (void)onSchoolTypeListLoaded:(id)sender
{
    m_SchoolTypes = [sender dictionary];
    schoolTypeIds = [m_SchoolTypes allValues];

    for(var i=0; i < [schoolTypeIds count]; i++)
    {
        var curSchoolTypeId = [schoolTypeIds objectAtIndex:i];
        loader = [[DictionaryLoader alloc] initWithUrl:(g_UrlPrefix + "/school_list_by_type/" + curSchoolTypeId)];
        [loader setCategory:curSchoolTypeId];
        [loader setAction:@selector(onSchoolListLoaded:)];
        [loader setTarget:self];
        [loader load];
    }

    if([m_Delegate respondsToSelector:@selector(onSchoolTypeListLoaded)])
        [m_Delegate onSchoolTypeListLoaded];

    console.log("Finished Loading School Type List");
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

- (void)onOrgListLoaded:(id)sender
{
    m_OrgPkToName = [sender dictionary];
    var orgIds = [m_OrgPkToName allKeys];

    for(var i=0; i < [orgIds count]; i++)
    {
        var curOrgId = [orgIds objectAtIndex:i];
        var curOrgName = [m_OrgPkToName objectForKey:curOrgId];

        var curOrg = [self createOrganization:curOrgId];
        [curOrg setName:curOrgName];
        [curOrg setType:[sender category]];
        [curOrg setDelegate:self];
    }

    if([m_Delegate respondsToSelector:@selector(onOrgListLoaded:)])
        [m_Delegate onOrgListLoaded:[sender category]];
}

- (void)onSchoolListLoaded:(id)sender
{
    m_SchoolPkToName = [sender dictionary];
    var schoolIds = [m_SchoolPkToName allKeys];

    for(var i=0; i < [schoolIds count]; i++)
    {
        var curSchoolId = [schoolIds objectAtIndex:i];
        var curSchoolName = [m_SchoolPkToName objectForKey:curSchoolId];

        var curSchool = [self createSchool:curSchoolId];
        [curSchool setName:curSchoolName];
        [curSchool setType:[sender category]];
        [curSchool setDelegate:self];
    }

    if([m_Delegate respondsToSelector:@selector(onSchoolListLoaded:)])
        [m_Delegate onSchoolListLoaded:[sender category]];
}

- (void)onOrgOverlayLoaded:(id)sender
{
    console.log("OverlayManager::onOrgOverlayLoaded Called");

    if([m_Delegate respondsToSelector:@selector(onOrgOverlayLoaded:)])
        [m_Delegate onOrgOverlayLoaded:sender];
}

- (void)onSchoolOverlayLoaded:(id)sender
{
    console.log("OverlayManager:onSchoolOverlayLoaded Called");

    if([m_Delegate respondsToSelector:@selector(onSchoolOverlayLoaded:)])
        [m_Delegate onSchoolOverlayLoaded:sender];
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

    [self removePointOverlaysFromMapView:m_OrgGidToOrg];
    [self removePointOverlaysFromMapView:m_SchoolGidToSchool];
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