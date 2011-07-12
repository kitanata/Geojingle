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
    MKMapView m_MapView @accessors(property=mapView);

    CPDictionary m_Counties @accessors(property=counties);                                //Maps a County Name to it's PK
    CPDictionary m_CountyOverlays @accessors(property=countyOverlays);                    //Maps a County PK to it's Overlay

    CPDictionary m_SchoolDistricts @accessors(property=schoolDistricts);                  //Maps a School District Name with the PK
    CPDictionary m_SchoolDistrictOverlays @accessors(property=schoolDistrictOverlays);    //Maps a School District PK to the Overlay

    CPDictionary m_OrganizationTypes @accessors(property=orgTypes);       //maps organization type to an array of organization pks
    CPDictionary m_OrgToGid @accessors(property=orgNames);                //maps name of organization to it's primary key in the db
    CPDictionary m_OrgGidToOrg @accessors(property=organizations);        //maps the the organization primary key to it's object

    CPDictionary m_SchoolToGid       @accessors(property=schoolToGid);     //maps name of school to it's primary key in the db
    CPDictionary m_SchoolGidToSchool @accessors(property=schools);         //maps school pk to it's object

    CPDictionary m_SchoolTypes       @accessors(property=schoolTypes);     //each of these maps a name to an id representing the name server side
    CPDictionary m_SchoolItcTypes   @accessors(property=schoolItcTypes);
    CPDictionary m_SchoolOdeTypes   @accessors(property=schoolOdeTypes);

    id m_Delegate @accessors(property=delegate);
}

- (id)init
{
    self = [super init];

    if(self)
    {
        m_Counties = [CPDictionary dictionary];
        m_CountyOverlays = [CPDictionary dictionary];

        m_SchoolDistricts = [CPDictionary dictionary];
        m_SchoolDistrictOverlays = [CPDictionary dictionary];

        m_OrganizationTypes = [CPDictionary dictionary];

        m_OrgToGid = [CPDictionary dictionary];
        m_OrgGidToOrg = [CPDictionary dictionary];

        m_SchoolTypes = [CPDictionary dictionary];
        m_SchoolToGid = [CPDictionary dictionary];
        m_SchoolGidToSchool = [CPDictionary dictionary];

        m_SchoolItcTypes = [CPArray array];
    }

    return self;
}

- (CPArray)getOrganizationsOfType:(CPString)type
{
    return [m_OrganizationTypes objectForKey:type];
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

- (void)loadCountyOverlay:(CPInteger)countyId
{
    [self loadCountyOverlay:countyId andShowOnLoad:NO];
}

- (void)loadCountyOverlay:(CPInteger)countyId andShowOnLoad:(BOOL)show
{
    countyOverlayLoader = [[PolygonOverlayLoader alloc] initWithIdentifier:countyId andUrl:"http://127.0.0.1:8000/county/"];
    [countyOverlayLoader setAction:@selector(onCountyOverlayLoaded:)];
    [countyOverlayLoader setTarget:self];
    [countyOverlayLoader loadAndShow:show];
}

- (void)loadSchoolDistrictOverlay:(CPInteger)itemId
{
    [self loadSchoolDistrictOverlay:itemId andShowOnLoad:NO];
}

- (void)loadSchoolDistrictOverlay:(CPInteger)itemId andShowOnLoad:(BOOL)show
{
    schoolDistrictOverlayLoader = [[PolygonOverlayLoader alloc] initWithIdentifier:itemId andUrl:"http://127.0.0.1:8000/school_district/"];
    [schoolDistrictOverlayLoader setAction:@selector(onSchoolDistrictOverlayLoader:)];
    [schoolDistrictOverlayLoader setTarget:self];
    [schoolDistrictOverlayLoader loadAndShow:show];
}

- (void)loadOrganizationTypeList
{
    organizationTypeListLoader = [[ListLoader alloc] initWithUrl:"http://127.0.0.1:8000/org_type_list/"];
    [organizationTypeListLoader setAction:@selector(onOrgTypeListLoaded:)];
    [organizationTypeListLoader setTarget:self];
    [organizationTypeListLoader load];
}

- (void)loadSchoolTypeList
{
    schoolTypeListLoader = [[DictionaryLoader alloc] initWithUrl:"http://127.0.0.1:8000/school_type_list/"];
    [schoolTypeListLoader setAction:@selector(onSchoolTypeListLoaded:)];
    [schoolTypeListLoader setTarget:self];
    [schoolTypeListLoader load];
}

- (void)loadSchoolItcTypeList
{
    loader = [[DictionaryLoader alloc] initWithUrl:"http://127.0.0.1:8000/school_itc_list/"];
    [loader setAction:@selector(onSchoolItcListLoaded:)];
    [loader setTarget:self];
    [loader load];
}

- (void)loadSchoolOdeTypeList
{
    loader = [[DictionaryLoader alloc] initWithUrl:"http://127.0.0.1:8000/school_ode_list/"];
    [loader setAction:@selector(onSchoolOdeListLoaded:)];
    [loader setTarget:self];
    [loader load];
}

- (void)onCountyOverlayLoaded:(id)sender
{
    overlay = [sender overlay];

    [m_CountyOverlays setObject:overlay forKey:[overlay pk]];

    if([sender showOnLoad])
    {
        [overlay addToMapView:m_MapView];
    }

    if([m_Delegate respondsToSelector:@selector(onCountyOverlayLoaded:)])
        [m_Delegate onCountyOverlayLoaded:overlay];
}

- (void)onSchoolDistrictOverlayLoader:(id)sender
{
    overlay = [sender overlay];

    [m_SchoolDistrictOverlays setObject:overlay forKey:[overlay pk]];

    if([sender showOnLoad])
    {
        [overlay addToMapView:m_MapView];
    }

    if([m_Delegate respondsToSelector:@selector(onSchoolDistrictOverlayLoader:)])
        [m_Delegate onSchoolDistrictOverlayLoader:overlay];
}

- (void)onOrgTypeListLoaded:(id)sender
{
    orgTypes = [sender list];

    for(var i=0; i < [orgTypes count]; i++)
    {
        var curOrgType = [orgTypes objectAtIndex:i];
        [m_OrganizationTypes setObject:[CPArray array] forKey:curOrgType];

        loader = [[DictionaryLoader alloc] initWithUrl:"http://127.0.0.1:8000/org_list_by_typename/" + curOrgType];
        [loader setCategory:curOrgType];
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

    schoolTypeNames = [m_SchoolTypes allKeys];

    for(var i=0; i < [schoolTypeNames count]; i++)
    {
        var curSchoolType = [schoolTypeNames objectAtIndex:i];

        loader = [[DictionaryLoader alloc] initWithUrl:"http://127.0.0.1:8000/school_list_by_typename/" + curSchoolType];
        [loader setCategory:curSchoolType];
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
    var orgIds = [CPArray array];

    var orgDict = [sender dictionary];
    var keys = [orgDict allKeys];

    for(var i=0; i < [keys count]; i++)
    {
        var curOrgId = [keys objectAtIndex:i];
        var curOrgName = [orgDict objectForKey:curOrgId];

        [orgIds addObject:curOrgId];
        [m_OrgToGid setObject:curOrgId forKey:curOrgName];

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
    var schoolIds = [CPArray array];

    var schoolDict = [sender dictionary];
    var keys = [schoolDict allKeys];

    for(var i=0; i < [keys count]; i++)
    {
        var curSchoolId = [keys objectAtIndex:i];
        var curSchoolName = [schoolDict objectForKey:curSchoolId];

        [schoolIds addObject:curSchoolId];
        [m_SchoolToGid setObject:curSchoolId forKey:curSchoolName];

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
    [self removeAllCountyOverlaysFromMapView];
    [self removeAllSchoolDistrictOverlaysFromMapView];
    [self removeAllOrgOverlaysFromMapView];
    [self removeAllSchoolOverlaysFromMapView];
}

- (void)removeAllCountyOverlaysFromMapView
{
    var countyOverlays = [m_CountyOverlays allValues];

    for(var i=0; i < [countyOverlays count]; i++)
    {
        [[countyOverlays objectAtIndex:i] removeFromMapView];
    }
}

- (void)removeAllSchoolDistrictOverlaysFromMapView
{
    var overlays = [m_SchoolDistrictOverlays allValues];

    for(var i=0; i < [overlays count]; i++)
    {
        [[overlays objectAtIndex:i] removeFromMapView];
    }
}

- (void)removeAllOrgOverlaysFromMapView
{
    var orgOverlays = [m_OrgGidToOrg allValues];

    for(var i=0; i < [orgOverlays count]; i++)
    {
        [[[orgOverlays objectAtIndex:i] overlay] removeFromMapView];
    }
}

- (void)removeAllSchoolOverlaysFromMapView
{
    var overlays = [m_SchoolGidToSchool allValues];

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