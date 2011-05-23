/*
 * AppController.j
 * NewApplication
 *
 * Created by You on February 22, 2011.
 * Copyright 2011, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>


@implementation AppController : CPObject
{
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var theWindow = [[CPWindow alloc]
                        initWithContentRect:CGRectMakeZero()
                        styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView];

        [theWindow orderFront:self];

        [contentView setBackgroundColor:[CPColor blackColor]];

        //Top View - Buttons and Controls
        var topView = [[CPView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([contentView bounds]), 100)];

        [topView setBackgroundColor:[CPColor redColor]];

        [topView setAutoresizingMask:CPViewWidthSizable];

        [contentView addSubview:topView];

        //Left View - Toolbar and Controls
        var leftView = [[CPView alloc] initWithFrame:CGRectMake(0, 100, 200, CGRectGetHeight([contentView bounds]))];

        [leftView setBackgroundColor:[CPColor blueColor]];

        [leftView setAutoresizingMask:CPViewHeightSizable];

        [contentView addSubview:leftView];

        //Right View - Layer Controls

        var rightView = [[CPView alloc] initWithFrame:CGRectMake(CGRectGetWidth([contentView bounds]) - 200, 100, 200, CGRectGetHeight([contentView bounds]))];

        [rightView setBackgroundColor:[CPColor blueColor]];

        [rightView setAutoresizingMask:CPViewHeightSizable | CPViewMinXMargin];

        [contentView addSubview:rightView];

        //Center View - The GIS Map Itself

        var centerView = [[CPView alloc] initWithFrame:CGRectMake(200, 100, CGRectGetWidth([contentView bounds]) - 400, CGRectGetHeight([contentView bounds]))];

        [centerView setBackgroundColor:[CPColor greenColor]];

        [centerView setAutoresizingMask:CPViewHeightSizable | CPViewWidthSizable];

        [contentView addSubview:centerView];
}

@end
