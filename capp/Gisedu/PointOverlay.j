/***** BEGIN LICENSE BLOCK *****
* Version: MPL 1.1/GPL 2.0/LGPL 2.1
*
* The Gisedu project is subject to the Mozilla Public License Version
* 1.1 (the "License"); you may not use any content of the Gisedu project
* except in compliance with the License. You may obtain a copy of the License at
* http://www.mozilla.org/MPL/
*
* Software distributed under the License is distributed on an "AS IS" basis,
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
* for the specific language governing rights and limitations under the
* License.
*
* The Original Code is the "Gisedu Project".
*
* The Initial Developer of the Original Code is "eTech Ohio Commission".
* Portions created by the Initial Developer are Copyright (C) 2011
* the Initial Developer. All Rights Reserved.
*
* Contributor(s):
*      Raymond E Chandler III
*
* Alternatively, the contents of this project may be used under the terms of
* either the GNU General Public License Version 2 or later (the "GPL"), or
* the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
* in which case the provisions of the GPL or the LGPL are applicable instead
* of those above. If you wish to allow use of your version of this file only
* under the terms of either the GPL or the LGPL, and not to allow others to
* use your version of this file under the terms of the MPL, indicate your
* decision by deleting the provisions above and replace them with the notice
* and other provisions required by the GPL or the LGPL. If you do not delete
* the provisions above, a recipient may use your version of this file under
* the terms of any one of the MPL, the GPL or the LGPL.
*
* ***** END LICENSE BLOCK ***** */
@import <Foundation/CPObject.j>

@import "MapOverlay.j"
@import "MapKit/MKLocation.j"
@import "MapKit/MKMarker.j"

@import "PointDisplayOptions.j"

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

@implementation PointOverlay : MapOverlay
{
    var m_GoogleMarker              @accessors(property=marker);

    MKLocation m_Point              @accessors(property=point);

    CPInteger m_nIdentifier         @accessors(property=pk);
    CPString m_szTitle              @accessors(property=title);
    CPString m_szMode;              //optimization

    PointDisplayOptions m_DisplayOptions       @accessors(getter=displayOptions);
    PointDisplayOptions m_FilterDisplayOptions @accessors(setter=setFilterDisplayOptions:);
}

- (id)init
{
    self = [super init];

    if(self)
    {
        m_Point = nil;

        m_DisplayOptions = [PointDisplayOptions defaultOptions];
        m_FilterDisplayOptions = [PointDisplayOptions defaultOptions];
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

- (BOOL)markerValid:(PointDisplayOptions)displayOptions
{
    var gm = [MKMapView gmNamespace];

    var icon = [displayOptions getDisplayOption:'icon'];
    
    if(icon != "circle" && icon != "rectangle" && m_szMode == "marker")
        return YES;
    else if(icon != m_szMode)
        return NO;

    return YES;
}

- (void)createGoogleMarker:(PointDisplayOptions)displayOptions
{
    var gm = [MKMapView gmNamespace];

    var icon = [displayOptions getDisplayOption:'icon'];

    if(icon == "circle")
    {
        m_GoogleMarker = new gm.Circle();
        m_szMode = "circle";
    }
    else if(icon == "rectangle")
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

    [self updateGoogleMarker:displayOptions];
}

- (void)updateGoogleMarker:(PointDisplayOptions)displayOptions
{
    if(m_GoogleMarker)
    {
        var gm = [MKMapView gmNamespace];
        var latLng = [m_Point googleLatLng];

        var icon = [displayOptions getDisplayOption:'icon'];

        if(icon == "circle")
        {
            var circleOptions = [displayOptions rawOptions];

            circleOptions.center = latLng;
            circleOptions.clickable = true;
            circleOptions.title = m_szTitle;
            circleOptions.zIndex = 3;

            m_GoogleMarker.setOptions(circleOptions);
        }
        else if(icon == "rectangle")
        {
            var rectOptions = [displayOptions rawOptions];
            var radius = rectOptions.radius * METERS_TO_DEG;

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

            var iconColor = [displayOptions getDisplayOption:'iconColor'];
            if(icon && iconColor)
                markerOptions.icon = "/capp/Resources/map_icons/" + iconColor + "/" + icon + ".png";

            m_GoogleMarker.setOptions(markerOptions);
        }

        var visible = [displayOptions getDisplayOption:'visible'];

        if(visible)
            [self addToMapView];
        else
            [self removeFromMapView];
    }
}

- (void)addToMapView
{
    m_GoogleMarker.setMap([[MKMapView getInstance] gMap]);
}

- (void)removeFromMapView
{
    if(m_GoogleMarker)
        m_GoogleMarker.setMap(null);
}

- (void)_update
{
    //Merge Default -> Filter -> Solo Options (Order matters)
    var displayOptions = [PointDisplayOptions defaultOptions];
    [displayOptions enchantOptionsFrom:m_FilterDisplayOptions];
    [displayOptions enchantOptionsFrom:m_DisplayOptions];

    var iconValid = [self markerValid:displayOptions];

    if(!m_GoogleMarker || !iconValid)
    {
        if(!iconValid)
            [self removeFromMapView];

        [self createGoogleMarker:displayOptions];
    }
    else
    {
        [self updateGoogleMarker:displayOptions];
    }
}

// EVENTS

- (void)onClick
{
    if([m_Delegate respondsToSelector:@selector(onClick)])
        [m_Delegate onClick];
}

@end
