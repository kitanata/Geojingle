@import <Foundation/CPObject.j>

@import "Organization.j"

@import <Foundation/CPObject.j>

@implementation School : CPObject
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

- (id)initWithIdentifier:(CPInteger)identifier
{
    self = [super init];

    if(self)
    {
        m_nIdentifier = identifier;

        [m_Overlay setOnClickAction:@selector(onClick)];
        [m_Overlay setEventTarget:self];
    }

    return self;
}

- (void)onClick
{
    [self toggleInfoWindow];
}

- (void)loadPointOverlay:(BOOL)showOnLoad
{
    m_PointLoader = [[PointOverlayLoader alloc] initWithIdentifier:m_nIdentifier andUrl:"http://127.0.0.1:8000/school_geom/"];
    [m_PointLoader setAction:@selector(onSchoolOverlayLoaded:)];
    [m_PointLoader setTarget:self];
    [m_PointLoader loadAndShow:showOnLoad];
}

- (void)onSchoolOverlayLoaded:(id)sender
{
    m_Overlay = [sender overlay];
    [m_Overlay setTitle:m_szName];
    [m_Overlay setDelegate:self];

    if([sender showOnLoad])
    {
        var mapView = [MKMapView getInstance];

        [m_Overlay addToMapView:mapView];
    }

    m_InfoLoader = [[InfoWindowOverlayLoader alloc] initWithIdentifier:m_nIdentifier andUrl:"http://127.0.0.1:8000/school_infobox/"];
    [m_InfoLoader setTarget:self];
    [m_InfoLoader setAction:@selector(onInfoWindowLoaded:)];

    if([m_Delegate respondsToSelector:@selector(onSchoolOverlayLoaded:)])
        [m_Delegate onSchoolOverlayLoaded:m_Overlay];
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

@end