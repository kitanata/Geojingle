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

@import "../GeoJsonParser.j"

@implementation PolygonOverlayLoader : CPControl
{
    CPURLConnection m_CountyConnection; //To pull data from django
    CPString m_ConnectionURL;

    CPInteger m_nIdentifier;
    CPString m_szCategory       @accessors(property=category);
    id m_DisplayOptions         @accessors(property=displayOptions);

    PolygonOverlay m_Polygon    @accessors(property=overlay);
}

- (id)initWithIdentifier:(CPInteger)identifier andUrl:(CPString)connectionUrl
{
    m_nIdentifier = identifier;
    m_ConnectionURL = connectionUrl;

    m_Polygon = nil;

    return self;
}

- (void)loadWithDisplayOptions:(id)displayOptions
{
    m_DisplayOptions = displayOptions;

    [m_CountyConnection cancel];
    m_CountyConnection = [CPURLConnection connectionWithRequest:[CPURLRequest requestWithURL:m_ConnectionURL + m_nIdentifier] delegate:self];
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError
{
    if (aConnection == m_CountyConnection) {
        alert('Load failed! ' + anError);
        m_CountyConnection = nil;
    } else {
        alert('Save failed! ' + anError);
    }
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)aData
{
    if (aConnection == m_CountyConnection)
    {
        var aData = aData.replace('while(1);', '');
        var aData = JSON.parse(aData);

        var nPk = 0;
        var szName = "";

        for(key in aData)
        {
            if(key == 'gid')
            {
                nPk = aData[key];
            }
            else if(key == 'name')
            {
                szName = aData[key];
            }
            else if(key == 'the_geom')
            {
                geoJson = JSON.stringify(aData[key]);
                
                m_Polygon = [[GeoJsonParser alloc] parse:geoJson];
            }
        }

        if(m_Polygon != nil)
        {
            [m_Polygon setName:szName];
            [m_Polygon setPk:nPk];

            if(m_DisplayOptions)
                [m_Polygon setDisplayOptions:m_DisplayOptions];
        }

        if(_action != nil && _target != nil)
        {
            [self sendAction:_action to:_target];
        }
    }
}

@end
