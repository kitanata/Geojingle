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
@import <AppKit/CPTabView.j>

@implementation OverlayOutlineView : CPControl
{
    CPScrollView m_OverlayFeaturesScrollView;
    CPOutlineView m_OutlineView @accessors(property=outline);

    CPDictionary m_Items        @accessors(property=items);

    id m_Delegate               @accessors(property=delegate);
}

- (id) initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if(self)
    {
        m_OverlayFeaturesScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0, 20, 300, CGRectGetHeight([self bounds]) - 20)];
        [m_OverlayFeaturesScrollView setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];
        [self addSubview:m_OverlayFeaturesScrollView];

        m_OutlineView = [[CPOutlineView alloc] initWithFrame:CGRectMake(0, 0, 280, CGRectGetHeight([m_OverlayFeaturesScrollView bounds]))];
        [m_OverlayFeaturesScrollView setDocumentView:m_OutlineView];

        var layerNameCol = [[CPTableColumn alloc] initWithIdentifier:@"LayerName"];
        [layerNameCol setWidth:280];

        [m_OutlineView setHeaderView:nil];
        [m_OutlineView setCornerView:nil];
        [m_OutlineView addTableColumn:layerNameCol];
        [m_OutlineView setOutlineTableColumn:layerNameCol];
        [m_OutlineView setAction:@selector(onOutlineItemSelected:)];
        [m_OutlineView setTarget:self];

        m_Items = [CPDictionary dictionary];
        [m_OutlineView setDataSource:self];

        [self setBackgroundColor:[CPColor colorWithHexString:"EDEDED"]];
    }

    return self;
}

- (void) clearItems
{
    m_Items = [CPDictionary dictionary];

    [m_OutlineView reloadItem:nil reloadChildren:YES];
}

- (void) addItem:(CPString)item forCategory:(CPString)category
{
    var itemArray = [m_Items objectForKey:category];

    if(!itemArray)
        [m_Items setObject:[CPArray arrayWithObject:item] forKey:category];
    else
        [itemArray addObject:item];

    [m_OutlineView reloadItem:nil reloadChildren:YES];
}

- (void) selectItem:(CPString)item
{
    parentItem = [m_OutlineView parentForItem:item];

    if(parentItem)
        [m_OutlineView expandItem:parentItem];

    var itemIndex = [m_OutlineView rowForItem:item];
    [m_OutlineView selectRowIndexes:[CPIndexSet indexSetWithIndex:itemIndex] byExtendingSelection:NO];
}

- (void) sortItems
{
    var itemCategories = [m_Items allKeys];

    for(var i=0; i < [itemCategories count]; i++)
    {
        var itemArray = [m_Items objectForKey:[itemCategories objectAtIndex:i]];
        var sortedArray = [itemArray sortedArrayUsingSelector:@selector(compare:)];
        [m_Items setObject:sortedArray forKey:[itemCategories objectAtIndex:i]];
    }

    [m_OutlineView reloadItem:nil reloadChildren:YES];
}

- (id)outlineView:(CPOutlineView)outlineView child:(int)index ofItem:(id)item
{
    //CPLog("outlineView:%@ child:%@ ofItem:%@", outlineView, index, item);

    if (item === nil)
    {
        var keys = [m_Items allKeys];
        return [keys objectAtIndex:index];
    }
    else
    {
        var values = [m_Items objectForKey:item];
        return [values objectAtIndex:index];
    }
}

- (BOOL)outlineView:(CPOutlineView)outlineView isItemExpandable:(id)item
{
    //CPLog("outlineView:%@ isItemExpandable:%@", outlineView, item);

    var values = [m_Items objectForKey:item];

    return ([values count] > 0);
}

- (int)outlineView:(CPOutlineView)outlineView numberOfChildrenOfItem:(id)item
{
    //CPLog("outlineView:%@ numberOfChildrenOfItem:%@", outlineView, item);

    if (item === nil)
        return [m_Items count];
    else
    {
        var values = [m_Items objectForKey:item];
        return [values count];
    }
}

- (id)outlineView:(CPOutlineView)outlineView objectValueForTableColumn:(CPTableColumn)tableColumn byItem:(id)item
{
    //CPLog("outlineView:%@ objectValueForTableColumn:%@ byItem:%@", outlineView, tableColumn, item);
    return item;
}

- (void) onOutlineItemSelected:(id)sender
{
    if(m_Delegate && [m_Delegate respondsToSelector:@selector(onOutlineItemSelected:)])
        [m_Delegate onOutlineItemSelected:sender];
}
