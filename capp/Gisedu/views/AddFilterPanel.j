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

@import "../FilterManager.j"

@implementation AddFilterPanel : CPPanel
{
    CPButton m_CancelButton;
    CPButton m_AddFilterButton;

    CPPopUpButton m_FilterType;

    CPTreeNode m_ParentFilter;
    id m_Delegate   @accessors(property=delegate);
}

- (id)initWithFilterNames:(CPArray)filterNames
{
    self = [super initWithContentRect:CGRectMake(0,276,300,150) styleMask:CPClosableWindowMask];

    if(self)
    {
        [self setFloatingPanel:YES];
        [self setTitle:"Add New Filter"];
        [self setBackgroundColor:[CPColor whiteColor]];

        m_CancelButton = [CPButton buttonWithTitle:"Cancel"];
        [m_CancelButton setTarget:self];
        [m_CancelButton setAction:@selector(onCancel:)];
        [m_CancelButton sizeToFit];

        m_AddFilterButton = [CPButton buttonWithTitle:"Add Filter"];
        [m_AddFilterButton setTarget:self];
        [m_AddFilterButton setAction:@selector(onAddFilterConfirm:)];
        [m_AddFilterButton sizeToFit];

        m_FilterType = [[CPPopUpButton alloc] initWithFrame:CGRectMake(20, 48, 260, 24)];
        [m_FilterType setTitle:"Select Filter Here"];

        [m_FilterType addItemsWithTitles:filterNames];

        var cancelWidth = CGRectGetWidth([m_CancelButton bounds]);
        var addWidth = CGRectGetWidth([m_AddFilterButton bounds]);

        [m_CancelButton setFrameOrigin:CGPointMake(300 - (addWidth + cancelWidth + 30), 115)];
        [m_AddFilterButton setFrameOrigin:CGPointMake(300 - (addWidth + 15), 115)];

        contentView = [self contentView];
        [contentView addSubview:m_FilterType];
        [contentView addSubview:m_CancelButton];
        [contentView addSubview:m_AddFilterButton];
    }

    return self;
}

- (void)onAddFilterConfirm:(id)sender
{
    var filterManager = [FilterManager getInstance];

    var curSelFilterName = [[m_FilterType selectedItem] title];
    var newFilterType = [filterManager filterIdFromName:curSelFilterName];

    console.log("CurSelFilterName is " + curSelFilterName);
    console.log("New Filter Type is " + newFilterType);

    if(newFilterType && [m_Delegate respondsToSelector:@selector(onAddFilterConfirm:)])
        [m_Delegate onAddFilterConfirm:newFilterType];

    [m_FilterType selectItemAtIndex:0];
    [self close];
}

- (void)onCancel:(id)sender
{
    [m_FilterType selectItemAtIndex:0];
    [self close];
}

@end
