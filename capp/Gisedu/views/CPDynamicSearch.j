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

@implementation CPDynamicSearch : CPSearchField
{
    CPMenu m_SearchMenu;

    CPArray m_SearchItems           @accessors(property=searchStrings);
    CPString m_DefaultSearch;
    CPInteger m_SearchSensitivity   @accessors(property=searchSensitivity);
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if(self)
    {
        m_SearchItems = [CPArray array];
        m_DefaultSearch = "Type To Search";
        m_SearchSensitivity = 4;
       
        [self setAction:@selector(onSearchFieldTextChanged:)];
        [self setTarget:self];
    }

    return self;
}

- (void)addSearchString:(CPString)searchString
{
    [m_SearchItems addObject:searchString];
}

- (void)setDefaultSearch:(CPString)defaultSearch
{
    m_DefaultSearch = defaultSearch;
    [self setStringValue:defaultSearch];
}

- (void)onSearchFieldTextChanged:(id)sender
{
    var searchString = [[self stringValue] lowercaseString];

    if([searchString length] >= m_SearchSensitivity)
    {
        var menuItems = [CPArray array];

        for(var i=0; i < [m_SearchItems count]; i++)
        {
            var testString = [[m_SearchItems objectAtIndex:i] lowercaseString];

            if(testString.indexOf(searchString) != -1)
            {
                [menuItems addObject:[m_SearchItems objectAtIndex:i]];
            }
        }

        m_SearchMenu = [[CPMenu alloc] initWithTitle:"Search"];
        [m_SearchMenu setAutoenablesItems:YES];

        for(var i=0; i < [menuItems count]; i++)
        {
            var item = [m_SearchMenu addItemWithTitle:[menuItems objectAtIndex:i] action:@selector(onSearchMenuItemSelected:) keyEquivalent:""];
            [item setTarget:self];
        }

        if([menuItems count] > 0)
        {
            [self setSearchMenuTemplate:m_SearchMenu];
        }
    }
    else
    {
        [self setSearchMenuTemplate:nil];
    }
}

- (void)onSearchMenuItemSelected:(id)sender
{
    if(m_SearchMenu)
    {
        [self setStringValue:[sender title]];

        if([_delegate respondsToSelector:@selector(onSearchMenuItemSelected:)])
            [_delegate onSearchMenuItemSelected:self];
    }
}

- (void)cancelOperation:(id)sender
{
    [self setObjectValue:m_DefaultSearch];
    [self _sendPartialString];
    [self _updateCancelButtonVisibility];
}

@end
