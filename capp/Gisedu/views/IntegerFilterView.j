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

@import "ArrayFilterView.j"
@import "CPDynamicSearch.j"

@implementation IntegerFilterView : ArrayFilterView
{
    CPPopUpButton   m_IntegerFilterOption;
}

- (id)initWithFrame:(CGRect)aFrame andFilter:(GiseduFilter)filter andAcceptedValues:(CPArray)acceptedValues
{
    var myAcceptedValues = [CPArray arrayWithArray:acceptedValues];
    [myAcceptedValues addObject:"All"];

    self = [super initWithFrame:aFrame andFilter:filter andAcceptedValues:myAcceptedValues];
    
    if(self)
    {
        if(m_bPopUp)
            [m_SelectionControl selectItemWithTitle:[m_Filter value]];
        else
            [m_SelectionControl setStringValue:[m_Filter value]];

        [m_SelectionControl setFrameOrigin:CGPointMake(20, 95)];

        m_IntegerFilterOption = [[CPPopUpButton alloc] initWithFrame:CGRectMakeZero()];
        [m_IntegerFilterOption addItemsWithTitles:["Equal", "Greater Than", "Less Than", 
            "Greater Than or Equal To", "Less Than or Equal To"]];

        [m_IntegerFilterOption sizeToFit];
        [m_IntegerFilterOption setFrameOrigin:CGPointMake(20, 50)];
        [m_IntegerFilterOption setFrameSize:CGSizeMake(260, CGRectGetHeight([m_IntegerFilterOption bounds]))];
        [m_IntegerFilterOption setTarget:self];
        [m_IntegerFilterOption setAction:@selector(onUpdate:)];

        var intFilterOpt = [m_Filter requestOption];
        if(intFilterOpt == "eq" || intFilterOpt == "")
            [m_IntegerFilterOption selectItemWithTitle:"Equal"];
        else if(intFilterOpt == "gt")
            [m_IntegerFilterOption selectItemWithTitle:"Greater Than"];
        else if(intFilterOpt == "lt")
            [m_IntegerFilterOption selectItemWithTitle:"Less Than"];
        else if(intFilterOpt == "lte")
            [m_IntegerFilterOption selectItemWithTitle:"Less Than or Equal To"];
        else if(intFilterOpt == "gte")
            [m_IntegerFilterOption selectItemWithTitle:"Greater Than or Equal To"];

        [self addSubview:m_IntegerFilterOption];
    }

    return self;
}

- (void)onUpdate:(id)sender
{
    if(m_bPopUp)
        [m_Filter setValue:[m_SelectionControl titleOfSelectedItem]];
    else
        [m_Filter setValue:[m_SelectionControl stringValue]];

    var intFilterOptSel = [m_IntegerFilterOption titleOfSelectedItem];
    if(intFilterOptSel == "Equal")
        [m_Filter setRequestOption:"eq"];
    else if(intFilterOptSel == "Greater Than")
        [m_Filter setRequestOption:"gt"];
    else if(intFilterOptSel == "Less Than")
        [m_Filter setRequestOption:"lt"];
    else if(intFilterOptSel == "Greater Than or Equal To")
        [m_Filter setRequestOption:"gte"];
    else if(intFilterOptSel == "Less Than or Equal To")
        [m_Filter setRequestOption:"lte"];

    [m_Filter setDirty];

    if(m_Delegate && [m_Delegate respondsToSelector:@selector(onFilterPropertiesChanged:)])
        [m_Delegate onFilterPropertiesChanged:self];
}

@end
