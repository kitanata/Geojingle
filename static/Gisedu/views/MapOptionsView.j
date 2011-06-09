@import <Foundation/CPObject.j>

@import "../OverlayManager.j"

@implementation MapOptionsView : CPView
{
    MKMapView m_MapView;
    
    CPCheckBox m_ShowCountiesCheckBox;
    CPCheckBox m_ShowSchoolDistrictsCheckBox;

    OverlayManager m_OverlayManager;
}

- (id) initWithFrame:(CGRect)aFrame andMapView:(MKMapView)mapView
{
    console.log("Initializing Map Options View");

    self = [super initWithFrame:aFrame];

    if(self)
    {
        m_MapView = mapView;

        m_OverlayManager = [OverlayManager getInstance];

        m_ShowCountiesCheckBox = [[CPCheckBox alloc] initWithFrame: CGRectMake(25, 20, 200, 40)];
        [m_ShowCountiesCheckBox setTitle:"Show All Counties"];
        [m_ShowCountiesCheckBox setState:CPOnState];
        [m_ShowCountiesCheckBox setTarget:self];
        [m_ShowCountiesCheckBox setAction:@selector(onShowCountiesChk:)];

        m_ShowSchoolDistrictsCheckBox = [[CPCheckBox alloc] initWithFrame: CGRectMake(25, 40, 200, 60)];
        [m_ShowSchoolDistrictsCheckBox setTitle:"Show All School Districts"];
        [m_ShowSchoolDistrictsCheckBox setState:CPOffState];
        [m_ShowSchoolDistrictsCheckBox setTarget:self];
        [m_ShowSchoolDistrictsCheckBox setAction:@selector(onShowSchoolDistrictsChk:)];

        [self addSubview:m_ShowCountiesCheckBox];
        [self addSubview:m_ShowSchoolDistrictsCheckBox];
    }

    console.log("Finished Initializing Map Options View");

    return self;
}

- (void)onShowCountiesChk:(id)sender
{
    pkToOverlay = [m_OverlayManager countyOverlays];
    
    if([m_ShowCountiesCheckBox state] == CPOnState)
    {
        overlays = [pkToOverlay allValues];

        for(var i=0; i < [overlays count]; i++)
        {
            [[overlays objectAtIndex:i] addToMapView:m_MapView];
        }
    }
    else if([m_ShowCountiesCheckBox state] == CPOffState)
    {
        overlays = [pkToOverlay allValues];

        for(var i=0; i < [overlays count]; i++)
        {
            [[overlays objectAtIndex:i] removeFromMapView:m_MapView];
        }
    }
}

- (void)onShowSchoolDistrictsChk:(id)sender
{
    if([m_ShowSchoolDistrictsCheckBox state] == CPOnState)
    {
        nameToPk = [m_OverlayManager schoolDistricts];
        pkToOverlay = [m_OverlayManager schoolDistrictOverlays];

        canBeLoaded = [nameToPk allValues];

        for(var i=0; i < [canBeLoaded count]; i++)
        {
            var nPk = [canBeLoaded objectAtIndex:i];

            if([pkToOverlay objectForKey:nPk] == nil)
            {
                schoolDistOverlayLoader = [[PolygonOverlayLoader alloc] initWithIdentifier:nPk andUrl:"http://127.0.0.1:8000/school_district/"];
                [schoolDistOverlayLoader setAction:@selector(onSchoolDistrictGeometryLoaded:)];
                [schoolDistOverlayLoader setTarget:self];
                [schoolDistOverlayLoader loadAndShow:NO];
            }
            else
            {
                [[pkToOverlay objectForKey:nPk] addToMapView:m_MapView];
            }
        }
    }
    else if([m_ShowSchoolDistrictsCheckBox state] == CPOffState)
    {
        pkToOverlay = [m_OverlayManager schoolDistrictOverlays];
        overlays = [pkToOverlay allValues];

        for(var i=0; i < [overlays count]; i++)
        {
            [[overlays objectAtIndex:i] removeFromMapView:m_MapView];
        }
    }
}

- (void)onSchoolDistrictGeometryLoaded:(id)sender
{
    pkToOverlay = [m_OverlayManager schoolDistrictOverlays];
    schoolDistOverlay = [sender overlay];

    [pkToOverlay setObject:schoolDistOverlay forKey:[schoolDistOverlay pk]];
    [schoolDistOverlay addToMapView:m_MapView];
}

@end