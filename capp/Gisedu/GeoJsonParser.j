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

@import "PointOverlay.j"
@import "PolygonOverlay.j"
@import "MapKit/MKLocation.j"
@import "MapKit/MKMapView.j"

@implementation GeoJsonParser : CPObject
{
}

- (id)parse:(CPString)geoJson
{
    var objectData = JSON.parse(geoJson);

    if(objectData['type'] == 'MultiPolygon')
    {
        return [self parsePolygon:objectData];
    }
    else if(objectData['type'] == 'Point')
    {
        return [self parsePoint:objectData];
    }
}

- (id)parsePolygon:(id)objectData
{
    overlay = [[PolygonOverlay alloc] init];

    polygons = objectData['coordinates'];

    var gm = [MKMapView gmNamespace];

    for(var i =0; i < polygons.length; i++)
    {
        var polygon = polygons[i];

        for(var j=0; j < polygon.length; j++)
        {
            var coords = polygon[j];

            var locarray = new Array();

            for(var k=0; k < coords.length; k++)
            {
                locarray[k] = new gm.LatLng(coords[k][1], coords[k][0]);
            }

            var locations = [CPArray arrayWithObjects:locarray count:locarray.length];

            [overlay addPolygonPath:locations];
        }
    }

    return overlay;
}

- (id)parsePoint:(id)objectData
{
    var overlay = [[PointOverlay alloc] init];

    var point = objectData['coordinates'];

    var location = [[MKLocation alloc] initWithLatitude:point[1] andLongitude:point[0] ];

    [overlay initFromLocation:location];

    return overlay;
}

@end
