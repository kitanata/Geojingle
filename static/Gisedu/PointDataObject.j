@import <Foundation/CPObject.j>

//More of a manager for a point overlay, markers, infowindows, handles loading, etc
@implementation PointDataObject : CPObject
{
    CPInteger m_nIdentifier @accessors(property=pk);
    CPString m_szName       @accessors(property=name);
    CPString m_szType       @accessors(property=type);
    CPString m_szDataType   @accessors(property=dataType); //'organization', 'school', 'joint_voc_sd' etc

    PointOverlayLoader m_PointLoader;
    PointOverlay m_Overlay  @accessors(getter=overlay);

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

- (void)loadWithDisplayOptions:(id)displayOptions
{
    var loaderUrl = g_UrlPrefix + "/point_geom/" + m_szDataType + "/id/" + m_nIdentifier;
    m_PointLoader = [[PointOverlayLoader alloc] initWithRequestUrl:loaderUrl];
    [m_PointLoader setAction:@selector(onPointGeomLoaded:)];
    [m_PointLoader setTarget:self];
    [m_PointLoader loadWithDisplayOptions:displayOptions];
}

- (void)onPointGeomLoaded:(id)sender
{
    m_Overlay = [sender overlay];
    [m_Overlay setTitle:m_szName];
    [m_Overlay setDelegate:self];

    [m_Overlay addToMapView];

    var loaderUrl = g_UrlPrefix + "/point_infobox/" + m_szDataType + "/id/" + m_nIdentifier;
    m_InfoLoader = [[InfoWindowOverlayLoader alloc] initWithRequestUrl:loaderUrl];
    [m_InfoLoader setTarget:self];
    [m_InfoLoader setAction:@selector(onInfoWindowLoaded:)];

    if([m_Delegate respondsToSelector:@selector(onPointGeomLoaded:)])
        [m_Delegate onPointGeomLoaded:self];
}

- (void)setOverlay:(id)overlay
{
    m_Overlay = overlay;
    [m_Overlay setTitle:m_szName];
    [m_Overlay setDelegate:self];

    [m_Overlay addToMapView];

    var loaderUrl = g_UrlPrefix + "/point_infobox/" + m_szDataType + "/id/" + m_nIdentifier;
    m_InfoLoader = [[InfoWindowOverlayLoader alloc] initWithRequestUrl:loaderUrl];
    [m_InfoLoader setTarget:self];
    [m_InfoLoader setAction:@selector(onInfoWindowLoaded:)];
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

- (void)removeFromMapView
{
    if(m_Overlay)
        [m_Overlay removeFromMapView];
}

+ (id)pointDataObjectWithIdentifier:(CPInteger)id dataType:(CPString)dataType
{
    var newDataObject = [[PointDataObject alloc] init];

    [newDataObject setPk:id];
    [newDataObject setDataType:dataType];

    return newDataObject;
}

@end