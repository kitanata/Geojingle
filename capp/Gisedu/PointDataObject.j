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

    if([m_Delegate respondsToSelector:@selector(onPointOverlaySelected:)])
        [m_Delegate onPointOverlaySelected:self];
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

    var loaderUrl = g_UrlPrefix + "/point_infobox/" + m_nIdentifier;
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

    var loaderUrl = g_UrlPrefix + "/point_infobox/" + m_nIdentifier;
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
