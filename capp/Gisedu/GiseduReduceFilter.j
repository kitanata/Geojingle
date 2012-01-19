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
@import "GiseduFilter.j"
@import "PointOverlay.j"
@import "PointDisplayOptions.j"
@import "PolygonDisplayOptions.j"

/* CPTreeNode does not allow us to reassign a new object to the same node without
recreating the node. This gets around that."*/

@implementation GiseduReduceFilter : GiseduFilter
{
    PointDisplayOptions m_PointDisplayOptions       @accessors(getter=pointDisplayOptions);
    PolygonDisplayOptions m_PolygonDisplayOptions   @accessors(getter=polygonDisplayOptions);
}

- (id)initWithValue:(id)value
{
    self = [super initWithValue:value];

    if(self)
    {
        m_PointDisplayOptions = [PointDisplayOptions defaultOptions];
        m_PolygonDisplayOptions = [PolygonDisplayOptions defaultOptions];
    }

    return self;
}

- (void)enchantFromFilter:(GiseduFilter)filter
{
    var filterType = [[filter description] dataType];

    if(filterType == "POINT")
        [m_PointDisplayOptions enchantOptionsFrom:[filter displayOptions]];
    else if(filterType == "POLYGON")
        [m_PolygonDisplayOptions enchantOptionsFrom:[filter displayOptions]];
    else if(filterType == "REDUCE")
    {
        [m_PointDisplayOptions enchantOptionsFrom:[filter pointDisplayOptions]];
        [m_PolygonDisplayOptions enchantOptionsFrom:[filter polygonDisplayOptions]];
    }
}

- (id)toJson 
{
    json = [super toJson];
    json.point_display_options = [m_PointDisplayOptions rawOptions];
    json.polygon_display_options = [m_PolygonDisplayOptions rawOptions];
    return json;
}

- (void)fromJson:(id)json
{
    [super fromJson:json];
    console.log("Json Display Options = "); console.log(json.point_display_options);
    [m_PointDisplayOptions enchantOptionsFromJson:json.point_display_options];
    [m_PolygonDisplayOptions enchantOptionsFromJson:json.polygon_display_options];
}

@end
