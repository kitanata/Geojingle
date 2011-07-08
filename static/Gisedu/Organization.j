@import <Foundation/CPObject.j>

@implementation Organization : CPObject
{
    CPInteger m_nIdentifier @accessors(property=pk);
    CPString m_szName       @accessors(property=name);
    CPString m_szType       @accessors(property=type);

    PointOverlayLoader m_PointLoader;
    PointOverlay m_Overlay  @accessors(property=overlay);

    InfoWindowOverlayLoader m_InfoLoader;
    InfoWindowOverlay m_InfoWindow;

    id m_Delegate           @accessors(property=delegate);
}

- (id)init
{
    self = [super init];

    if(self)
    {
        [m_Overlay setOnClickAction:@selector(onClick)];
        [m_Overlay setEventTarget:self];
    }

    return self;
}

- (id)initWithIdentifier:(CPInteger)identifier
{
    self = [self init];

    if(self)
    {
        m_nIdentifier = identifier;
    }

    return self;
}

- (void)onClick
{
    [self toggleInfoWindow];

    if([m_Delegate respondsToSelector:@selector(onOrgOverlaySelected:)])
        [m_Delegate onOrgOverlaySelected:self];
}

- (void)loadPointOverlay:(BOOL)showOnLoad
{
    m_PointLoader = [[PointOverlayLoader alloc] initWithIdentifier:m_nIdentifier andUrl:"http://127.0.0.1:8000/org_geom/"];
    [m_PointLoader setAction:@selector(onOrgOverlayLoaded:)];
    [m_PointLoader setTarget:self];
    [m_PointLoader loadAndShow:showOnLoad];
}

- (void)onOrgOverlayLoaded:(id)sender
{
    m_Overlay = [sender overlay];
    [m_Overlay setTitle:m_szName];
    [m_Overlay setDelegate:self];

    if([sender showOnLoad])
    {
        var mapView = [MKMapView getInstance];

        [m_Overlay addToMapView:mapView];
    }

    m_InfoLoader = [[InfoWindowOverlayLoader alloc] initWithIdentifier:m_nIdentifier andUrl:"http://127.0.0.1:8000/org_infobox/"];
    [m_InfoLoader setTarget:self];
    [m_InfoLoader setAction:@selector(onInfoWindowLoaded:)];

    if([m_Delegate respondsToSelector:@selector(onOrgOverlayLoaded:)])
        [m_Delegate onOrgOverlayLoaded:self];
}

- (void)onInfoWindowLoaded:(id)sender
{
    m_InfoWindow = [sender overlay];

    [m_InfoWindow open:[m_Overlay marker]];
}

- (void)openInfoWindow
{
    if(m_InfoWindow)
    {
        [m_InfoWindow open:[m_Overlay marker]];
    }
    else if(m_InfoLoader)
    {
        [m_InfoLoader load];
    }
}

- (void)closeInfoWindow
{
    if(m_InfoWindow)
    {
        [m_InfoWindow close];
    }
}

- (void)toggleInfoWindow
{
    if([m_InfoWindow opened])
    {
        [self closeInfoWindow];
    }
    else
    {
        [self openInfoWindow];
    }
}

+ (id)orgWithId:(CPInteger)id andName:(CPString)theName andType:(CPString)theType
{
    var newOrg = [[Organization alloc] init];

    [newOrg setPk:id];
    [newOrg setName:theName];
    [newOrg setType:theType];

    return newOrg;
}

@end