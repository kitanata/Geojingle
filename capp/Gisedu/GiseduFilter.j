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

/* CPTreeNode does not allow us to reassign a new object to the same node without
recreating the node. This gets around that."*/

@implementation GiseduFilter : CPTreeNode
{
    CPString m_FilterType           @accessors(property=type);
    id m_FilterValue                @accessors(property=value);
    CPString m_FilterRequestOption  @accessors(property=requestOption); //optional argument to request_modifier
    id m_FilterDescription          @accessors(property=description);

    BOOL m_bDirty                   @accessors(property=dirty);
}

- (id)initWithValue:(id)value
{
    self = [super initWithRepresentedObject:"Gisedu Filter"];

    if(self)
    {
        m_FilterValue = value;
        m_FilterRequestOption = "";

        m_bDirty = YES;
    }

    return self;
}

- (void)setDirty
{
    m_bDirty = YES;
}

- (void)enchantChildren
{
    var children = [self childNodes];

    //Do not refactor. This is correct. We to apply our properties to all our children.
    //THEN have our children apply their properties to their children. and so on...
    [self _enchantChildren:children];

    for(var i=0; i < [children count]; i++)
        [[children objectAtIndex:i] enchantChildren];
}

- (void)_enchantChildren:(CPArray)children
{
    for(var i=0; i < [children count]; i++)
    {
        var curChild = [children objectAtIndex:i];
        var curFilterType = [[curChild description] dataType];

        [curChild enchantFromFilter:self];

        [self _enchantChildren:[curChild childNodes]];
    }
}

- (void)enchantFromParents
{
    [self _enchantFromParents:[self parentNode]];
}

- (void)_enchantFromParents:(GiseduFilter)parentFilter
{
    //recurse to root then propegate down to this
    if([parentFilter parentNode])
        [self _enchantFromParents:[parentFilter parentNode]];

    [self enchantFromFilter:parentFilter];
}

- (void)enchantFromFilter:(GiseduFilter)filter { }

- (id)toJson
{
    json = {};
    json.type = m_FilterType
    json.value = m_FilterValue
    json.request_option = m_FilterRequestOption
    return json;
}

- (void)fromJson:(id)json
{
    m_FilterType = json.type;
    m_FilterValue = json.value;
    m_FilterRequestOption = json.request_option;
}

@end
