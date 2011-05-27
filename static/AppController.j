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

@import "Gisedu/OverlaysOutlineView.j"
@import "Gisedu/TablesController.j"

@import "Gisedu/OverlayOptionsView.j"

@implementation AppController : CPObject
{
    MKMapView m_MapView;
    CPWindow theWindow;

    CPView m_ContentView;

    CPScrollView m_OverlayFeaturesScrollView;
    OverlaysOutlineView m_OverlaysController;

    CPCheckBox m_ShowCountiesCheckBox;

    TablesController m_TablesController;

    CPScrollView m_TableScrollView;

    var m_MinMapHeight; //map's minimum height
    var m_MaxMapHeight; //map's maximum height
    var m_MapHeight;    //map's current height

    var m_MinMapWidth;  //map's minimum width
    var m_MaxMapWidth;  //map's maximum width
    var m_MapWidth;     //map's current width

    OverlayOptionsView m_OverlayOptionsView;
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

    m_MinMapHeight = Math.max(CGRectGetHeight([m_ContentView bounds]) / 3 * 2, 200);
    m_MaxMapHeight = CGRectGetHeight([m_ContentView bounds]);
    m_MapHeight = m_MaxMapHeight;

    m_MinMapWidth = CGRectGetWidth([m_ContentView bounds]) - 550;
    m_MaxMapWidth = CGRectGetWidth([m_ContentView bounds]) - 300;
    m_MapWidth = m_MaxMapWidth;

    m_MapView = [[MKMapView alloc] initWithFrame:CGRectMake(300, 0, m_MapWidth, m_MapHeight) apiKey:''];
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

    m_OverlayOptionsView = [[OverlayOptionsView alloc] initWithParentView:m_ContentView];
    [m_ContentView addSubview:m_OverlayOptionsView];
}

- (void)mapViewIsReady:(MKMapView)mapView
{
    var loc = [[MKLocation alloc] initWithLatitude:39.962226 andLongitude:-83.000642];
    var marker = [[MKMarker alloc] initAtLocation:loc];
    [marker addToMapView:m_MapView];
    [m_MapView setCenter:loc];

    m_OverlaysController = [[OverlaysOutlineView alloc] initWithParentView:m_OverlayFeaturesScrollView andMapView:m_MapView];
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
	            m_ShowCountiesCheckBox = [[CPCheckBox alloc] initWithFrame: CGRectMake(25, 20, 200, 40)];
	            [m_ShowCountiesCheckBox setTitle:"Show All Counties"];
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

	[tabView selectFirstTabViewItem:self];
}

- (void)onShowTables:(id)sender
{
    if([m_TableScrollView superview] != nil)
    {
        [m_TableScrollView removeFromSuperview];
        m_MapHeight = m_MaxMapHeight;
        [self updateMapViewFrame];
    }
    else
    {
        m_MapHeight = m_MinMapHeight;
        [self updateMapViewFrame];
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

- (void)showOverlayOptionsView
{
    m_MapWidth = m_MinMapWidth;
    [self updateMapViewFrame];
    [m_ContentView addSubview:m_OverlayOptionsView];
}

- (void)hideOverlayOptionsView
{
    [m_OverlayOptionsView removeFromSuperview];
    m_MapWidth = m_MaxMapWidth;
    [self updateMapViewFrame];
}

- (void)updateMapViewFrame
{
    [m_MapView setFrame:CGRectMake(300, 0, m_MapWidth, m_MapHeight)];
}

@end
