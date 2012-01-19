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

@implementation DisplayOptions : CPObject
{
    id m_DefaultDisplayOptions;
    id m_DisplayOptions         @accessors(getter=rawOptions);
}

- (void)setDisplayOption:(CPString)option value:(id)value
{
    m_DisplayOptions[option] = value;
}

- (id)getDisplayOption:(CPString)option
{
    return m_DisplayOptions[option];
}

//This function should only be used during loading saved projects
//from the server. Use setDisplayOption or enchantOptionsFrom instead
//for anything else. It is unwise to use this to access things directly: Why?
//Because it can break backward compatability with old saves.
- (void)enchantOptionsFromJson:(id)rawOptions
{
    for(key in rawOptions)
        m_DisplayOptions[key] = rawOptions[key];
}

- (void)enchantOptionsFrom:(PointDisplayOptions)theOptions
{
    var options = [theOptions rawOptions];

    for(key in options)
    {
        if(options[key] != m_DefaultDisplayOptions[key])
            m_DisplayOptions[key] = options[key];
    }
}

- (void)resetOptions
{
    m_DisplayOptions = {};

    for(key in m_DefaultDisplayOptions)
        m_DisplayOptions[key] = m_DefaultDisplayOptions[key];
}

@end
