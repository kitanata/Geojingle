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

@implementation PointOverlayListLoader : CPControl
{
    CPArray m_PointIdList           @accessors(property=idList);
    CPString m_DataType             @accessors(property=dataType);
    CPDictionary m_PointOverlays    @accessors(property=pointOverlays);

    CPURLConnection m_Connection; //To pull data from django
    CPString m_ConnectionURL        @accessors(property=url);
}

- (id)initWithRequestUrl:(CPString)connectionUrl
{
    m_ConnectionURL = connectionUrl;
    m_PointOverlays = [CPDictionary dictionary];

    return self;
}

- (void)load
{
    [m_Connection cancel];

    var request         = [CPURLRequest requestWithURL:m_ConnectionURL];
    
    var pointIds = [];
    for(var i=0; i < [m_PointIdList count]; i++)
        pointIds.push([m_PointIdList objectAtIndex:i]);

    var requestJson     = {'point_ids' : pointIds};

    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[CPString JSONFromObject:requestJson]];

    m_Connection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError
{
    if (aConnection == m_Connection)
    {
        alert('Load failed! ' + anError);
        m_Connection = nil;
    }
    else
    {
        alert('Save failed! ' + anError);
    }
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)aData
{
    if (aConnection == m_Connection)
    {
        var aData = aData.replace('while(1);', '');
        var objectData = JSON.parse(aData);

        var geoJsonParser = [GeoJsonParser alloc];

        for(id in objectData)
        {
            var pointOverlay = [geoJsonParser parsePoint:objectData[id]];

            [m_PointOverlays setObject:pointOverlay forKey:id];
        }

        if(_action != nil && _target != nil)
        {
            [self sendAction:_action to:_target];
        }
    }
}

@end
