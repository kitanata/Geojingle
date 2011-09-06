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

var DEG_TO_METERS = 111120;
var METERS_TO_DEG = 0.000008999;

@implementation PointOverlay : CPControl
{
    var m_GoogleMarker              @accessors(property=marker);

    MKLocation m_Point              @accessors(property=point);

    CPInteger m_nIdentifier         @accessors(property=pk);
    CPString m_szTitle              @accessors(property=title);
    CPString m_szMode;              //optimization

    id m_DisplayOptions             @accessors(getter=displayOptions);// JS object representing additional options for the icon (used with circles and rects)

    id m_Delegate                   @accessors(property=delegate);
}

- (id)init
{
    self = [super init];

    if(self)
    {
        m_Point = nil;

        m_DisplayOptions = {
            icon: "marker-dot",
            iconColor : "red",
            strokeColor: "#FF0000",
            strokeOpacity: 0.8,
            strokeWeight: 2,
            fillColor: "#FF0000",
            fillOpacity: 0.35,
            radius: 100,
            visible: YES
        };
    }

    return self;
}

- (id)initFromLocation:(MKLocation)location
{
    self = [self init];

    if(self)
    {
        m_Point = location;
    }
    
    return self;
}

- (void)setDisplayOptions:(id)displayOptions
{
    //Note to losers. This is a necessary psuedo-deep copy.
    m_DisplayOptions.icon = displayOptions.icon;
    m_DisplayOptions.iconColor = displayOptions.iconColor;
    m_DisplayOptions.strokeColor = displayOptions.strokeColor;
    m_DisplayOptions.strokeOpacity = displayOptions.strokeOpacity;
    m_DisplayOptions.strokeWeight = displayOptions.strokeWeight;
    m_DisplayOptions.fillColor = displayOptions.fillColor;
    m_DisplayOptions.fillOpacity = displayOptions.fillOpacity;
    m_DisplayOptions.radius = displayOptions.radius;
    m_DisplayOptions.visible = displayOptions.visible;
}

- (void)setDisplayOption:(CPString)option value:(id)value
{
    m_DisplayOptions[option] = value;
}

- (id)getDisplayOptions:(CPString)option
{
    return m_DisplayOptions[option];
}

- (BOOL)markerValid
{
    var gm = [MKMapView gmNamespace];

    if(m_DisplayOptions.icon != "circle" && m_DisplayOptions.icon != "rectangle" && m_szMode == "marker")
        return YES;
    else if(m_DisplayOptions.icon != m_szMode )
        return NO;

    return YES;
}

- (void)createGoogleMarker
{
    var gm = [MKMapView gmNamespace];

    if(m_DisplayOptions.icon == "circle")
    {
        m_GoogleMarker = new gm.Circle();
        m_szMode = "circle";
    }
    else if(m_DisplayOptions.icon == "rectangle")
    {
        m_GoogleMarker = new gm.Rectangle();
        m_szMode = "rectangle";
    }
    else
    {
        m_GoogleMarker = new gm.Marker();
        m_szMode = "marker";
    }

    gm.event.addListener(m_GoogleMarker, 'click', function() {[self onClick];});

    [self updateGoogleMarker];
}

- (void)updateGoogleMarker
{
    if(m_GoogleMarker)
    {
        var gm = [MKMapView gmNamespace];
        var latLng = [m_Point googleLatLng];

        if(m_DisplayOptions.icon == "circle")
        {
            var circleOptions = m_DisplayOptions;

            circleOptions.center = latLng;
            circleOptions.clickable = true;
            circleOptions.title = m_szTitle;
            circleOptions.zIndex = 3;

            m_GoogleMarker.setOptions(circleOptions);
        }
        else if(m_DisplayOptions.icon == "rectangle")
        {
            var rectOptions = m_DisplayOptions;
            var radius = m_DisplayOptions.radius * METERS_TO_DEG;

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

            if(m_DisplayOptions.icon && m_DisplayOptions.iconColor)
                markerOptions.icon = "/static/Resources/map_icons/" + m_DisplayOptions.iconColor + "/" + m_DisplayOptions.icon + ".png";

            m_GoogleMarker.setOptions(markerOptions);
        }

        if(m_DisplayOptions.visible)
            [self addToMapView];
        else
            [self removeFromMapView];
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