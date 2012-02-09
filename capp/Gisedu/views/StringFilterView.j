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

@import "FilterView.j"

@implementation StringFilterView : FilterView
{
    CPSearchField m_SelectionControl;

    CPScrollView m_ScrollView;
    CPOutlineView m_OutlineView;

    CPArray m_AcceptedValues    @accessors(property=acceptedValues);
    CPArray m_Items;
}

- (id)initWithFrame:(CGRect)aFrame andFilter:(GiseduFilter)filter andAcceptedValues:(CPArray)acceptedValues
{
    self = [super initWithFrame:aFrame andFilter:filter];

    if(self)
    {
        m_AcceptedValues = [acceptedValues sortedArrayUsingSelector:@selector(compare:)];
        m_Items = [CPArray array];
        [m_Items addObject:"All"];
        [m_Items addObjectsFromArray:m_AcceptedValues];

        m_SelectionControl = [[CPSearchField alloc] initWithFrame:CGRectMake(20, 40, 260, 30)];
        [m_SelectionControl setSendsSearchStringImmediately:YES];
        [m_SelectionControl setAction:@selector(onSearchTextChanged)];
        [m_SelectionControl setTarget:self];

        [m_SelectionControl sizeToFit];
        [m_SelectionControl setDelegate:self];

        m_ScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0, 80, 300, CGRectGetHeight([self bounds]) - 20)];
        [m_ScrollView setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];

        m_OutlineView = [[CPOutlineView alloc] initWithFrame:CGRectMake(0, 0, 280, CGRectGetHeight([m_ScrollView bounds]))];
        [m_ScrollView setDocumentView:m_OutlineView];

        var layerNameCol = [[CPTableColumn alloc] initWithIdentifier:@"LayerName"];
        [layerNameCol setWidth:280];

        [m_OutlineView setHeaderView:nil];
        [m_OutlineView setCornerView:nil];
        [m_OutlineView addTableColumn:layerNameCol];
        [m_OutlineView setOutlineTableColumn:layerNameCol];
        [m_OutlineView setAction:@selector(onOutlineItemSelected:)];
        [m_OutlineView setTarget:self];

        [m_OutlineView setDataSource:self];

        [self setAutoresizingMask:CPViewHeightSizable];
        [self addSubview:m_SelectionControl];
        [self addSubview:m_ScrollView];

        [m_SelectionControl setStringValue:[m_Filter value]];
    }

    return self;
}

- (void)onSearchTextChanged
{
    console.log("onSearchTextChanged");

    var searchString = [[m_SelectionControl stringValue] lowercaseString];
    console.log(searchString);

    m_Items = [CPArray array];
    [m_Items addObject:"All"];

    for(var i=0; i < [m_AcceptedValues count]; i++)
    {
        var curItem = [m_AcceptedValues objectAtIndex:i];
        var testString = [curItem lowercaseString];

        if(testString.indexOf(searchString) != -1)
            [m_Items addObject:curItem];
    }

    [m_OutlineView reloadData];
}

- (id)outlineView:(CPOutlineView)outlineView child:(int)index ofItem:(id)item
{
    if (item === nil)
        return [m_Items objectAtIndex:index];
    else
        return nil;
}

- (BOOL)outlineView:(CPOutlineView)outlineView isItemExpandable:(id)item
{
    return NO;
}

- (int)outlineView:(CPOutlineView)outlineView numberOfChildrenOfItem:(id)item
{
    if (item === nil)
        return [m_Items count];
    else
        return 0;
}

- (id)outlineView:(CPOutlineView)outlineView objectValueForTableColumn:(CPTableColumn)tableColumn byItem:(id)item
{
    return item;
}

- (void) onOutlineItemSelected:(id)sender
{
    var curSelItem = [m_OutlineView itemAtRow:[m_OutlineView selectedRow]];

    if(curSelItem == "All")
        [m_Filter setValue:"All"];
    else
        [m_Filter setValue:curSelItem];

    [m_Filter setDirty];

    if(m_Delegate && [m_Delegate respondsToSelector:@selector(onFilterPropertiesChanged:)])
        [m_Delegate onFilterPropertiesChanged:self];
}

@end
