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

@implementation RightSideTabView : CPView
{
    CPTabView m_TabView;
}

- (id) initWithParentView:(CPView)parentView
{
    self = [self initWithFrame:CGRectMake(CGRectGetWidth([parentView bounds]) - 280, 0, 280, CGRectGetHeight([parentView bounds]))];
    [self setAutoresizingMask:CPViewHeightSizable | CPViewMinXMargin];

    if(self)
    {
        m_TabView = [[CPTabView alloc] initWithFrame:CGRectMake(CGRectGetMinX([self bounds]), CGRectGetMinY([self bounds]) + 10, 280, CGRectGetHeight([self bounds]) - 10)];
        [m_TabView setTabViewType:CPTopTabsBezelBorder];
        [m_TabView setAutoresizingMask:CPViewHeightSizable | CPViewMinXMargin];

        [self addSubview:m_TabView];
    }

    return self;
}

- (CGSize)tabViewBounds
{
    return [m_TabView bounds];
}

- (id)addModuleView:(CPView)theView withTitle:(CPString)title
{
    var newTabItem = [[CPTabViewItem alloc] initWithIdentifier:title];
    [newTabItem setLabel:title];
    [newTabItem setView:theView];
    
    [m_TabView addTabViewItem:newTabItem];

    return newTabItem;
}

- (void)enableModuleTabItem:(CPTabViewItem)item
{
    if(![[m_TabView tabViewItems] containsObject:item])
        [m_TabView addTabViewItem:item];
}

//Due to a bug in Cappucinno when we remove tab items dynamically we have to recreate the 
//entire damn view from scratch. This bug applied as recently as version 0.9.5
- (void)disableModuleTabItem:(CPTabViewItem)item
{
    var curTabItems = [m_TabView tabViewItems];
    [curTabItems removeObject:item];
    [m_TabView removeFromSuperview];//kill it

    m_TabView = [[CPTabView alloc] initWithFrame:CGRectMake(CGRectGetMinX([self bounds]), CGRectGetMinY([self bounds]) + 10, 280, CGRectGetHeight([self bounds]) - 10)];
    [m_TabView setTabViewType:CPTopTabsBezelBorder];
    [m_TabView setAutoresizingMask:CPViewHeightSizable | CPViewMinXMargin];

    for(var i=0; i < [curTabItems count]; i++)
        [m_TabView addTabViewItem:[curTabItems objectAtIndex:i]];

    [self addSubview:m_TabView];
}

- (id)selectTabItem:(CPTabViewitem)item
{
    if([[m_TabView tabViewItems] containsObject:item])
        [m_TabView selectTabViewItem:item];
}

@end
