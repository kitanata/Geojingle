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
@import <AppKit/CPTreeNode.j>

@implementation GiseduFilterRequest : CPObject
{
    BOOL m_bFinished    @accessors(property=finished);
    BOOL m_bCached      @accessors(property=cached);

    CPString m_szUrl    @accessors(property=url);
    CPURLConnection m_Connection; //To pull data from django

    CPArray m_ResultSet @accessors(property=resultSet);

    id m_Delegate       @accessors(property=delegate);
}

- (id)initWithUrl:(CPString)url
{
    self = [super init];

    if(self)
    {
        m_szUrl = url;

        m_bFinished = NO;
        m_bCached = NO;

        m_ResultSet = [CPArray array];
    }

    return self;
}

- (void)trigger
{
    [self trigger:NO];
}

- (void)trigger:(BOOL)reloadData
{
    m_bFinished = NO;

    if(!m_bCached || reloadData)
    {
        m_bCached = NO;
        m_ResultSet = [CPArray array];

        [m_Connection cancel];
        m_Connection = [CPURLConnection connectionWithRequest:[CPURLRequest requestWithURL:m_szUrl] delegate:self];
    }
    else
    {
        m_bFinished = YES;
    }
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError
{
    if (aConnection == m_Connection)
    {
        [self onError];
        m_Connection = nil;
    }
    else
    {
        alert('Save failed! ' + anError);
    }
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)aData
{
    var aData = aData.replace('while(1);', '');
    var listData = JSON.parse(aData);

    if (aConnection == m_Connection)
    {
        m_bFinished = YES;
        m_bCached = YES;

        m_ResultSet = [CPArray arrayWithObjects:listData count:listData.length];

        if(m_Delegate && [m_Delegate respondsToSelector:@selector(onFilterRequestSuccessful:)])
            [m_Delegate onFilterRequestSuccessful:self];
    }
}

+ (id)requestWithUrl:(CPString)url
{
    return [[GiseduFilterRequest alloc] initWithUrl:url];
}

@end
