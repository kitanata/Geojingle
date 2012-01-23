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

@import "DictFilterView.j"
@import "CPDynamicSearch.j"

@implementation IdStringMapFilterView : DictFilterView
{
}

- (id)initWithFrame:(CGRect)aFrame andFilter:(GiseduFilter)filter andAcceptedValues:(CPDictionary)acceptedValues
{
    self = [super initWithFrame:aFrame andFilter:filter andAcceptedValues:acceptedValues];

    if(self)
    {
        if(m_bPopUp)
        {
            var curKeysForFilterValue = [m_AcceptedValues objectForKey:[m_Filter value]];
            if(curKeysForFilterValue)
                [m_SelectionControl selectItemWithTitle:curKeysForFilterValue];
        }
        else
        {
            var curKeysForFilterValue = [m_AcceptedValues objectForKey:[m_Filter value]];
            if(curKeysForFilterValue)
                [m_SelectionControl setStringValue:curKeysForFilterValue];
        }

    }

    return self;
}

- (void)onUpdate:(id)sender
{
    var curSelItem = nil;

    if(m_bPopUp)
        curSelItem = [m_SelectionControl titleOfSelectedItem];
    else
        curSelItem = [m_SelectionControl stringValue];

    if(curSelItem == "All")
    {
        [m_Filter setValue:"All"];
    }
    else
    {
        var keyList = [m_AcceptedValues allKeysForObject:curSelItem];
        if([keyList count] > 0)
            [m_Filter setValue:[keyList objectAtIndex:0]];
    }

    if(_action && _target)
    {
        [self sendAction:_action to:_target];
    }
}

@end
