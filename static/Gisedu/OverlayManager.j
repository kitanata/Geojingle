@import <Foundation/CPObject.j>

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
    CPDictionary m_Counties @accessors(property=counties);                                //Maps a County Name to it's PK
    CPDictionary m_CountyOverlays @accessors(property=countyOverlays);                    //Maps a County PK to it's Overlay

    CPDictionary m_SchoolDistricts @accessors(property=schoolDistricts);                  //Maps a School District Name with the PK
    CPDictionary m_SchoolDistrictOverlays @accessors(property=schoolDistrictOverlays);    //Maps a School District PK to the Overlay

    CPDictionary m_OrgToGid @accessors(property=orgs);                    //maps name of organization to it's primary key in the db
    CPDictionary m_OrgGidToOverlay @accessors(property=orgOverlays);      //maps the PK of the organization to a PointOverlay.
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

        m_OrgToGid = [CPDictionary dictionary];
        m_OrgGidToOverlay = [CPDictionary dictionary];
    }

    return self;
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