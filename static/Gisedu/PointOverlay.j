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
    var m_GoogleMarker              @accessors(property=marker);

    MKLocation m_Point              @accessors(property=point);

    CPInteger m_nIdentifier         @accessors(property=pk);
    CPString m_szTitle              @accessors(property=title);
    CPString m_szIconLocation       @accessors(property=icon);          // path like "education/school"
    CPString m_szIconColor          @accessors(property=iconColor);     // the value part of g_MapIconColors "green" not "Green"
    id m_IconOptions                @accessors(property=iconOptions);   // JS object representing additional options for the icon (used with circles and rects)
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
        m_IconOptions = {
            strokeColor: "#FF0000",
            strokeOpacity: 0.8,
            strokeWeight: 2,
            fillColor: "#FF0000",
            fillOpacity: 0.35,
            radius: 100
        }
        
        m_Point = location;
        m_bVisible = NO;

        m_szIconLocation = "marker-dot";
        m_szIconColor = "red";
    }
    
    return self;
}

- (void)setIconOption:(CPString)option value:(id)value
{
    m_IconOptions[option] = value;
}

- (void)createGoogleMarker
{
    var gm = [MKMapView gmNamespace];

    if(m_szIconLocation == "circle")
        m_GoogleMarker = new gm.Circle();
    else if(m_szIconLocation == "rectangle")
        m_GoogleMarker = new gm.Rectangle();
    else
        m_GoogleMarker = new gm.Marker();

    gm.event.addListener(m_GoogleMarker, 'click', function() {[self onClick];});

    [self updateGoogleMarker];
}

- (void)updateGoogleMarker
{
    if(m_GoogleMarker)
    {
        var gm = [MKMapView gmNamespace];
        var latLng = [m_Point googleLatLng];

        var DEG_TO_METERS = 111120;
        var METERS_TO_DEG = 0.000008999;

        if(m_szIconLocation == "circle")
        {
            var circleOptions = m_IconOptions;

            circleOptions.center = latLng;
            circleOptions.clickable = true;
            circleOptions.title = m_szTitle;
            circleOptions.zIndex = 3;

            m_GoogleMarker.setOptions(circleOptions);
        }
        else if(m_szIconLocation == "rectangle")
        {
            var rectOptions = m_IconOptions;
            var radius = m_IconOptions.radius * METERS_TO_DEG;

            var rectSW = new gm.LatLng(latLng.lat() - radius, latLng.lng() - radius);
            var rectNE = new gm.LatLng(latLng.lat() + radius, latLng.lng() + radius);

            rectOptions.clickable = true;
            rectOptions.title = m_szTitle;
            rectOptions.zIndex = 2,
            rectOptions.bounds = new gm.LatLngBounds(rectSW, rectNE);

            m_GoogleMarker.setOptions(rectOptions);
        }
        else //normal marker
        {
            var markerOptions =
            {
                position: latLng,
                clickable: true,
                draggable: false,
                title: m_szTitle,
                zIndex: 4,
            };

            if(m_szIconLocation && m_szIconColor)
                markerOptions.icon = "/static/Resources/map_icons/" + m_szIconColor + "/" + m_szIconLocation + ".png";

            m_GoogleMarker.setOptions(markerOptions);
        }
    }
}

- (void)addToMapView
{
    if(m_GoogleMarker == nil)
    {
        [self createGoogleMarker];
        [self updateGoogleMarker];
    }

    m_GoogleMarker.setMap([[MKMapView getInstance] gMap]);
}

- (void)removeFromMapView
{
    if(m_GoogleMarker)
        m_GoogleMarker.setMap(null);
}

// EVENTS

- (void)onClick
{
    if([m_Delegate respondsToSelector:@selector(onClick)])
        [m_Delegate onClick];
}

@end