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

@implementation DictionaryLoader : CPControl
{
    CPDictionary m_Dictionary   @accessors(property=dictionary);
    CPString m_szCategory       @accessors(property=category);
    CPString m_szSubCategory    @accessors(property=subCategory);//remove this once refactoring is done. Find a better way

    CPString m_szUrl;
    CPURLConnection m_Connection; //To pull data from django
}

- (id)initWithUrl:(CPString)url
{
    self = [super init];

    if(self)
    {
        m_szUrl = url;
        m_Dictionary = [CPDictionary dictionary];
    }

    return self;
}

- (void)load
{
    if(m_Connection)
        [m_Connection cancel];
    
    m_Connection = [CPURLConnection connectionWithRequest:[CPURLRequest requestWithURL:m_szUrl] delegate:self];
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError
{
    if (aConnection == m_Connection)
    {
        alert('Could not load dictionary! ' + anError);
        m_Connection = nil;
    }
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)aData
{
    var aData = aData.replace('while(1);', '');
    var listData = JSON.parse(aData);

    if (aConnection == m_Connection)
    {
        m_Dictionary = [self parseObjectIntoDictionary:listData];

        console.log("Finished loading dictionary");

        if(_action != nil && _target != nil)
        {
            [self sendAction:_action to:_target];
        }
    }
}

- (CPDictionary)parseObjectIntoDictionary:(id)data
{
    var retDict = [CPDictionary dictionary];

    for(var key in data)
    {
        var curDataItem = data[key];

        if(Array.isArray(curDataItem))
            [retDict setObject:[self parseObjectIntoArray:curDataItem] forKey:key];
        else if(typeof(curDataItem) === "object")
            [retDict setObject:[self parseObjectIntoDictionary:curDataItem] forKey:key];
        else
            [retDict setObject:curDataItem forKey:key];
    }

    return retDict;
}

- (CPArray)parseObjectIntoArray:(id)data
{
    var retArr = [CPArray array];

    for(var i=0; i < data.length; i++)
    {
        var curDataItem = data[key];

        if(Array.isArray(curDataItem))
            [retArr addObject:[self parseObjectIntoArray:curDataItem]];
        else if(typeof(retArr[key]) === "object")
            [retArr addObject:[self parseObjectIntoDictionary:curDataItem]];
        else
            [retArr addObject:curDataItem];
    }

    return retArr;
}

@end
