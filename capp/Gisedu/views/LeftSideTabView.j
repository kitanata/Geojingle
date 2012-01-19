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
@import "OverlayOutlineView.j"
@import "OverlayFiltersView.j"

@implementation LeftSideTabView : CPTabView
{
    CPTabViewItem m_OverlayFiltersTabItem;
    OverlayFiltersView m_OverlayFiltersView @accessors(property=filtersView);

    CPTabViewItem m_OverlayOutlineTabItem;
    OverlayOutlineView m_OverlayOutlineView @accessors(property=outlineView);

    id m_Delegate                           @accessors(property=delegate);
}

- (id) initWithContentView:(CPView)contentView
{
    self = [self initWithFrame:CGRectMake(CGRectGetMinX([contentView bounds]), 10, 300, CGRectGetHeight([contentView bounds]) - 10)];
    [self setTabViewType:CPTopTabsBezelBorder];
    [self setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];

    if(self)
    {
        m_OverlayFiltersView = [[OverlayFiltersView alloc] initWithFrame:[self bounds]];

        //Overlay Filters
        m_OverlayFiltersTabItem = [[CPTabViewItem alloc] initWithIdentifier:@"FiltersTab"];
        [m_OverlayFiltersTabItem setLabel:"Filter Engine"];
        [m_OverlayFiltersTabItem setView:m_OverlayFiltersView];

        //Overlay Features
        m_OverlayOutlineTabItem = [[CPTabViewItem alloc] initWithIdentifier:@"OutlineTab"];
        [m_OverlayOutlineTabItem setLabel:"Feature Outline"];

        [self addTabViewItem:m_OverlayFiltersTabItem];
        [self addTabViewItem:m_OverlayOutlineTabItem];
    }

    return self;
}

- (void)mapViewIsReady:(MKMapView)mapView
{
    m_OverlayOutlineView = [[OverlayOutlineView alloc] initWithFrame:[self bounds]];
    [m_OverlayOutlineTabItem setView:m_OverlayOutlineView];
}

@end
