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
@import "MapKit/MKMapView.j"
@import "MapKit/MKMapItem.j"
@import "MapKit/MKLocation.j"

@import "PolygonDisplayOptions.j"

@implementation PolygonOverlay : MapOverlay
{
    CPInteger m_nPk                         @accessors(property=pk);
    CPString m_szName                       @accessors(property=name);

    Polygon m_GooglePolygon                 @accessors(property=googlePolygon);

    CPArray     m_Paths                     @accessors(property=paths);
    PolygonDisplayOptions m_DisplayOptions   @accessors(getter=displayOptions); // JS object representing additional options for the icon (used with circles and rects)
    PolygonDisplayOptions m_FilterDisplayOptions @accessors(setter=setFilterDisplayOptions:);

    BOOL m_bActive                          @accessors(property=active); //Is this polygon currently being edited?
}

- (id)init 
{
    if (self = [super init])
    {
        m_Paths = [CPArray array];
        m_szName = "Unknown";

        m_DisplayOptions = [PolygonDisplayOptions defaultOptions];
        m_FilterDisplayOptions = [PolygonDisplayOptions defaultOptions];
    }

    return self;
}

- (void)addPolygonPath:(CPArray)pathLocations
{
    m_Paths = [m_Paths arrayByAddingObject:pathLocations];
}

- (void)createGooglePolygon:(PolygonDisplayOptions)displayOptions
{
    if (m_Paths)
    {
        var gm = [MKMapView gmNamespace];

        m_GooglePolygon = new gm.Polygon();

        [self updateGooglePolygon:displayOptions];

        gm.event.addListener(m_GooglePolygon, 'click', function() { [self onClick]; });
    }
}

- (void)updateGooglePolygon:(PolygonDisplayOptions)displayOptions
{
    if(m_GooglePolygon)
    {
        var loc = nil
        var linePaths = [];

        for(var i=0; i < [m_Paths count]; i++)
        {
            linePaths.push([m_Paths objectAtIndex:i]);
        }

        var zIndex = 0;

        if(m_bActive)
        {
            zIndex = 1;
        }
        
        var polyOptions = [displayOptions rawOptions];

        polyOptions.paths = linePaths;
        polyOptions.zIndex = 1;

        m_GooglePolygon.setOptions(polyOptions);

        if([displayOptions getDisplayOption:'visible'])
            [self addToMapView];
        else
            [self removeFromMapView];
    }
}

- (void)addToMapView
{
    m_GooglePolygon.setMap([[MKMapView getInstance] gMap]);
}

- (void)removeFromMapView
{
    m_GooglePolygon.setMap(null);
}

- (void)update
{
    console.log("PolygonOverlay update Called");
    console.log(m_FilterDisplayOptions);

    var displayOptions = [PolygonDisplayOptions defaultOptions];
    [displayOptions enchantOptionsFrom:m_FilterDisplayOptions];
    [displayOptions enchantOptionsFrom:m_DisplayOptions];

    if(m_GooglePolygon == nil)
    {
        [self createGooglePolygon:displayOptions];
    }
    else
    {
        [self updateGooglePolygon:displayOptions];
    }
}

// EVENTS

- (void)onClick
{
    if([m_Delegate respondsToSelector:@selector(onPolygonOverlaySelected:)])
        [m_Delegate onPolygonOverlaySelected:self];
}

@end
