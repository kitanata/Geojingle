@import <Foundation/CPObject.j>

@import "../MapKit/MKLocation.j"
@import "../MapKit/MKMarker.j"

@import "loaders/InfoWindowOverlayLoader.j"

g_IconTypes = { "Map Marker" : "marker",
                    "Map Marker With Dot" : "marker-dot",
                    "Casetta" : "casetta",
                    "Push-Pin" : "pushpin",
                    "Circle" : "circle",
                    "Rectangle" : "rectangle",
                    "Educational Icon": "education" };

g_EducationIconTypes = {"Cram/Night School" : "cramschool",
                            "Dance Class" : "dance_class",
                            "Daycare / Preschool" : "daycare",
                            "High School" : "highschool",
                            "Babysitter / Nanny" : "nanny",
                            "Baby Nursery" : "nursery",
                            "School / Academy" : "school",
                            "Summer Camp" : "summercamp",
                            "University / College" : "university" };

g_MapIconColors = { "Black" : "black",
                        "Blue" : "blue",
                        "Green" : "green",
                        "Grey" : "grey",
                        "Purple" : "purple",
                        "Red" : "red",
                        "White" : "white",
                        "Yellow" : "yellow" };

@implementation PointOverlay : CPControl
{
    Marker m_GoogleMarker           @accessors(property=marker);

    MKLocation m_Point              @accessors(property=point);

    CPInteger m_nIdentifier         @accessors(property=pk);
    CPString m_szTitle              @accessors(property=title);
    CPString m_szIconLocation       @accessors(property=icon);          // path like "education/school"
    CPString m_szIconColor          @accessors(property=iconColor);     // the value part of g_MapIconColors "green" not "Green"
    BOOL m_bVisible                 @accessors(property=visible);

    id m_Delegate                   @accessors(property=delegate);
}

- (id)init
{
    self = [super init];

    if(self)
    {
        m_Point = nil;
        m_bVisible = NO;
    }

    return self;
}

- (id)initFromLocation:(MKLocation)location
{
    self = [self init];

    if(self)
    {
        m_Point = location;
        m_bVisible = NO;

        m_szIconLocation = "marker-dot";
        m_szIconColor = "red";
    }
    
    return self;
}

- (void)createGoogleMarker
{
    var gm = [MKMapView gmNamespace];
    var latLng = [m_Point googleLatLng];

    var markerOptions =
    {
        position: latLng,
        clickable: true,
        draggable: false,
        title: m_szTitle
    };

    if(m_szIconLocation && m_szIconColor)
        markerOptions.icon = "/static/Resources/map_icons/" + m_szIconColor + "/" + m_szIconLocation + ".png";

    m_GoogleMarker = new gm.Marker(markerOptions);

    gm.event.addListener(m_GoogleMarker, 'click', function() {[self onClick];});
}

- (void)updateGoogleMarker
{
    [self removeFromMapView];

    m_GoogleMarker = nil;

    [self addToMapView];
}

- (void)addToMapView
{
    if(m_GoogleMarker == nil)
    {
        [self createGoogleMarker];
    }

    var mapView = [MKMapView getInstance];

    m_GoogleMarker.setMap([mapView gMap]);
}

- (void)removeFromMapView
{
    m_GoogleMarker.setMap(null);
}

// EVENTS

- (void)onClick
{
    if([m_Delegate respondsToSelector:@selector(onClick)])
        [m_Delegate onClick];
}

@end