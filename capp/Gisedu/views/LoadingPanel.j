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

@implementation LoadingPanel : CPPanel
{
    CPImageView m_SpinnerView;
    CPTextField m_Status;
}

- (id)init
{
    self = [super initWithContentRect:CGRectMake(0,0,300,150) 
                styleMask:CPBorderlessWindowMask | CPTitledWindowMask];

    if(self)
    {
        [self setTitle:"Loading..."];
        [self center];
        [self setBackgroundColor:[CPColor whiteColor]];

        m_Status = [CPTextField labelWithTitle:"Loading Maps... please wait."];
        [m_Status setFrameOrigin:CGPointMake(10, 120)];
        [m_Status sizeToFit];

        m_SpinnerView = [[CPImageView alloc] initWithFrame:CGRectMake(126, 41, 48, 48)];

        var mainBundle = [CPBundle mainBundle];
        var img = [[CPImage alloc] initWithContentsOfFile:[mainBundle 
                                            pathForResource:@"spinner_lrg.gif"] 
                                    size:CPSizeMake(48, 48)];

        [m_SpinnerView setImage:img];

        contentView = [self contentView];
        [contentView addSubview:m_SpinnerView];
        [contentView addSubview:m_Status];
    }

    return self;
}

- (void)showWithStatus:(CPString)status
{
    [m_Status setObjectValue:status];
    [self orderFront:self];
}

- (void)setStatus:(CPString)status
{
    [m_Status setObjectValue:status];
    [m_Status display];
}

@end
