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

@import "../OverlayManager.j"
@import "CPDynamicSearch.j"

//A Little Note: This filter view uses a dictionary of accepted key value pairs of type <String:Integer>
//This allows us to provide a nice view to the user(the strings) and a nice view to the server(the Integer)
//during future filter requests
@implementation StringIdMapFilterView : CPControl
{
    OverlayManager m_OverlayManager;

    CPPopUpButton   m_SelectionControl;
    CPDynamicSearch m_SelectionControl; //objective J lets us do this if they are mutually exclusive ;)
    BOOL m_bPopUp; //pop_up(YES) or dynamic_search(NO)

    CPButton m_UpdateButton;

    GiseduFilter m_Filter            @accessors(property=filter);
    CPDictionary m_AcceptedValues    @accessors(property=acceptedValues);
}

- (id)initWithFrame:(CGRect)aFrame andFilter:(GiseduFilter)filter andAcceptedValues:(CPDictionary)acceptedValues
{
    self = [super initWithFrame:aFrame];

    if(self)
    {
        m_Filter = filter;
        m_AcceptedValues = acceptedValues;
        m_OverlayManager = [OverlayManager getInstance];

        m_bPopUp = ([m_AcceptedValues count] <= 100);

        if(m_bPopUp)
        {
            m_SelectionControl = [[CPPopUpButton alloc] initWithFrame:CGRectMakeZero()];
            [m_SelectionControl addItemWithTitle:"All"];
            
            acceptedValuesSorted = [[m_AcceptedValues allKeys] sortedArrayUsingSelector:@selector(compare:)];
            [m_SelectionControl addItemsWithTitles:acceptedValuesSorted];

            [m_SelectionControl sizeToFit];
            [m_SelectionControl setFrameOrigin:CGPointMake(20, 20)];
            [m_SelectionControl setFrameSize:CGSizeMake(260, CGRectGetHeight([m_SelectionControl bounds]))];

            var curKeysForFilterValue = [m_AcceptedValues allKeysForObject:[m_Filter value]];
            if([curKeysForFilterValue count] > 0)
                [m_SelectionControl selectItemWithTitle:[curKeysForFilterValue objectAtIndex:0]];
        }
        else
        {
            m_SelectionControl = [[CPDynamicSearch alloc] initWithFrame:CGRectMake(20, 20, 260, 30)];
            [m_SelectionControl setSearchStrings:[[m_AcceptedValues allKeys] sortedArrayUsingSelector:@selector(compare:)]];
            [m_SelectionControl addSearchString:"All"];
            [m_SelectionControl setDefaultSearch:"All"];
            [m_SelectionControl setSearchSensitivity:1];
            
            var curKeysForFilterValue = [m_AcceptedValues allKeysForObject:[m_Filter value]];
            if([curKeysForFilterValue count] > 0)
                [m_SelectionControl setStringValue:[curKeysForFilterValue objectAtIndex:0]];
                
            [m_SelectionControl sizeToFit];
        }

        m_UpdateButton = [CPButton buttonWithTitle:"Update Filter"];
        [m_UpdateButton sizeToFit];
        [m_UpdateButton setFrameOrigin:CGPointMake(20, 65)];
        [m_UpdateButton setAction:@selector(onFilterUpdateButton:)];
        [m_UpdateButton setTarget:self];

        [self addSubview:m_SelectionControl];

        [self addSubview:m_UpdateButton];
    }

    return self;
}

- (void)onFilterUpdateButton:(id)sender
{
    console.log("onFilterUpdateButton called");

    var curSelItem = nil;

    if(m_bPopUp)
        curSelItem = [m_SelectionControl titleOfSelectedItem];
    else
        curSelItem = [m_SelectionControl stringValue];

    //console.log("AcceptedValues is " + m_AcceptedValues);

    if(curSelItem == "All")
        [m_Filter setValue:"All"];
    else
        [m_Filter setValue:[m_AcceptedValues objectForKey:curSelItem]];

    console.log("Filter Values is " + [m_Filter value]);

    if(_action && _target)
    {
        [self sendAction:_action to:_target];
    }
}

@end
