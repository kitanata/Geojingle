/*
 * AppController.j
 * NewApplication
 *
 * Created by You on February 22, 2011.
 * Copyright 2011, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import <AppKit/CPToolbar.j>
@import <AppKit/CPToolbarItem.j>

@import <Foundation/CPURLConnection.j>

@import "Gisedu/AuthKit/AKUserSessionManager.j"

@import "Gisedu/MapKit/MKMapView.j"

@import "Gisedu/views/LeftSideTabView.j"
@import "Gisedu/views/RightSideTabView.j"
@import "Gisedu/views/OverlayOutlineView.j"

@import "Gisedu/views/AddFilterPanel.j"
@import "Gisedu/views/LoadingPanel.j"

@import "Gisedu/loaders/PolygonOverlayLoader.j"
@import "Gisedu/loaders/PointOverlayLoader.j"

@import "Gisedu/Modules/CsvImporter/CsvImporterModule.j"
@import "Gisedu/Modules/PointDisplayOptions/PointDisplayOptionsModule.j"
@import "Gisedu/Modules/PolygonDisplayOptions/PolygonDisplayOptionsModule.j"
@import "Gisedu/FileKit/FKFileController.j"

var m_NewProjectToolbarId = 'newProject';
var m_SaveProjectToolbarId = 'saveProject';
var m_SaveProjectAsToolbarId = 'saveProjectAs';
var m_OpenProjectToolbarId = 'openProject';

var m_OverlayOptionsToolbarId = 'overlayOptions';
var m_UpdateMapToolbarId = 'updateMap';

g_UrlPrefix = 'http://127.0.0.1';

@implementation AppController : CPObject
{
    MKMapView m_MapView;
    CPWindow theWindow;
    CPView m_ContentView;

    LeftSideTabView m_LeftSideTabView   @accessors(getter=leftSideTabView);
    RightSideTabView m_RightSideTabView @accessors(getter=rightSideTabView);

    id m_CurSelectedItem;

    OverlayManager m_OverlayManager;
    FilterManager m_FilterManager;

    var m_MinMapHeight; //map's minimum height
    var m_MaxMapHeight; //map's maximum height
    var m_MapHeight;    //map's current height

    var m_MinMapWidth;  //map's minimum width
    var m_MaxMapWidth;  //map's maximum width
    var m_MapWidth;     //map's current width

    AKUserSessionManager m_SessionManager;
    FKFileController m_ProjectCloudManager;

    CPMenu m_FileMenu;
    CPMenuItem m_FileNewMenuItem;       //reloads browser
    CPMenuItem m_FileOpenMenuItem;      //open a project
    CPMenuItem m_FileSaveMenuItem;      //save project
    CPMenuItem m_FileSaveAsMenuItem;    //save project as
    CPMenuItem m_FileSeparatorItem;
    CPMenuItem m_FileExitMenuItem;      //exit Gisedu (closes browser tab)

  	CPMenu m_EditMenu;
  	CPMenuItem m_EditMenuAddPointFilter;    //adds point filter
    CPMenuItem m_EditMenuAddPolygonFilter;  //adds polygon filter
    CPMenuItem m_EditMenuAddReduceFilter;   //adds reduce filter
    CPMenuItem m_EditMenuAddPostFilter;     //adds post filter
    CPMenuItem m_EditMenuDeleteFilter;      //deletes the selected filter

    CPMenu m_AccountMenu;
    CPMenuItem m_AccountLoginMenuItem;      //logs a user in
    CPMenuItem m_AccountRegisterMenuItem;   //registers a new account
    CPMenuItem m_AccountLogOutMenuItem;     //logs a user out
    CPMenuItem m_AccountAdminMenuItem;      //takes user to django admin page

    CPAlert m_ExitAlert;

    //Modules
    CsvImporterModule m_CsvImporter;
    PointDisplayOptionsModule m_PointDisplayOptions @accessors(getter=pointDisplayOptions);
    PolygonDisplayOptionsModule m_PolygonDisplayOptions @accessors(getter=polygonDisplayOptions);
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    theWindow = [[CPWindow alloc]
                        initWithContentRect:CGRectMakeZero()
                        styleMask:CPBorderlessBridgeWindowMask],
        m_ContentView = [theWindow contentView];

    [theWindow orderFront:self];
    [theWindow setDelegate:self];

    [m_ContentView setBackgroundColor:[CPColor whiteColor]];

    m_MapLoadingPanel = [[LoadingPanel alloc] init];

    m_OverlayManager = [OverlayManager getInstance];
    [m_OverlayManager setDelegate:self];
    [m_OverlayManager setStatusPanel:m_MapLoadingPanel];

    m_FilterManager = [FilterManager getInstance];
    [m_FilterManager setDelegate:self];
    [m_FilterManager loadFilterDescriptions];
    [m_FilterManager setStatusPanel:m_MapLoadingPanel];

    //Initialize the mapview
    m_MinMapHeight = Math.max(CGRectGetHeight([m_ContentView bounds]) / 3 * 2, 200);
    m_MaxMapHeight = CGRectGetHeight([m_ContentView bounds]);
    m_MapHeight = m_MaxMapHeight;

    m_MinMapWidth = CGRectGetWidth([m_ContentView bounds]) - 580;
    m_MaxMapWidth = CGRectGetWidth([m_ContentView bounds]) - 300;
    m_MapWidth = m_MaxMapWidth;

    var bottomHeight = Math.max(CGRectGetHeight([m_ContentView bounds]) / 3, 200);

    var loc = [[MKLocation alloc] initWithLatitude:39.962226 andLongitude:-83.000642];
    m_MapView = [[MKMapView getInstance] initWithFrame:CGRectMake(300, 0, m_MapWidth, m_MapHeight) center:loc];

    [m_MapView setDelegate:self]
    [m_MapView setAutoresizingMask:CPViewHeightSizable | CPViewWidthSizable];
    [m_ContentView addSubview:m_MapView];

    [m_OverlayManager setMapView:m_MapView];

    m_RightSideTabView = [[RightSideTabView alloc] initWithParentView:m_ContentView];

    m_LeftSideTabView = [[LeftSideTabView alloc] initWithContentView:m_ContentView];
    [m_LeftSideTabView setDelegate:self];
    [[m_LeftSideTabView filtersView] setAppController:self];
    [m_ContentView addSubview:m_LeftSideTabView];

    //Load Modules
    m_CsvImporter = [[CsvImporterModule alloc] initFromApp:self];
    m_PointDisplayOptions = [[PointDisplayOptionsModule alloc] initFromApp:self];
    m_PolygonDisplayOptions = [[PolygonDisplayOptionsModule alloc] initFromApp:self];

    //Load the Menu
    [self initMenu];

    //Top View - Buttons and Controls
    var toolbar = [[CPToolbar alloc] initWithIdentifier:"My Toolbar"];
    [toolbar setDelegate:self];
    [toolbar setVisible:YES];
    [theWindow setToolbar:toolbar];

    m_SessionManager = [AKUserSessionManager defaultManager];
    [CPURLConnection setClassDelegate:m_SessionManager];
    [m_SessionManager setDelegate:self];
    [m_SessionManager syncSession];

    m_ProjectCloudManager = [FKFileController getInstance];
    [m_ProjectCloudManager setDelegate:self];

    //ALERT CONFIGURATION
    m_ExitAlert = [[CPAlert alloc] init];
    [m_ExitAlert setTitle:"Are you sure?"];
    [m_ExitAlert setAlertStyle:CPInformationalAlertStyle];
    [m_ExitAlert setMessageText:"Are you sure you want to close gisedu?"];
    [m_ExitAlert addButtonWithTitle:@"No"];
    [m_ExitAlert addButtonWithTitle:@"Yes"];
    [m_ExitAlert setDelegate:self];

    m_NewProjectAlert = [[CPAlert alloc] init];
    [m_NewProjectAlert setTitle:"Are you sure?"];
    [m_NewProjectAlert setAlertStyle:CPInformationalAlertStyle];
    [m_NewProjectAlert setMessageText:"Are you sure. All unsaved progress will be lost."];
    [m_NewProjectAlert addButtonWithTitle:"No, not yet."];
    [m_NewProjectAlert addButtonWithTitle:"Yes"];
    [m_NewProjectAlert setDelegate:self];
}

- (void)mapViewIsReady:(MKMapView)mapView
{
    console.log("AppController:-mapViewIsReady() called");

    [m_LeftSideTabView mapViewIsReady:mapView];

    [[m_LeftSideTabView outlineView] setDelegate:self];

    console.log("AppController:-mapViewIsReady() finished");
}

// Return an array of toolbar item identifier (all the toolbar items that may be present in the toolbar)
- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar
{
   return [m_NewProjectToolbarId, m_OpenProjectToolbarId, m_SaveProjectToolbarId, m_SaveProjectAsToolbarId,
            CPToolbarSeparatorItemIdentifier, m_OverlayOptionsToolbarId, m_UpdateMapToolbarId];
}

// Return an array of toolbar item identifier (the default toolbar items that are present in the toolbar)
- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
   return [m_NewProjectToolbarId, m_OpenProjectToolbarId, m_SaveProjectToolbarId, m_SaveProjectAsToolbarId,
            CPToolbarSeparatorItemIdentifier, m_OverlayOptionsToolbarId, m_UpdateMapToolbarId];
}

// Create the toolbar item that is requested by the toolbar.
- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
	// Create the toolbar item and associate it with its identifier
    var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier:anItemIdentifier];

    var mainBundle = [CPBundle mainBundle];

    if(m_NewProjectToolbarId == anItemIdentifier)
    {
        var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"buttons/rest/new.png"] size:CPSizeMake(48, 48)];
        var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"buttons/highlighted/new.png"] size:CPSizeMake(48, 48)];

        [toolbarItem setImage:image];
        [toolbarItem setAlternateImage:highlighted];

        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(onNewProject:)];
        [toolbarItem setLabel:"New Project"];

        [toolbarItem setMinSize:CGSizeMake(32, 32)];
        [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    }
    else if(m_OpenProjectToolbarId == anItemIdentifier)
    {
        var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"buttons/rest/open.png"] size:CPSizeMake(48, 48)];
        var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"buttons/highlighted/open.png"] size:CPSizeMake(48, 48)];

        [toolbarItem setImage:image];
        [toolbarItem setAlternateImage:highlighted];

        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(onOpenProject:)];
        [toolbarItem setLabel:"Open Project"];

        [toolbarItem setMinSize:CGSizeMake(32, 32)];
        [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    }
    else if(m_SaveProjectToolbarId == anItemIdentifier)
    {
        var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"buttons/rest/save.png"] size:CPSizeMake(48, 48)];
        var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"buttons/highlighted/save.png"] size:CPSizeMake(48, 48)];

        [toolbarItem setImage:image];
        [toolbarItem setAlternateImage:highlighted];

        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(onSaveProject:)];
        [toolbarItem setLabel:"Save Project"];

        [toolbarItem setMinSize:CGSizeMake(32, 32)];
        [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    }
    else if(m_SaveProjectAsToolbarId == anItemIdentifier)
    {
        var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"buttons/rest/save_as.png"] size:CPSizeMake(48, 48)];
        var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"buttons/highlighted/save_as.png"] size:CPSizeMake(48, 48)];

        [toolbarItem setImage:image];
        [toolbarItem setAlternateImage:highlighted];

        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(onSaveProjectAs:)];
        [toolbarItem setLabel:"Save Project As"];

        [toolbarItem setMinSize:CGSizeMake(32, 32)];
        [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    }
    else if(m_OverlayOptionsToolbarId == anItemIdentifier)
    {
        var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"buttons/rest/overlay_options.png"] size:CPSizeMake(48, 48)];
        var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"buttons/highlighted/overlay_options.png"] size:CPSizeMake(48, 48)];

        [toolbarItem setImage:image];
        [toolbarItem setAlternateImage:highlighted];

        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(onOverlayOptions:)];
        [toolbarItem setLabel:"Overlay Options"];

        [toolbarItem setMinSize:CGSizeMake(32, 32)];
        [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    }
    else if(m_UpdateMapToolbarId == anItemIdentifier)
    {
        var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"buttons/rest/update_map.png"] size:CPSizeMake(48, 48)];
        var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"buttons/highlighted/update_map.png"] size:CPSizeMake(48, 48)];

        [toolbarItem setImage:image];
        [toolbarItem setAlternateImage:highlighted];

        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(onUpdateMapFilters:)];
        [toolbarItem setLabel:"Update Map"];

        [toolbarItem setMinSize:CGSizeMake(32, 32)];
        [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    }


    return toolbarItem;
}

- (void)initMenu
{
    console.log("AppController:-initMenu() called");

    var menu = [[CPMenu alloc] initWithTitle:"main_menu"];

    //BEGIN FILE MENU
    var fileMenuItem = [[CPMenuItem alloc] initWithTitle:@"File" action:nil keyEquivalent:@"F"];
  	m_FileMenu = [[CPMenu alloc] initWithTitle:@"file_menu"];
  	    m_FileNewMenuItem = [[CPMenuItem alloc] initWithTitle:@"New Project" action:@selector(onNewProject:) keyEquivalent:@"N"];
        m_FileOpenMenuItem = [[CPMenuItem alloc] initWithTitle:@"Open Project" action:@selector(onOpenProject:) keyEquivalent:@"O"];
        m_FileSaveMenuItem = [[CPMenuItem alloc] initWithTitle:@"Save Project" action:@selector(onSaveProject:) keyEquivalent:@"S"];
        m_FileSaveAsMenuItem = [[CPMenuItem alloc] initWithTitle:@"Save Project As..." action:@selector(onSaveProjectAs:) keyEquivalent:nil];
        m_FileExitMenuItem = [[CPMenuItem alloc] initWithTitle:@"Exit Gisedu" action:@selector(onExitGisedu:) keyEquivalent:nil];

        [m_FileMenu addItem:m_FileNewMenuItem];
        [m_FileMenu addItem:m_FileOpenMenuItem];
        [m_FileMenu addItem:m_FileSaveMenuItem];
        [m_FileMenu addItem:m_FileSaveAsMenuItem];

        [m_CsvImporter loadIntoMenu:m_FileMenu];
        [m_FileMenu addItem:[CPMenuItem separatorItem]];
        [m_FileMenu addItem:m_FileExitMenuItem];

  	[fileMenuItem setSubmenu:m_FileMenu];
  	[menu addItem:fileMenuItem];
  	//END FILE MENU

  	//BEGIN EDIT MENU
  	var editMenuItem = [[CPMenuItem alloc] initWithTitle:@"Edit" action:nil keyEquivalent:@"E"];
  	m_EditMenu = [[CPMenu alloc] initWithTitle:@"edit_menu"];
  	    m_EditMenuAddPointFilter = [[CPMenuItem alloc] initWithTitle:@"Add Point Filter" action:@selector(onAddPointFilter:) keyEquivalent:@"p"];
  	    m_EditMenuAddPolygonFilter = [[CPMenuItem alloc] initWithTitle:@"Add Polygon Filter" action:@selector(onAddPolygonFilter:) keyEquivalent:@"P"];
  	    m_EditMenuAddReduceFilter = [[CPMenuItem alloc] initWithTitle:@"Add Reduce Filter" action:@selector(onAddReduceFilter:) keyEquivalent:@"R"];
        m_EditMenuAddPostFilter = [[CPMenuItem alloc] initWithTitle:@"Add Post Filter" action:@selector(onAddPostFilter:) keyEquivalent:@"o"];
  	    m_EditMenuDeleteFilter = [[CPMenuItem alloc] initWithTitle:@"Delete Filter" action:@selector(onDeleteFilter:) keyEquivalent:@"D"];

        [m_EditMenu addItem:m_EditMenuAddPointFilter];
        [m_EditMenu addItem:m_EditMenuAddPolygonFilter];
        [m_EditMenu addItem:m_EditMenuAddReduceFilter];
        [m_EditMenu addItem:m_EditMenuAddPostFilter];
        [m_EditMenu addItem:m_EditMenuDeleteFilter];

        [m_EditMenu addItem:[CPMenuItem separatorItem]];
        [m_PointDisplayOptions loadIntoMenu:m_EditMenu];
        [m_PolygonDisplayOptions loadIntoMenu:m_EditMenu];

    [editMenuItem setSubmenu:m_EditMenu];
  	[menu addItem:editMenuItem];
  	//END EDIT MENU

	var sharedApplication = [CPApplication sharedApplication];
	[sharedApplication setMainMenu:menu];

	// Show the application menu
	[CPMenu setMenuBarVisible:YES];
	[CPMenu setMenuBarTitle:"Untitled Project"];

    var accountMenuItem = [[CPMenuItem alloc] initWithTitle:"My Account" action:nil keyEquivalent:nil];
    m_AccountMenu = [[CPMenu alloc] initWithTitle:@"Account Menu"];
	    m_AccountLoginMenuItem = [[CPMenuItem alloc] initWithTitle:"Login" action:@selector(onLoginUser:) keyEquivalent:"L"];
	    m_AccountRegisterMenuItem = [[CPMenuItem alloc] initWithTitle:"Sign-Up" action:@selector(onRegisterUser:) keyEquivalent:"R"];
	    m_AccountLogOutMenuItem = [[CPMenuItem alloc] initWithTitle:"Logout" action:@selector(onLogoutUser:) keyEquivalent:"L"];
        m_AccountAdminMenuItem = [[CPMenuItem alloc] initWithTitle:"Admin" action:@selector(onAdminUser:) keyEquivalent:"A"];

	    [m_AccountMenu addItem:m_AccountLoginMenuItem];
	    [m_AccountMenu addItem:m_AccountRegisterMenuItem];
	    [m_AccountMenu addItem:m_AccountAdminMenuItem];
	    [m_AccountMenu addItem:m_AccountLogOutMenuItem];

    [accountMenuItem setSubmenu:m_AccountMenu];
	[menu addItem:accountMenuItem];

	[self updateMenuItems:NO];

	console.log("AppController:-initMenu() finished");
}

- (void)onPolygonOverlaySelected:(id)sender
{
    [m_PointDisplayOptions disable];
    
    [m_PolygonDisplayOptions enable];
    [m_PolygonDisplayOptions setOverlayTarget:sender];

    [self showRightSideTabView];
}

- (void)onPointOverlaySelected:(id)pointDataObject
{
    [m_PolygonDisplayOptions disable];
    
    [m_PointDisplayOptions enable];
    [m_PointDisplayOptions setOverlayTarget:[pointDataObject overlay]];

    [[m_LeftSideTabView outlineView] selectItem:[pointDataObject name]];
    [self showRightSideTabView];
}

- (void) onOutlineItemSelected:(id)sender
{
    var item = [sender itemAtRow:[sender selectedRow]];
    var itemParent = [sender parentForItem:item];

    if(itemParent == nil)
        return;

    var descriptions = [[m_FilterManager filterDescriptions] allValues];

    for(var i=0; i < [descriptions count]; i++)
    {
        var curDesc = [descriptions objectAtIndex:i];

        if([curDesc dataType] == "REDUCE" || [curDesc dataType] == "POST")
            continue;

        var curOptions = [curDesc options];

        if([curOptions containsKey:itemParent])
            curOptions = [curOptions objectForKey:itemParent];

        if([[curOptions allValues] containsObject:item])
        {
            var curDataType = [curDesc dataType];
            var itemIds = [curOptions allKeysForObject:item];
            for(var j=0; j < [itemIds count]; j++)
            {
                var itemId = [itemIds objectAtIndex:j];
                if(curDataType == "POINT")
                {
                    var pointDataObject = [m_OverlayManager getOverlayObject:[curDesc id] objId:itemId];

                    [pointDataObject toggleInfoWindow];

                    [m_PolygonDisplayOptions disable];
                    [m_PointDisplayOptions enable];
                    [m_PointDisplayOptions setOverlayTarget:[pointDataObject overlay]];

                    [self showRightSideTabView];
                }
                else if(curDataType == "POLYGON")
                {
                    var overlay = [m_OverlayManager getOverlayObject:[curDesc id] objId:itemId];

                    [m_PolygonDisplayOptions enable];
                    [m_PointDisplayOptions disable];
                    [m_PolygonDisplayOptions setOverlayTarget:overlay];

                    [self showRightSideTabView];
                }
            }

            m_CurSelectedItem = item;
        }
    }

    return;
}

- (void)showRightSideTabView
{
    [self updateMapTheory];
    m_MapWidth = m_MinMapWidth;

    [self updateMapViewFrame];
    if(![[m_ContentView subviews] containsObject:m_RightSideTabView])
        [m_ContentView addSubview:m_RightSideTabView];
}

- (void)hideRightSideTabView
{
    [m_RightSideTabView removeFromSuperview];

    [self updateMapTheory];
    m_MapWidth = m_MaxMapWidth;

    [self updateMapViewFrame];
}

- (void)updateMapTheory
{
    m_MinMapWidth = CGRectGetWidth([m_ContentView bounds]) - 580;
    m_MaxMapWidth = CGRectGetWidth([m_ContentView bounds]) - 300;

    m_MinMapHeight = Math.max(CGRectGetHeight([m_ContentView bounds]) / 3 * 2, 200);
    m_MaxMapHeight = CGRectGetHeight([m_ContentView bounds]);
}

- (void)updateMapViewFrame
{
    [m_MapView setFrame:CGRectMake(300, 0, m_MapWidth, m_MapHeight)];
}

- (void)onOverlayOptions:(id)sender
{
    if([m_RightSideTabView superview] != nil)
    {
        [self hideRightSideTabView];
    }
    else
    {
        [self showRightSideTabView];
    }
}

- (void)onFilterDescriptionsLoaded
{
    [m_OverlayManager onFilterDescriptionsLoaded];
}

- (void)onUpdateMapFilters:(id)sender
{
    [m_MapLoadingPanel showWithStatus:"Updating Maps"];
    [[m_LeftSideTabView outlineView] clearItems];
    [m_FilterManager triggerFilters];
}

- (void)onFilterManagerFinished:(CPDictionary)activeOverlays
{
    console.log("AppController::onFilterManagerFinished called");
    var overlayDataTypes = [activeOverlays allKeys];

    for(var i=0; i < [overlayDataTypes count]; i++)
    {
        var curDataType = [overlayDataTypes objectAtIndex:i];
        var curOverlayIds = [activeOverlays objectForKey:curDataType];

        var desc = [[m_FilterManager filterDescriptions] objectForKey:curDataType];

        for(var j=0; j < [curOverlayIds count]; j++)
        {
            var curOverlay = [m_OverlayManager getOverlayObject:curDataType objId:[curOverlayIds objectAtIndex:j]];

            if([desc filterType] == "POINT") //really a point data object
                curOverlay = [curOverlay overlay];

            var curOverlayName = [curOverlay name];
            var dataTypeName = [desc subTypeForOption:curOverlayName];

            [[m_LeftSideTabView outlineView] addItem:curOverlayName forCategory:dataTypeName];
        }
    }

    [m_MapLoadingPanel showWithStatus:"Updating Feature Outline"];
    [[m_LeftSideTabView outlineView] sortItems];
    [m_MapLoadingPanel close];
}


/*======================LOGIN STUFF */
- (void)alertWithMessage:(CPString)aMessage title:(CPString)aTitle
{
    var activationAlert = [[CPAlert alloc] init];
    [activationAlert setTitle:aTitle];
    [activationAlert setAlertStyle:CPInformationalAlertStyle];
    [activationAlert setMessageText:aMessage];
    [activationAlert addButtonWithTitle:@"Ok"];
    [activationAlert runModal];
}

- (void)successfulAlertWithMessage:(CPString)aMessage
{
    [self alertWithMessage:aMessage title:@"Success!"];
}

- (void)failureAlertWithMessage:(CPString)aMessage
{
    [self alertWithMessage:aMessage title:@"Failed!"];
}

- (void)onLoginUser:(id)sender
{
    [[AKUserSessionManager defaultManager] triggerLogin];
}

- (void)onRegisterUser:(id)sender
{
    [[AKUserSessionManager defaultManager] triggerRegister];
}

- (void)onLogoutUser:(id)sender
{
    [[AKUserSessionManager defaultManager] triggerLogout];
}

- (void)onManageUser:(id)sender
{

}

- (void)onAdminUser:(id)sender
{
    window.open(g_UrlPrefix + "/admin");
}

- (void)onSessionSyncSuccessful:(id)sender
{
    [self updateMenuItems:YES];
    [self updateMenuBarTitle];
}

- (void)onSessionSyncFailed:(id)sender
{
    console.log("No session exists for this client on the server.");
}

- (void)onLoginSuccessful:(id)sender
{
    [self updateMenuItems:YES];
    [self updateMenuBarTitle];
    [m_ProjectCloudManager loadProjectDictData];
}

- (void)onRegisterSuccessful:(id)sender
{
    //Change Menu To Show Log-Out
    [self updateMenuItems:YES];
    [self updateMenuBarTitle];
}

- (void)onLogoutSuccessful:(id)sender
{
    [self updateMenuItems:NO];
    [m_ProjectCloudManager clearProjectDictData];
    [m_ProjectCloudManager setProjectName:"Untitled"];

    [self updateMenuBarTitle];
}

- (void)onLogoutFailed:(id)sender
{
    logoutFailedAlter = [CPAlert alertWithError:"Something went terrible wrong and we were unable to log you out."];
    [logoutFailedAlter addButtonWithTitle:"Ok, I'll call eTech IT right away!"];
}

- (void)updateMenuItems:(BOOL)sessionActive
{
    [m_AccountLoginMenuItem setHidden:sessionActive];
    [m_AccountRegisterMenuItem setHidden:sessionActive];

    [m_FileOpenMenuItem setHidden:!sessionActive];
    [m_FileSaveMenuItem setHidden:!sessionActive];
    [m_FileSaveAsMenuItem setHidden:!sessionActive];
    [m_FileSeparatorItem setHidden:!sessionActive];

    [m_AccountAdminMenuItem setHidden:!sessionActive];
    [m_AccountLogOutMenuItem setHidden:!sessionActive];

    [m_CsvImporter updateMenuItems:sessionActive];
}

- (void)updateMenuBarTitle
{
    var userId = [[AKUserSessionManager defaultManager] userIdentifier];
    var projectName = [[FKFileController getInstance] projectName];

    var theTitle = "";

    if(userId)
        theTitle += [userId capitalizedString] + "'s ";

    theTitle += [projectName capitalizedString] + " Project";

    [CPMenu setMenuBarTitle:theTitle];
}

//FILE MENU SELECTORS

- (void)onNewProject:(id)sender
{
    [m_NewProjectAlert runModal];
}

- (void)onOpenProject:(id)sender
{
    [m_ProjectCloudManager triggerOpenProject];
}

- (void)onSaveProject:(id)sender
{
    [m_ProjectCloudManager triggerSaveProject];
}

- (void)onSaveProjectAs:(id)sender
{
    [m_ProjectCloudManager triggerSaveProjectAs];
}

- (void)onExitGisedu:(id)sender
{     
    [m_ExitAlert runModal];
}

- (void)onAddPointFilter:(id)sender
{
    [[m_LeftSideTabView filtersView] onAddPointFilter:sender];
}

- (void)onAddPolygonFilter:(id)sender
{
    [[m_LeftSideTabView filtersView] onAddPolygonFilter:sender];
}

- (void)onAddReduceFilter:(id)sender
{
    [[m_LeftSideTabView filtersView] onAddReduceFilter:sender];
}

- (void)onAddPostFilter:(id)sender
{
    [[m_LeftSideTabView filtersView] onAddPostFilter:sender];
}

- (void)onDeleteFilter:(id)sender
{
    [[m_LeftSideTabView filtersView] onDeleteFilter:sender];
}

- (void)alertDidEnd:(CPAlert)theAlert returnCode:(int)returnCode
{
    if(theAlert == m_ExitAlert && returnCode == 1)
    {
        [[CPApplication sharedApplication] terminate:self];

        [[[CPApplication sharedApplication] mainWindow] close];
        [[[CPApplication sharedApplication] keyWindow] close];
        [[[CPApplication sharedApplication] modalWindow] close];

        [[theWindow platformWindow] orderOut:self];

        window.close();

        var badAlert = [CPAlert alertWithError:"Sorry. I could not close the window."];
        [badAlert runModal];
    }
    else if(theAlert == m_NewProjectAlert && returnCode == 1)
    {
        location.reload(true);
    }
}

- (id)buildJsonSaveData
{
    return {"filters": [m_FilterManager toJson]};
}

- (void)onOpenFileRequestSuccessful:(id)sender
{
    var jsonData = [sender jsonData];

    var filters = jsonData['filters'];

    [m_FilterManager fromJson:filters];
    [[m_LeftSideTabView filtersView] refreshOutline];
    [self onUpdateMapFilters:self];
    [self updateMenuBarTitle];
}

- (void)onOpenFileRequestFailed:(id)sender
{
    var badAlert = [CPAlert alertWithError:"Sorry. I could not open the project. " + [sender error]];
    [badAlert runModal];
}

- (void)onSaveFileRequestSuccessful:(id)sender
{
    var successAlert = [CPAlert alertWithError:"Your project was saved successfully to the server."];
    [successAlert setAlertStyle:CPInformationalAlertStyle];
    [successAlert runModal];

    [self updateMenuBarTitle];
}

- (void)onSaveFileRequestFailed:(id)sender
{
    var badAlert = [CPAlert alertWithError:"Sorry. I could not save the project. " + [sender error]];
    [badAlert runModal];
}

@end
