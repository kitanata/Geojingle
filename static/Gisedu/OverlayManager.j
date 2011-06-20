@import <Foundation/CPObject.j>

@import "loaders/OrganizationTypeListLoader.j"

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

    CPDictionary m_OrganizationTypes @accessors(property=orgTypes);       //maps organization type to an array of organization names
    CPDictionary m_OrgToGid @accessors(property=orgs);                    //maps name of organization to it's primary key in the db
    CPDictionary m_OrgGidToOverlay @accessors(property=orgOverlays);      //maps the PK of the organization to a PointOverlay.

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
        m_OrgGidToOverlay = [CPDictionary dictionary];
    }

    return self;
}

- (CPArray)getOrganizationsOfType:(CPString)type
{
    return [m_OrganizationTypes objectForKey:type];
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

- (void)loadOrganizationOverlay:(CPInteger)orgId andShowOnLoad:(BOOL)show
{
    pointOverlayLoader = [[PointOverlayLoader alloc] initWithIdentifier:orgId andUrl:"http://127.0.0.1:8000/edu_org/"];
    [pointOverlayLoader setAction:@selector(onOrgOverlayLoaded:)];
    [pointOverlayLoader setTarget:self];
    [pointOverlayLoader loadAndShow:show];
}

- (void)loadOrganizationTypeList
{
    organizationTypeListLoader = [[OrganizationTypeListLoader alloc] init];
    [organizationTypeListLoader setAction:@selector(onOrgTypeListLoaded:)];
    [organizationTypeListLoader setTarget:self];
    [organizationTypeListLoader load];
}

- (void)onCountyOverlayLoaded:(id)sender
{
    overlay = [sender overlay];
    
    [m_CountyOverlays setObject:overlay forKey:[overlay pk]];

    if([sender showOnLoad])
    {
        [overlay addToMapView:m_MapView];
    }

    if([m_Delegate respondsToSelector:@selector(setCountyOverlayOnClick:)])
        [m_Delegate setCountyOverlayOnClick:overlay];
}

- (void)onOrgOverlayLoaded:(id)sender
{
    overlay = [sender overlay];

    [m_OrgGidToOverlay setObject:overlay forKey:[overlay pk]];

    if([sender showOnLoad])
    {
        [overlay addToMapView:m_MapView];
    }

    infoLoader = [[InfoWindowOverlayLoader alloc] initWithIdentifier:[overlay pk] andUrl:"http://127.0.0.1:8000/edu_org_info/"];
    [overlay setInfoLoader:infoLoader];

    if([m_Delegate respondsToSelector:@selector(setOrgOverlayOnClick:)])
        [m_Delegate setOrgOverlayOnClick:overlay];
}

- (void)onOrgTypeListLoaded:(id)sender
{
    orgTypes = [sender orgTypes];
    for(var i=0; i < [orgTypes count]; i++)
    {
        [m_OrganizationTypes setObject:[CPArray array] forKey:[orgTypes objectAtIndex:i]];

        loader = [[OrganizationListLoader alloc] initWithTypeName:[orgTypes objectAtIndex:i]];
        [loader setAction:@selector(onOrgListLoaded:)];
        [loader setTarget:self];
        [loader load];
    }

    if([m_Delegate respondsToSelector:@selector(onOrgTypeListLoaded)])
        [m_Delegate onOrgTypeListLoaded];
}

- (void)onOrgListLoaded:(id)sender
{
    [m_OrganizationTypes setObject:[[sender orgs] allKeys] forKey:[sender name]];
    [m_OrgToGid addEntriesFromDictionary:[sender orgs]];
    
    if([m_Delegate respondsToSelector:@selector(onOrgListLoaded:)])
        [m_Delegate onOrgListLoaded:[sender name]];
}

- (void)removeAllOverlaysFromMapView
{
    [self removeAllCountyOverlaysFromMapView];
    [self removeAllOrgOverlaysFromMapView];
}

- (void)removeAllCountyOverlaysFromMapView
{
    var countyOverlays = [m_CountyOverlays allValues];

    for(var i=0; i < [countyOverlays count]; i++)
    {
        [[countyOverlays objectAtIndex:i] removeFromMapView];
    }
}

- (void)removeAllOrgOverlaysFromMapView
{
    var orgOverlays = [m_OrgGidToOverlay allValues];

    for(var i=0; i < [orgOverlays count]; i++)
    {
        [[orgOverlays objectAtIndex:i] removeFromMapView];
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