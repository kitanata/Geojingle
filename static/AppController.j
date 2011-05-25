/*
 * AppController.j
 * NewApplication
 *
 * Created by You on February 22, 2011.
 * Copyright 2011, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import <MapKit/MKMapView.j>
@import <MapKit/MKMapScene.j>
@import <AppKit/CPToolbar.j>
@import <AppKit/CPToolbarItem.j>

@implementation AppController : CPObject
{
    MKMapView centerView;
    CPWindow theWindow;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    theWindow = [[CPWindow alloc]
                        initWithContentRect:CGRectMakeZero()
                        styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView];

    [theWindow orderFront:self];

    [contentView setBackgroundColor:[CPColor whiteColor]];

    //Top View - Buttons and Controls
    var toolbar = [[CPToolbar alloc] initWithIdentifier:"My Toolbar"];
    [toolbar setDelegate:self];
    [toolbar setVisible:YES];
    [theWindow setToolbar:toolbar];

    [self initMenu];

    [self initTabView:contentView];

    //Right View - Layer Controls

    //var rightView = [[CPView alloc] initWithFrame:CGRectMake(CGRectGetWidth([contentView bounds]) - 300, 0, 300, CGRectGetHeight([contentView bounds]))];

    //[rightView setBackgroundColor:[CPColor blueColor]];

    //[rightView setAutoresizingMask:CPViewHeightSizable | CPViewMinXMargin];

    //[contentView addSubview:rightView];

    //Center View - The GIS Map Itself

    //centerView = [[MKMapView alloc] initWithFrame:CGRectMake(300, 0, CGRectGetWidth([contentView bounds]) - 300, CGRectGetHeight([contentView bounds])) apiKey:''];

    //[centerView setDelegate:self]

    //[centerView setAutoresizingMask:CPViewHeightSizable | CPViewWidthSizable];

    //[contentView addSubview:centerView];
}

- (void)mapViewIsReady:(MKMapView)mapView
{
    var loc = [[MKLocation alloc] initWithLatitude:39.962226 andLongitude:-83.000642];
    var marker = [[MKMarker alloc] initAtLocation:loc];
    [marker addToMapView:centerView];
    [mapView setCenter:loc];

    mapScene = [[MKMapScene alloc] initWithMapView:centerView];

    mapUrl = [[CPURL alloc] initWithString:"http://127.0.0.1:8000/json"]

    [mapScene readFromURL:mapUrl]
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

    var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"add.png"] size:CPSizeMake(30, 25)];
    var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"addHighlighted.png"] size:CPSizeMake(30, 25)];

    [toolbarItem setImage:image];
    [toolbarItem setAlternateImage:highlighted];

    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(add:)];
    [toolbarItem setLabel:"Test"];

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

-(void) initTabView:(CPView)contentView
{
    //var leftTabView = [[CPTabView alloc] initWithFrame:CGRectMake(0, 0, 300, CGRectGetHeight([contentView bounds]))];
        //var leftTabViewLayersItem = [[CPTabViewItem alloc] initWithIdentifier:@"LayersTab"];
        //[leftTabViewLayersItem setLabel:"Overlay Layers"];
            //var scrollView = [[CPScrollView alloc] initWithFrame:[leftTabView bounds]];
            //var scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight([leftTabView bounds]) + 100, CGRectGetWidth([leftTabView bounds]), CGRectGetHeight([leftTabView bounds]))];
            //[scrollView setBackgroundColor:[CPColor blueColor]];
            //[scrollView setAutoresizingMask:CPViewHeightSizable];
                //The Layer TableView(1 Column)
            //    var layerView = [[CPTableView alloc] initWithFrame:[scrollView bounds]];
            //    [scrollView setDocumentView:layerView];
                    //The TableView's Column
            //        var layerNameCol = [[CPTableColumn alloc] initWithIdentifier:@"LayerName"];
             //       [[layerNameCol headerView] setStringValue:"Layer Name"];
            //        [layerNameCol setWidth:125.0];
            //        [layerView addTableColumn:layerNameCol];
        //[leftTabViewLayersItem setView:scrollView];
        //[leftTabView addTabViewItem:leftTabViewLayersItem];

        //var leftTabViewFeaturesItem = [[CPTabViewItem alloc] initWithIdentifier:@"FeaturesTab"];
        //[leftTabViewFeaturesItem setLabel:"Overlay Features"];
        //[leftTabViewFeaturesItem setView:scrollView];
        //[leftTabView addTabViewItem:leftTabViewFeaturesItem];
    //[leftTabView setBackgroundColor:[CPColor blueColor]];
    //[leftTabView setTabViewType:CPTopTabsBezelBorder];
    //[contentView addSubview:leftTabView];

	var tabView = [[CPTabView alloc] initWithFrame:CGRectMake(0, 10, 300, CGRectGetHeight([contentView bounds]))];
	[tabView setTabViewType:CPTopTabsBezelBorder];
	[tabView setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];
	    var layersTabItem = [[CPTabViewItem alloc] initWithIdentifier:@"LayersTab"];
        [layersTabItem setLabel:"Overlay Layers"];
            var layersTabView = [[CPView alloc] initWithFrame: CGRectMake(0, 100, 300, CGRectGetHeight([contentView bounds]) - 50)];
                var scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(10, 20, 280, CGRectGetHeight([layersTabView bounds]))];
                    var layerView = [[CPTableView alloc] initWithFrame:CGRectMake(0, 0, 300, CGRectGetHeight([scrollView bounds]))];
                    [scrollView setDocumentView:layerView];
                        //The TableView's Column
                        var layerNameCol = [[CPTableColumn alloc] initWithIdentifier:@"LayerName"];
                        [[layerNameCol headerView] setStringValue:"Layer Name"];
                        [layerNameCol setWidth:125.0];
                        [layerView addTableColumn:layerNameCol];
                [layersTabView addSubview:scrollView];
            //[layersTabView setBackgroundColor:[CPColor blueColor]];
            [layersTabItem setView:layersTabView];
        [tabView addTabViewItem:layersTabItem];
	[contentView addSubview:tabView];

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

	var tabViewItem2 = [[CPTabViewItem alloc] initWithIdentifier:@"tabViewItem2"];
	[tabViewItem2 setLabel:@"Second Tab"];

	var view2 = [[CPView alloc] initWithFrame: CGRectMake(0, 0, 50, 50)];
	[tabViewItem2 setView:view2];
	var auxiliaryView2 = [[CPView alloc] initWithFrame: CGRectMake(0, 0, 50, 50)];
	[tabViewItem2 setAuxiliaryView:auxiliaryView2];
	
	[tabView addTabViewItem:tabViewItem1];
	[tabView addTabViewItem:tabViewItem2];

	[tabView selectFirstTabViewItem:self];
}

@end
