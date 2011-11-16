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
@import "Gisedu/views/OverlayOutlineView.j"
@import "Gisedu/views/OverlayOptionsView.j"

@import "Gisedu/views/AddFilterPanel.j"

@import "Gisedu/loaders/PolygonOverlayLoader.j"
@import "Gisedu/loaders/PointOverlayLoader.j"

@import "Gisedu/Modules/CsvImporter/CsvImportPanel.j"
@import "Gisedu/FileKit/FKFileController.j"

var m_NewProjectToolbarId = 'newProject';
var m_SaveProjectToolbarId = 'saveProject';
var m_SaveProjectAsToolbarId = 'saveProjectAs';
var m_OpenProjectToolbarId = 'openProject';

var m_OverlayOptionsToolbarId = 'overlayOptions';
var m_UpdateMapToolbarId = 'updateMap';

g_UrlPrefix = 'http://127.0.0.1:8000';

@implementation AppController : CPObject
{
    MKMapView m_MapView;
    CPWindow theWindow;
    CPView m_ContentView;

    LeftSideTabView m_LeftSideTabView;
    OverlayOptionsView m_OverlayOptionsView;

    id m_CurSelectedItem;

    CPArray m_CountyItems;
    CPArray m_SchoolDistrictItems;

    OverlayManager m_OverlayManager;
    FilterManager m_FilterManager;

    CPScrollView m_TableScrollView;

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
    CPMenuItem m_FileImportCSVItem;
    CPMenuItem m_FileExitMenuItem;      //exit Gisedu (closes browser tab)

    CPMenu m_AccountMenu;
    CPMenuItem m_AccountLoginMenuItem;
    CPMenuItem m_AccountRegisterMenuItem;
    CPMenuItem m_AccountLogOutMenuItem;
    CPMenuItem m_AccountAdminMenuItem;

    CPAlert m_ExitAlert;
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

    m_OverlayManager = [OverlayManager getInstance];
    [m_OverlayManager setDelegate:self];

    m_FilterManager = [FilterManager getInstance];
    [m_FilterManager setDelegate:self];
    [m_FilterManager loadFilterDescriptions];

    m_CountyItems = [CPArray array];
    m_SchoolDistrictItems = [CPArray array];

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

    m_OverlayOptionsView = [[OverlayOptionsView alloc] initWithParentView:m_ContentView];

    m_LeftSideTabView = [[LeftSideTabView alloc] initWithContentView:m_ContentView];
    [m_LeftSideTabView setDelegate:self];
    [[m_LeftSideTabView filtersView] setOptionsView:m_OverlayOptionsView];
    [m_ContentView addSubview:m_LeftSideTabView];

    //Not added to mapview because default is minimized

    m_TableScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(300, CGRectGetHeight([m_ContentView bounds]) - bottomHeight, CGRectGetWidth([m_ContentView bounds]), bottomHeight)];
    [m_TableScrollView setAutoresizingMask:CPViewMinYMargin | CPViewWidthSizable];
        var countyTableView = [[CPTableView alloc] initWithFrame:CGRectMake(300, 0, CGRectGetWidth([m_ContentView bounds]), bottomHeight)];
        var countyNameCol = [[CPTableColumn alloc] initWithIdentifier:@"CountyNameColumn"];
        [countyNameCol setWidth:125.0];
        [[countyNameCol headerView] setStringValue:"County Name"];
        [countyTableView addTableColumn:countyNameCol];
        [m_TableScrollView setDocumentView:countyTableView];
        console.log("Loaded Table View");

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
        m_FileSeparatorItem = [CPMenuItem separatorItem];
        m_FileImportCSVItem = [[CPMenuItem alloc] initWithTitle:@"Import CSV" action:@selector(onImportCSV:) keyEquivalent:nil];
        m_FileExitMenuItem = [[CPMenuItem alloc] initWithTitle:@"Exit Gisedu" action:@selector(onExitGisedu:) keyEquivalent:nil];

        [m_FileMenu addItem:m_FileNewMenuItem];
        [m_FileMenu addItem:m_FileOpenMenuItem];
        [m_FileMenu addItem:m_FileSaveMenuItem];
        [m_FileMenu addItem:m_FileSaveAsMenuItem];
        [m_FileMenu addItem:m_FileSeparatorItem];
        [m_FileMenu addItem:m_FileImportCSVItem];
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
  	    m_EditMenuDeleteFilter = [[CPMenuItem alloc] initWithTitle:@"Delete Filter" action:@selector(onDeleteFilter:) keyEquivalent:@"D"];

        [m_EditMenu addItem:m_EditMenuAddPointFilter];
        [m_EditMenu addItem:m_EditMenuAddPolygonFilter];
        [m_EditMenu addItem:m_EditMenuAddReduceFilter];
        [m_EditMenu addItem:m_EditMenuDeleteFilter];

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
    [m_OverlayOptionsView setPolygonOverlayTarget:sender];
    [self showOverlayOptionsView];
}

- (void)onPointOverlaySelected:(id)pointDataObject
{
    console.log("AppController::onPointOverlaySelected Called");
    [m_OverlayOptionsView setPointOverlayTarget:[pointDataObject overlay]];

    [[m_LeftSideTabView outlineView] selectItem:[pointDataObject name]];
}

- (void) onOutlineItemSelected:(id)sender
{
    var item = [sender itemAtRow:[sender selectedRow]];
    var itemParent = [sender parentForItem:item];

    var filterDesc = [[m_FilterManager filterDescriptions] allValues];

    if(itemParent == nil)
        return;

    var theItemId = -1;

    for(var i=0; i < [filterDesc count]; i++)
    {
        var curFilterDesc = [filterDesc objectAtIndex:i];

        var itemId = [self findItemIdOfItem:item withParent:itemParent inFilterDesc:curFilterDesc];

        if(itemId != -1)
        {
            var curDataType = [curFilterDesc dataType];

            if(curDataType == "POINT")
            {
                var pointDataObject = [m_OverlayManager getOverlayObject:[curFilterDesc id] objId:itemId];

                [pointDataObject toggleInfoWindow];
                [m_OverlayOptionsView setPointOverlayTarget:[pointDataObject overlay]];

                [self showOverlayOptionsView];
            }
            else if(curDataType == "POLYGON")
            {
                var overlay = [m_OverlayManager getOverlayObject:[curFilterDesc id] objId:itemId];

                [m_OverlayOptionsView setPolygonOverlayTarget:overlay];

                [self showOverlayOptionsView];
            }

            m_CurSelectedItem = item;
            return;
        }
    }
}

- (id) findItemIdOfItem:(id)item withParent:(id)itemParent inFilterDesc:(id)desc
{
    var filterDesc = [[m_FilterManager filterDescriptions] allValues];

    if(itemParent == nil)
        return -1;

    var curFilterType = [desc filterType];

    var filterOptions = [[desc options] allKeys];

    if(curFilterType == "LIST" && [desc name] == itemParent)
    {
        for(var j=0; j < [filterOptions count]; j++)
        {
            var curItemId = [filterOptions objectAtIndex:j];
            var curItemName = [[desc options] objectForKey:curItemId];

            if(curItemName == item)
                return curItemId;
        }
    }
    else if(curFilterType == "DICT")
    {
        for(var j=0; j < [filterOptions count]; j++)
        {
            var curFilterSubType = [filterOptions objectAtIndex:j];
            var curFilterDict = [[desc options] objectForKey:curFilterSubType];

            var curFilterDictKeys = [curFilterDict allKeys];

            for(var k=0; k < [curFilterDictKeys count]; k++)
            {
                var curItemId = [curFilterDictKeys objectAtIndex:k];
                var curItemName = [curFilterDict objectForKey:curItemId];

                if(curItemName == item)
                    return curItemId;
            }
        }
    }

    return -1;
}

- (void)showOverlayOptionsView
{
    [self updateMapTheory];
    m_MapWidth = m_MinMapWidth;

    [self updateMapViewFrame];
    [m_ContentView addSubview:m_OverlayOptionsView];
}

- (void)hideOverlayOptionsView
{
    [m_OverlayOptionsView removeFromSuperview];

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
    if([m_OverlayOptionsView superview] != nil)
    {
        [self hideOverlayOptionsView];
    }
    else
    {
        [self showOverlayOptionsView];
    }
}

- (void)onFilterDescriptionsLoaded
{
    [m_OverlayManager onFilterDescriptionsLoaded];
}

- (void)onUpdateMapFilters:(id)sender
{
    [[m_LeftSideTabView outlineView] clearItems];
    [m_FilterManager triggerFilters];
}

- (void)onOverlayListLoaded:(CPArray)overlays dataType:(CPString)dataType
{
    var filterDesc = [[m_FilterManager filterDescriptions] objectForKey:dataType];

    for(var i=0; i < [overlays count]; i++)
    {
        var curOverlayName = [[overlays objectAtIndex:i] name];
        var dataTypeName = [filterDesc subTypeForOption:curOverlayName];

        [[m_LeftSideTabView outlineView] addItem:curOverlayName forCategory:dataTypeName];
    }
}

- (void)onFilterRequestProcessed:(id)sender
{
    [[m_LeftSideTabView outlineView] sortItems];
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
    [m_FileImportCSVItem setHidden:!sessionActive];

    [m_AccountAdminMenuItem setHidden:!sessionActive];
    [m_AccountLogOutMenuItem setHidden:!sessionActive];
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

- (void)onImportCSV:(id)sender
{
    importPanel = [CsvImportPanel csvImportPanel];
    [importPanel orderFront:self];

    //openPanel = [CPOpenPanel openPanel];
    //[openPanel runModal];
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