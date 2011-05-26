/*
 * AppController.j
 * NewApplication
 *
 * Created by You on February 22, 2011.
 * Copyright 2011, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import <MapKit/MKMapView.j>
@import <AppKit/CPToolbar.j>
@import <AppKit/CPToolbarItem.j>

@import "Gisedu/OverlaysController.j"
@import "Gisedu/TablesController.j"

@implementation AppController : CPObject
{
    MKMapView m_MapView;
    CPWindow theWindow;

    CPView m_ContentView;

    CPScrollView m_OverlayFeaturesScrollView;
    OverlaysController m_OverlaysController;

    CPCheckBox m_ShowCountiesCheckBox;

    TablesController m_TablesController;

    CPScrollView m_TableScrollView;

    var m_MapHeight;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    theWindow = [[CPWindow alloc]
                        initWithContentRect:CGRectMakeZero()
                        styleMask:CPBorderlessBridgeWindowMask],
        m_ContentView = [theWindow contentView];

    [theWindow orderFront:self];

    [m_ContentView setBackgroundColor:[CPColor whiteColor]];

    //Top View - Buttons and Controls
    var toolbar = [[CPToolbar alloc] initWithIdentifier:"My Toolbar"];
    [toolbar setDelegate:self];
    [toolbar setVisible:YES];
    [theWindow setToolbar:toolbar];

    [self initMenu];

    [self initTabView];

    m_MapHeight = Math.max(CGRectGetHeight([m_ContentView bounds]) / 3 * 2, 200);

    m_MapView = [[MKMapView alloc] initWithFrame:CGRectMake(300, 0, CGRectGetWidth([m_ContentView bounds]) - 300, m_MapHeight) apiKey:''];
    [m_MapView setDelegate:self]
    [m_MapView setAutoresizingMask:CPViewHeightSizable | CPViewWidthSizable];
    [m_ContentView addSubview:m_MapView];

    var bottomHeight = Math.max(CGRectGetHeight([m_ContentView bounds]) / 3, 200);

    m_TableScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(300, CGRectGetHeight([m_ContentView bounds]) - bottomHeight, CGRectGetWidth([m_ContentView bounds]), bottomHeight)];
    [m_TableScrollView setAutoresizingMask:CPViewMinYMargin | CPViewWidthSizable];
        var countyTableView = [[CPTableView alloc] initWithFrame:CGRectMake(300, 0, CGRectGetWidth([m_ContentView bounds]), bottomHeight)];
        var countyNameCol = [[CPTableColumn alloc] initWithIdentifier:@"CountyNameColumn"];
        [countyNameCol setWidth:125.0];
        [[countyNameCol headerView] setStringValue:"County Name"];
        [countyTableView addTableColumn:countyNameCol];
        [m_TableScrollView setDocumentView:countyTableView];
        console.log("Loaded Table View");
    [m_ContentView addSubview:m_TableScrollView];
}

- (void)mapViewIsReady:(MKMapView)mapView
{
    var loc = [[MKLocation alloc] initWithLatitude:39.962226 andLongitude:-83.000642];
    var marker = [[MKMarker alloc] initAtLocation:loc];
    [marker addToMapView:m_MapView];
    [m_MapView setCenter:loc];

    m_OverlaysController = [[OverlaysController alloc] initWithParentView:m_OverlayFeaturesScrollView andMapView:m_MapView];
}

// Return an array of toolbar item identifier (all the toolbar items that may be present in the toolbar)
- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar
{
   return ['Test'];
}

// Return an array of toolbar item identifier (the default toolbar items that are present in the toolbar)
- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
   return ['Test'];
}

// Create the toolbar item that is requested by the toolbar.
- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
	// Create the toolbar item and associate it with its identifier
    var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier:anItemIdentifier];

    var mainBundle = [CPBundle mainBundle];

    var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"view_table.png"] size:CPSizeMake(48, 48)];
    var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"view_table_highlighted.png"] size:CPSizeMake(48, 48)];

    [toolbarItem setImage:image];
    [toolbarItem setAlternateImage:highlighted];

    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(onShowTables:)];
    [toolbarItem setLabel:"Show Tables"];

    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];

    return toolbarItem;
}

- (void)initMenu
{
    var menu = [[CPMenu alloc] initWithTitle:@"dummy"];

  	var menuItem1 = [[CPMenuItem alloc] initWithTitle:@"File" action:nil keyEquivalent:@"1"];
  	[menu addItem:menuItem1];

  	var menu11 = [[CPMenu alloc] initWithTitle:@"dummy"];
  	var menuItem111 = [[CPMenuItem alloc] initWithTitle:@"AAA" action:@selector(showAlert:) keyEquivalent:@"3"];
  	[menu11 addItem:menuItem111];
  	[menu11 addItem:[CPMenuItem separatorItem]];
  	var menuItem112 = [[CPMenuItem alloc] initWithTitle:@"BBB" action:@selector(showAlert:) keyEquivalent:@"3"];
  	[menu11 addItem:menuItem112];

	[menuItem1 setSubmenu:menu11];

  	var menuItem2 = [[CPMenuItem alloc] initWithTitle:@"Edit" action:nil keyEquivalent:@"4"];
  	[menu addItem:menuItem2];


  	var menu2 = [[CPMenu alloc] initWithTitle:@"dummy"];
  	var menuItem3 = [[CPMenuItem alloc] initWithTitle:@"CCC" action:@selector(showAlert:) keyEquivalent:@"3"];
  	[menu2 addItem:menuItem3];
  	[menu2 addItem:[CPMenuItem separatorItem]];

  	var menuItem4 = [[CPMenuItem alloc] initWithTitle:@"DDD" action:nil keyEquivalent:@"2"];
  	[menu2 addItem:menuItem4];
	[menu2 addItem:[[CPMenuItem alloc] initWithTitle:@"EEE" action:nil keyEquivalent:@"2"]];

  	var menu3 = [[CPMenu alloc] initWithTitle:@"Phil"];
  	[menu3 addItem:[[CPMenuItem alloc] initWithTitle:@"GGG" action:@selector(showAlert:) keyEquivalent:@"2"]];
	[menuItem4 setSubmenu:menu3];

	[menuItem2 setSubmenu:menu2];

	var sharedApplication = [CPApplication sharedApplication];
	[sharedApplication setMainMenu:menu];

	// Show the application menu
	[CPMenu setMenuBarVisible:YES];
}

-(void) initTabView
{
	var tabView = [[CPTabView alloc] initWithFrame:CGRectMake(0, 10, 300, CGRectGetHeight([m_ContentView bounds]))];
	[tabView setTabViewType:CPTopTabsBezelBorder];
	[tabView setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];
	    //Map Options
	    var mapOptionsTabItem = [[CPTabViewItem alloc] initWithIdentifier:@"MapOptionsTab"];
	    [mapOptionsTabItem setLabel:"Map Options"];
	        var mapOptionsTabView = [[CPView alloc] initWithFrame: CGRectMake(0, 100, 300, CGRectGetHeight([m_ContentView bounds]) - 50)];
	            m_ShowCountiesCheckBox = [[CPCheckBox alloc] initWithFrame: CGRectMake(25, 0, 100, 100)];
	            [m_ShowCountiesCheckBox setTitle:"Show Counties"];
	            [m_ShowCountiesCheckBox setState:CPOnState];
	            [m_ShowCountiesCheckBox setTarget:self];
	            [m_ShowCountiesCheckBox setAction:@selector(onShowCountiesChk:)];
	        [mapOptionsTabView addSubview:m_ShowCountiesCheckBox];
        [mapOptionsTabItem setView:mapOptionsTabView];
    [tabView addTabViewItem:mapOptionsTabItem];
	    //Overlay Features
	    var layersTabItem = [[CPTabViewItem alloc] initWithIdentifier:@"LayersTab"];
        [layersTabItem setLabel:"Overlay Features"];
            var layersTabView = [[CPView alloc] initWithFrame: CGRectMake(0, 100, 300, CGRectGetHeight([m_ContentView bounds]) - 50)];
                m_OverlayFeaturesScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(10, 20, 280, CGRectGetHeight([layersTabView bounds]))];
                [layersTabView addSubview:m_OverlayFeaturesScrollView];
        [layersTabItem setView:layersTabView];

    console.log("Tab View Initialized");

    [tabView addTabViewItem:layersTabItem];
	[m_ContentView addSubview:tabView];

	//Other Stuff Below - Not Core.

	var tabViewItem1 = [[CPTabViewItem alloc] initWithIdentifier:@"tabViewItem1"];
	[tabViewItem1 setLabel:@"First Tab"];

	var view1 = [[CPView alloc] initWithFrame: CGRectMake(0, 0, 100, 100)];

	var button = [[CPButton alloc] initWithFrame: CGRectMake(0, 0, 40, 18)];
	[button setTitle:"view1"];
	[button setTarget:self];
	[button setAction:@selector(showAlert:)];

	[view1 addSubview:button];

	[tabViewItem1 setView:view1];

	var auxiliaryView1 = [[CPView alloc] initWithFrame: CGRectMake(0, 0, 50, 50)];

	var button = [[CPButton alloc] initWithFrame: CGRectMake(0, 0, 40, 18)];
	[button setTitle:"auxiliaryView1"];
	[button setTarget:self];
	[button setAction:@selector(showAlert:)];
	[auxiliaryView1 addSubview:button];

	[tabViewItem1 setAuxiliaryView:auxiliaryView1];
	
	[tabView addTabViewItem:tabViewItem1];

	[tabView selectFirstTabViewItem:self];
}

- (void)onShowTables:(id)sender
{
    if([m_TableScrollView superview] != nil)
    {
        [m_TableScrollView removeFromSuperview];
        [m_MapView setFrame:CGRectMake(300, 0, CGRectGetWidth([m_ContentView bounds]) - 300, CGRectGetHeight([m_ContentView bounds]))];
    }
    else
    {
        console.log(m_MapHeight);
        [m_MapView setFrame:CGRectMake(300, 0, CGRectGetWidth([m_ContentView bounds]) - 300, m_MapHeight)];
        [m_ContentView addSubview:m_TableScrollView];
    }
}

- (void)onShowCountiesChk:(id)sender
{
    if([m_ShowCountiesCheckBox state] == CPOnState)
    {
        [m_OverlaysController setCountiesVisible:YES];
    }
    else if([m_ShowCountiesCheckBox state] == CPOffState)
    {
        [m_OverlaysController setCountiesVisible:NO];
    }
}

@end
